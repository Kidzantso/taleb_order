import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerMenuPage extends StatefulWidget {
  const CustomerMenuPage({super.key});

  @override
  State<CustomerMenuPage> createState() => _CustomerMenuPageState();
}

class _CustomerMenuPageState extends State<CustomerMenuPage> {
  final _firestore = FirebaseFirestore.instance;
  String? _selectedBranchId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse Menus")),
      body: Column(
        children: [
          // 🔽 Branch Dropdown
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('branches').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final branches = snapshot.data!.docs;

              return DropdownButton<String>(
                value: _selectedBranchId,
                hint: const Text("Select Branch"),
                items: branches.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(data['branch_name'] ?? "Unnamed Branch"),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedBranchId = val;
                  });
                },
              );
            },
          ),

          const SizedBox(height: 20),

          // 🔽 Menu Items
          Expanded(
            child: _selectedBranchId == null
                ? const Center(child: Text("Please select a branch"))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('branch_menus')
                        .doc(_selectedBranchId)
                        .collection('items')
                        .where(
                          'is_available',
                          isEqualTo: true,
                        ) // ✅ only available
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final menus = snapshot.data!.docs;

                      if (menus.isEmpty) {
                        return const Center(child: Text("No available items"));
                      }

                      return ListView.builder(
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final data =
                              menus[index].data() as Map<String, dynamic>;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: ListTile(
                              leading:
                                  (data['photo_url'] != null &&
                                      data['photo_url'].toString().isNotEmpty)
                                  ? Image.network(
                                      data['photo_url'],
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    )
                                  : const Icon(Icons.fastfood, size: 40),
                              title: Text(data['name'] ?? ""),
                              subtitle: Text(
                                "${data['category']} • \$${data['price'] ?? 'N/A'}",
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
