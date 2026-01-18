import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../customer/customer_page.dart';
import 'cart_provider.dart';

class CheckoutPage extends ConsumerWidget {
  final String branchId;
  final String branchName;

  const CheckoutPage({
    super.key,
    required this.branchId,
    required this.branchName,
  });

  Future<void> _placeOrder(BuildContext context, WidgetRef ref) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final cart = ref.read(cartProvider);
    if (cart.isEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerPage()),
        (route) => false,
      );
      return;
    }

    // 🔽 Fetch user full name from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userName = userDoc.exists ? userDoc['full_name'] ?? "" : "";

    final itemsList = cart.map((item) {
      return {
        "item_id": item.id,
        "name": item.name,
        "quantity": item.quantity,
        "price": item.price,
        "photo_url": item.photoUrl,
      };
    }).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      "user_id": user.uid,
      "user_name": userName,
      "branch_id": branchId,
      "branch_name": branchName,
      "items": itemsList,
      "total_price": ref.read(cartProvider.notifier).totalPrice(),
      "created_at": FieldValue.serverTimestamp(),
    });

    ref.read(cartProvider.notifier).clearCart();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order placed successfully!")));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerPage()),
      (route) => false,
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String itemId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Remove item?"),
        content: const Text("Do you want to remove this item from your cart?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () {
              ref.read(cartProvider.notifier).deleteItem(itemId);
              Navigator.pop(context);
              if (ref.read(cartProvider).isEmpty) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerPage()),
                  (route) => false,
                );
              }
            },
            child: const Text("Yes"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final totalPrice = ref.read(cartProvider.notifier).totalPrice();

    if (cart.isEmpty) {
      Future.microtask(() {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const CustomerPage()),
          (route) => false,
        );
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...cart.map((item) {
            return Card(
              child: ListTile(
                leading: (item.photoUrl.isNotEmpty)
                    ? Image.network(
                        item.photoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.fastfood, size: 40),
                title: Text(item.name),
                subtitle: Text(
                  "Qty: ${item.quantity} • \$${item.price * item.quantity}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _confirmDelete(context, ref, item.id),
                ),
              ),
            );
          }),
          const SizedBox(height: 20),
          Text(
            "Total: \$${totalPrice.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => _placeOrder(context, ref),
            child: const Text("Place Order"),
          ),
        ],
      ),
    );
  }
}
