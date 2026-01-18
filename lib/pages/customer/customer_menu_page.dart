import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'checkout_page.dart';
import 'cart_provider.dart';

class CustomerMenuPage extends ConsumerStatefulWidget {
  const CustomerMenuPage({super.key});

  @override
  ConsumerState<CustomerMenuPage> createState() => _CustomerMenuPageState();
}

class _CustomerMenuPageState extends ConsumerState<CustomerMenuPage> {
  String? _selectedBranchId;
  String? _selectedBranchName;

  @override
  Widget build(BuildContext context) {
    final _firestore = FirebaseFirestore.instance;
    final cart = ref.watch(cartProvider);

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
                    onTap: () => _selectedBranchName = data['branch_name'],
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
                          final quantity = cart
                              .firstWhere(
                                (i) => i.id == itemId,
                                orElse: () => CartItem(
                                  id: itemId,
                                  name: data['name'],
                                  price: (data['price'] ?? 0).toDouble(),
                                  photoUrl: data['photo_url'] ?? "",
                                  quantity: 0,
                                ),
                              )
                              .quantity;

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
                                      onPressed: () => ref
                                          .read(cartProvider.notifier)
                                          .removeItem(itemId),
                                    ),
                                  if (quantity > 0)
                                    Text(
                                      quantity.toString(),
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => ref
                                        .read(cartProvider.notifier)
                                        .addItem(
                                          CartItem(
                                            id: itemId,
                                            name: data['name'],
                                            price: (data['price'] ?? 0)
                                                .toDouble(),
                                            photoUrl: data['photo_url'] ?? "",
                                            quantity: 1,
                                          ),
                                        ),
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
      floatingActionButton: cart.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CheckoutPage(
                      branchId: _selectedBranchId!,
                      branchName: _selectedBranchName!,
                    ),
                  ),
                );
              },
              label: Text(
                "Cart (${ref.read(cartProvider.notifier).totalItems()})",
              ),
              icon: const Icon(Icons.shopping_cart),
            )
          : null,
    );
  }
}
