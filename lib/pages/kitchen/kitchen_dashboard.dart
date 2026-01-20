import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../pages/auth/login_page.dart';
import '../profile_page.dart';

class KitchenPage extends StatefulWidget {
  const KitchenPage({super.key});

  @override
  State<KitchenPage> createState() => _KitchenPageState();
}

Future<void> _signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

class _KitchenPageState extends State<KitchenPage> {
  final _firestore = FirebaseFirestore.instance;
  String? _branchId;

  @override
  void initState() {
    super.initState();
    _loadBranchId();
  }

  Future<void> _loadBranchId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    setState(() => _branchId = userDoc.data()?['branch_id']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kitchen Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sign Out",
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('branch_id', isEqualTo: _branchId)
            .where('status', isEqualTo: 'pending') // only kitchen orders
            .orderBy('created_at', descending: false) // FIFO
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(child: Text("No pending orders"));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final data = order.data() as Map<String, dynamic>;

              final orderId = order.id;
              final userName = data['user_name'] ?? "Unknown";
              final items = (data['items'] as List<dynamic>? ?? [])
                  .map((item) => item as Map<String, dynamic>)
                  .toList();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text("Order $orderId"),
                  subtitle: Text("Customer: $userName"),
                  children: [
                    ...items.map(
                      (item) => ListTile(
                        title: Text(item['name']),
                        subtitle: Text("Qty: ${item['quantity']}"),
                        trailing: Text("\$${item['price']}"),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          await FirebaseFirestore.instance
                              .collection('orders')
                              .doc(orderId)
                              .update({"status": "serving"});
                        },
                        child: const Text("Mark as Serving"),
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
