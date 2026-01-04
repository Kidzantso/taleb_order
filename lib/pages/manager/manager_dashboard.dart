import 'package:flutter/material.dart';
import 'add_waiter_page.dart';
import 'branch_analytics.dart';
import 'menu_items_page.dart';

class ManagerDashboard extends StatelessWidget {
  const ManagerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        "title": "Add Waiter",
        "icon": Icons.person_add,
        "page": const AddWaiterPage(),
      },
      {
        "title": "Add Items in menu",
        "icon": Icons.store,
        "page": const MenuItemsPage(),
      },
      {
        "title": "View Analytics",
        "icon": Icons.bar_chart,
        "page": const BranchAnalyticsPage(),
      },
      // {
      //   "title": "Profile",
      //   "icon": Icons.account_circle,
      //   "page": const ProfilePage(),
      // },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Manager Dashboard")),
      body: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 icons per row
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
