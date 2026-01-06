import 'package:flutter/material.dart';
import 'add_manager_page.dart';
import 'branch_page.dart';
import 'analytics_page.dart';
import 'profile_page.dart';
import 'add_item_page.dart';
import 'view_workers.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = [
      {
        "title": "Add Manager",
        "icon": Icons.person_add,
        "page": const AddManagerPage(),
      },
      {"title": "Add Branch", "icon": Icons.store, "page": const BranchPage()},
      {
        "title": "View Analytics",
        "icon": Icons.bar_chart,
        "page": const AnalyticsPage(),
      },
      {
        "title": "Profile",
        "icon": Icons.account_circle,
        "page": const ProfilePage(),
      },
      {
        "title": "Add Item",
        "icon": Icons.add_shopping_cart,
        "page": const AddItemPage(),
      },
      {
        "title": "View Workers",
        "icon": Icons.group,
        "page": const ViewWorkersPage(),
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
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
