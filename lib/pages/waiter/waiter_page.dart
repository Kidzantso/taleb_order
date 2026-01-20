import 'package:flutter/material.dart';
import '../../pages/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../profile_page.dart';

class WaiterPage extends StatefulWidget {
  const WaiterPage({super.key});

  @override
  State<WaiterPage> createState() => _WaiterPageState();
}

Future<void> _signOut(BuildContext context) async {
  await FirebaseAuth.instance.signOut();
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (route) => false,
  );
}

class _WaiterPageState extends State<WaiterPage> {
  final _firestore = FirebaseFirestore.instance;
  String? _branchId;

  @override
  void initState() {
    super.initState();
    _loadBranchId();
  }

  Future<void> _markAsServed(String orderId) async {
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      "status": "served",
    });
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
        title: const Text("Waiter Dashboard"),
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
            .where('status', isEqualTo: 'serving') // waiter sees serving orders
            .orderBy('created_at', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!.docs;

          if (orders.isEmpty) {
            return const Center(
              child: Text(
                "No orders to serve",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        onPressed: () => _markAsServed(orderId),
                        child: const Text("Mark as Served"),
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
