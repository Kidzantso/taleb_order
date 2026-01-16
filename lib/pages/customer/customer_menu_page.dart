import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_page.dart';

class CustomerMenuPage extends StatefulWidget {
  const CustomerMenuPage({super.key});

  @override
  State<CustomerMenuPage> createState() => _CustomerMenuPageState();
}

class _CustomerMenuPageState extends State<CustomerMenuPage> {
  final _firestore = FirebaseFirestore.instance;
  String? _selectedBranchId;
  String? _selectedBranchName;

  final Map<String, int> _cart = {}; // itemId → quantity
  final Map<String, Map<String, dynamic>> _itemDetails = {}; // itemId → data

  void _addItem(String itemId, Map<String, dynamic> data) {
    setState(() {
      _cart[itemId] = (_cart[itemId] ?? 0) + 1;
      _itemDetails[itemId] = data;
    });
  }

  void _removeItem(String itemId) {
    if (_cart[itemId] == 1) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Remove item?"),
          content: const Text(
            "Do you want to cancel this item from your order?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _cart.remove(itemId);
                  _itemDetails.remove(itemId);
                });
                Navigator.pop(context);
              },
              child: const Text("Yes"),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _cart[itemId] = _cart[itemId]! - 1;
      });
    }
  }

  void _goToCheckout() {
    if (_selectedBranchId == null || _selectedBranchName == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckoutPage(
          cart: _cart,
          itemDetails: _itemDetails,
          branchId: _selectedBranchId!,
          branchName: _selectedBranchName!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Browse Menus")),
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('branches').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const CircularProgressIndicator();
              final branches = snapshot.data!.docs;
              return DropdownButton<String>(
                value: _selectedBranchId,
                hint: const Text("Select Branch"),
                items: branches.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Text(data['branch_name'] ?? "Unnamed Branch"),
                    onTap: () {
                      _selectedBranchName = data['branch_name'];
                    },
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedBranchId = val),
              );
            },
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _selectedBranchId == null
                ? const Center(child: Text("Please select a branch"))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('branch_menus')
                        .doc(_selectedBranchId)
                        .collection('items')
                        .where('is_available', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const CircularProgressIndicator();
                      final menus = snapshot.data!.docs;
                      if (menus.isEmpty)
                        return const Center(child: Text("No available items"));

                      return ListView.builder(
                        itemCount: menus.length,
                        itemBuilder: (context, index) {
                          final doc = menus[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final itemId = doc.id;
                          final quantity = _cart[itemId] ?? 0;

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
                                "${data['category']} • \$${data['price']}",
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (quantity > 0)
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _removeItem(itemId),
                                    ),
                                  if (quantity > 0)
                                    Text(
                                      quantity.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => _addItem(itemId, data),
                                  ),
                                ],
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
      floatingActionButton: _cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _goToCheckout,
              label: Text("Cart (${_cart.values.reduce((a, b) => a + b)})"),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }
}
