import 'package:flutter/material.dart';
import 'customer_menu_page.dart';
import '../../pages/auth/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required String title,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Customer Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Sign Out",
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildOption(
            context: context,
            title: "Dine In",
            imagePath: "assets/images/menu.jpg",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerMenuPage()),
              );
            },
          ),
          _buildOption(
            context: context,
            title: "Drive Thru",
            imagePath: "assets/images/drive_thru.jpg",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Drive Thru not available yet")),
              );
            },
          ),
          _buildOption(
            context: context,
            title: "Order Online",
            imagePath: "assets/images/order.jpg",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Order Online not available yet")),
              );
            },
          ),
        ],
      ),
    );
  }
}
