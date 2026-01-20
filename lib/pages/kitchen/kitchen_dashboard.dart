import 'dart:async';
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
  String _selectedStrategy = "FIFO";
  List<QueryDocumentSnapshot> _orders = [];
  List<QueryDocumentSnapshot> _deferredOrders = [];
  Timer? _roundRobinTimer;
  Timer? _countdownTimer;
  int _activeIndex = 0;
  int _countdown = 5; // seconds per slice

  @override
  void initState() {
    super.initState();
    _loadBranchId();
  }

  @override
  void dispose() {
    _roundRobinTimer?.cancel();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBranchId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final userDoc = await _firestore.collection('users').doc(uid).get();
    setState(() => _branchId = userDoc.data()?['branch_id']);
  }

  void _startRoundRobin() {
    _roundRobinTimer?.cancel();
    _countdownTimer?.cancel();
    _activeIndex = 0;
    _countdown = 5;

    // Rotate orders every slice
    _roundRobinTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_selectedStrategy == "Round Robin" && _orders.isNotEmpty) {
        setState(() {
          _activeIndex = (_activeIndex + 1) % _orders.length;
          _countdown = 5;
        });
      }
    });

    // Countdown timer
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_selectedStrategy == "Round Robin" && _orders.isNotEmpty) {
        setState(() {
          _countdown = (_countdown > 0) ? _countdown - 1 : 0;
        });
      }
    });
  }

  List<QueryDocumentSnapshot> _applyStrategy(List<QueryDocumentSnapshot> docs) {
    var orders = [...docs];

    if (_selectedStrategy == "FIFO") {
      orders.sort((a, b) {
        final aDate = a['created_at'] as Timestamp?;
        final bDate = b['created_at'] as Timestamp?;
        return aDate!.compareTo(bDate!);
      });
    } else if (_selectedStrategy == "Multi-Queue") {
      final smallOrders = orders
          .where((d) => (d['items'] as List).length <= 3)
          .toList();
      final largeOrders = orders
          .where((d) => (d['items'] as List).length > 3)
          .toList();
      _deferredOrders = largeOrders;
      orders = smallOrders;
    }

    return orders;
  }

  Widget _buildOrderCard(Map<String, dynamic> data, bool isActive) {
    final items = (data['items'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .toList();

    return Card(
      color: isActive ? Colors.yellow.shade100 : null,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map(
            (item) => ListTile(
              title: Text(item['name']),
              subtitle: Text("Qty: ${item['quantity']}"),
              trailing: Text("\$${item['price']}"),
            ),
          ),
          if (isActive && _selectedStrategy == "Round Robin")
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text("⏱ $_countdown s left"),
                  LinearProgressIndicator(
                    value: _countdown / 5,
                    minHeight: 6,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
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
      body: _branchId == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Strategy buttons
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedStrategy = "FIFO";
                            _roundRobinTimer?.cancel();
                            _countdownTimer?.cancel();
                          });
                        },
                        child: const Text("FIFO"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedStrategy = "Round Robin";
                            _startRoundRobin();
                          });
                        },
                        child: const Text("Round Robin"),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedStrategy = "Multi-Queue";
                            _roundRobinTimer?.cancel();
                            _countdownTimer?.cancel();
                          });
                        },
                        child: const Text("Multi-Queue"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('orders')
                        .where('branch_id', isEqualTo: _branchId)
                        .where('status', isEqualTo: 'pending')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      _orders = _applyStrategy(snapshot.data!.docs);

                      if (_orders.isEmpty && _deferredOrders.isEmpty) {
                        return const Center(child: Text("No pending orders"));
                      }

                      return ListView(
                        children: [
                          // Active queue
                          ..._orders.asMap().entries.map((entry) {
                            final index = entry.key;
                            final order = entry.value;
                            final data = order.data() as Map<String, dynamic>;
                            final isActive =
                                _selectedStrategy == "Round Robin" &&
                                index == _activeIndex;

                            return Dismissible(
                              key: Key(order.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                              onDismissed: (direction) async {
                                await _firestore
                                    .collection('orders')
                                    .doc(order.id)
                                    .update({"status": "serving"});

                                // Replace any existing snackbar
                                ScaffoldMessenger.of(
                                  context,
                                ).hideCurrentSnackBar();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      "Order marked as serving ✅",
                                    ),
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 3),
                                    action: SnackBarAction(
                                      label: "UNDO",
                                      textColor: Colors.yellow,
                                      onPressed: () async {
                                        await _firestore
                                            .collection('orders')
                                            .doc(order.id)
                                            .update({"status": "pending"});
                                        // Hide snackbar immediately after undo
                                        ScaffoldMessenger.of(
                                          context,
                                        ).hideCurrentSnackBar();
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: _buildOrderCard(data, isActive),
                            );
                          }),
                          // Deferred queue (Multi-Queue)
                          if (_selectedStrategy == "Multi-Queue" &&
                              _deferredOrders.isNotEmpty)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Deferred Orders",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                ..._deferredOrders.map((order) {
                                  final data =
                                      order.data() as Map<String, dynamic>;
                                  return Dismissible(
                                    key: Key(order.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      color: Colors.green,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    ),
                                    onDismissed: (direction) async {
                                      await _firestore
                                          .collection('orders')
                                          .doc(order.id)
                                          .update({"status": "serving"});

                                      ScaffoldMessenger.of(
                                        context,
                                      ).hideCurrentSnackBar();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: const Text(
                                            "Order marked as serving ✅",
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          duration: const Duration(seconds: 3),
                                          action: SnackBarAction(
                                            label: "UNDO",
                                            textColor: Colors.yellow,
                                            onPressed: () async {
                                              await _firestore
                                                  .collection('orders')
                                                  .doc(order.id)
                                                  .update({
                                                    "status": "pending",
                                                  });
                                              ScaffoldMessenger.of(
                                                context,
                                              ).hideCurrentSnackBar();
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: _buildOrderCard(data, false),
                                  );
                                }),
                              ],
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
