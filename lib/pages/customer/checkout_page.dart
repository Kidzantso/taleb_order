import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../customer/customer_page.dart';

class CheckoutPage extends StatefulWidget {
  final Map<String, int> cart;
  final Map<String, Map<String, dynamic>> itemDetails;
  final String branchId;
  final String branchName;

  const CheckoutPage({
    super.key,
    required this.cart,
    required this.itemDetails,
    required this.branchId,
    required this.branchName,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  double _calculateTotal() {
    double total = 0;
    widget.cart.forEach((itemId, qty) {
      final price = (widget.itemDetails[itemId]?['price'] ?? 0).toDouble();
      total += price * qty;
    });
    return total;
  }

  void _deleteItem(String itemId) {
    setState(() {
      widget.cart.remove(itemId);
      widget.itemDetails.remove(itemId);
    });
  }

  Future<void> _placeOrder(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // 🔽 Fetch user full name from Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final userName = userDoc.exists ? userDoc['full_name'] ?? "" : "";

    final totalPrice = _calculateTotal();

    final itemsList = widget.cart.entries.map((entry) {
      final itemId = entry.key;
      final qty = entry.value;
      final data = widget.itemDetails[itemId]!;
      return {
        "item_id": itemId,
        "name": data['name'],
        "quantity": qty,
        "price": data['price'],
      };
    }).toList();

    await FirebaseFirestore.instance.collection('orders').add({
      "user_id": user.uid,
      "user_name": userName,
      "branch_id": widget.branchId,
      "branch_name": widget.branchName,
      "items": itemsList,
      "total_price": totalPrice,
      "created_at": FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Order placed successfully!")));

    // ✅ Redirect to CustomerPage (home) and clear cart
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotal();

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...widget.cart.entries.map((entry) {
            final itemId = entry.key;
            final qty = entry.value;
            final data = widget.itemDetails[itemId]!;
            final price = (data['price'] ?? 0).toDouble();
            return Card(
              child: ListTile(
                title: Text(data['name']),
                subtitle: Text("Qty: $qty • \$${price * qty}"),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteItem(itemId),
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
            onPressed: () => _placeOrder(context),
            child: const Text("Place Order"),
          ),
        ],
      ),
    );
  }
}
