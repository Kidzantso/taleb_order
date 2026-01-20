import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Import dashboards for navigation
import 'admin/admin_dashboard.dart';
import 'manager/manager_dashboard.dart';
import 'waiter/waiter_page.dart';
import 'kitchen/kitchen_dashboard.dart';
import 'customer/customer_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = true;
  String? _email;
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      final data = doc.data();
      if (data != null) {
        final fullName = (data['full_name'] ?? "").split(" ");
        _firstNameController.text = fullName.isNotEmpty ? fullName.first : "";
        _lastNameController.text = fullName.length > 1
            ? fullName.sublist(1).join(" ")
            : "";
        _email = data['email'];
        _role = data['role'];
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _updateProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final fullName = "$firstName $lastName";

    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();
    final currentPassword = _currentPasswordController.text.trim();

    // ✅ Password check
    if (newPassword.isNotEmpty && newPassword != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Passwords do not match ❌")));
      return;
    }

    // Update Firestore full_name
    await _firestore.collection('users').doc(user.uid).update({
      'full_name': fullName,
    });

    // Update password if provided
    if (newPassword.isNotEmpty) {
      try {
        final cred = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(cred);
        await user.updatePassword(newPassword);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Password update failed: $e")));
        return;
      }
    }

    // Clear fields
    _firstNameController.clear();
    _lastNameController.clear();
    _currentPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Profile updated ✅")));

    // Navigate back to role-based dashboard
    if (_role == "admin") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AdminDashboard()),
        (route) => false,
      );
    } else if (_role == "manager") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ManagerDashboard()),
        (route) => false,
      );
    } else if (_role == "waiter") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WaiterPage()),
        (route) => false,
      );
    } else if (_role == "kitchen") {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => KitchenPage()),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const CustomerPage()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text("My Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (_email != null)
              Text(
                "Email: $_email",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            TextField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: "First Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: "Last Name"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _currentPasswordController,
              decoration: const InputDecoration(labelText: "Current Password"),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _newPasswordController,
              decoration: const InputDecoration(labelText: "New Password"),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPasswordController,
              decoration: const InputDecoration(labelText: "Confirm Password"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }
}
