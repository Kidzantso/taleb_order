import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(body: Center(child: Text("Not logged in")));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("My Orders")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('user_id', isEqualTo: user!.uid)
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

              final branchName = data['branch_name'] ?? "Unknown Branch";
              final orderId = order.id;
              final createdAt = (data['created_at'] as Timestamp?)?.toDate();
              final formattedDate = createdAt != null
                  ? DateFormat("MMM dd • hh:mm a").format(createdAt)
                  : "Unknown Date";

              final items = (data['items'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();

              final totalPrice = data['total_price'] ?? 0;

              return _CustomExpansionTile(
                title: Text(
                  branchName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("$formattedDate • Order ID: $orderId"),
                children: [
                  ...items.map((item) {
                    return ListTile(
                      title: Text(item['name']),
                      subtitle: Text("Qty: ${item['quantity']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("\$${item['price']}"),
                          const SizedBox(width: 8),
                          (item['photo_url'] != null &&
                                  item['photo_url'].toString().isNotEmpty)
                              ? Image.network(
                                  item['photo_url'],
                                  width: 40,
                                  height: 40,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.fastfood, size: 40),
                        ],
                      ),
                    );
                  }),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Total: \$${totalPrice.toString()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

/// ✅ Custom ExpansionTile with arrow rotation
class _CustomExpansionTile extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final List<Widget> children;

  const _CustomExpansionTile({
    required this.title,
    this.subtitle,
    required this.children,
  });

  @override
  State<_CustomExpansionTile> createState() => _CustomExpansionTileState();
}

class _CustomExpansionTileState extends State<_CustomExpansionTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: widget.title,
      subtitle: widget.subtitle,
      trailing: AnimatedRotation(
        turns: _expanded ? 0.25 : 0, // 0 → right, 0.25 → down
        duration: const Duration(milliseconds: 200),
        child: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
      onExpansionChanged: (val) {
        setState(() => _expanded = val);
      },
      children: widget.children,
    );
  }
}
