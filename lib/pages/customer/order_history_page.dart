import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrderHistoryPage extends StatelessWidget {
  const OrderHistoryPage({super.key});

  Color _statusColor(String status) {
    switch (status) {
      case "pending":
        return Colors.red; // kitchen
      case "serving":
        return Colors.yellow.shade700; // waiter
      case "served":
        return Colors.green; // completed
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case "pending":
        return "In Kitchen";
      case "serving":
        return "With Waiter";
      case "served":
        return "Served";
      default:
        return "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text("Not logged in"));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('user_id', isEqualTo: user.uid)
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No orders yet"));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final orderId = order.id;
              final branchName = data['branch_name'] ?? "Unknown Branch";
              final status = data['status'] ?? "unknown";
              final items = (data['items'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text("Order $orderId"),
                  subtitle: Text("Branch: $branchName"),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  children: [
                    ...items.map(
                      (item) => ListTile(
                        leading:
                            (item['photo_url'] != null &&
                                item['photo_url'].toString().isNotEmpty)
                            ? Image.network(
                                item['photo_url'],
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.fastfood, size: 30),
                        title: Text(item['name']),
                        subtitle: Text("Qty: ${item['quantity']}"),
                        trailing: Text("\$${item['price']}"),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
