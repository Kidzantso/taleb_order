import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_waiter_page.dart';
import 'branch_analytics.dart';
import 'menu_items_page.dart';
import 'view_waiters.dart';

class ManagerDashboard extends StatefulWidget {
  const ManagerDashboard({super.key});

  @override
  State<ManagerDashboard> createState() => _ManagerDashboardState();
}

class _ManagerDashboardState extends State<ManagerDashboard> {
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
    if (_branchId == null) {
      return const Scaffold(body: Center(child: Text("No branch linked yet")));
    }

    final items = [
      {
        "title": "Add Waiter",
        "icon": Icons.person_add,
        "page": const AddWaiterPage(),
      },
      {
        "title": "Add Items in menu",
        "icon": Icons.store,
        "page": MenuItemsPage(branchId: _branchId!), // pass branchId
      },
      {
        "title": "View Analytics",
        "icon": Icons.bar_chart,
        "page": const BranchAnalyticsPage(),
      },
      {
        "title": "View Waiters",
        "icon": Icons.group,
        "page": const ViewWaitersPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Manager Dashboard")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => item["page"] as Widget),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF0022),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(item["icon"] as IconData, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    item["title"] as String,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
