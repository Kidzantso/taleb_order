import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../admin/admin_dashboard.dart';
import '../customer/customer_page.dart';
import '../manager/manager_dashboard.dart';
import '../waiter/waiter_page.dart';
import 'register_page.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  /// ✅ If user already logged in, redirect immediately
  Future<void> _checkExistingSession() async {
    final user = _auth.currentUser;
    if (user != null) {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        _navigateByRole(userDoc['role']);
      }
    }
  }

  /// ✅ Centralized role routing
  void _navigateByRole(String role) {
    Widget page;
    switch (role) {
      case 'admin':
        page = const AdminDashboard();
        break;
      case 'customer':
        page = const CustomerPage();
        break;
      case 'manager':
        page = const ManagerDashboard();
        break;
      case 'waiter':
        page = const WaiterPage();
        break;
      default:
        page = const LoginPage();
    }

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _loginUser() async {
    if (!validateEmail(context, _emailController.text) ||
        !validateField(context, _passwordController.text, "Password")) {
      return;
    }

    try {
      final userCred = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final userDoc = await _firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .get();

      if (userDoc.exists) {
        _navigateByRole(userDoc['role']);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User role not found")));
      }
    } catch (e) {
      _emailController.clear();
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Incorrect email or password")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Center(
        // ✅ centers everything vertically & horizontally
        child: SingleChildScrollView(
          // ✅ prevents overflow on small screens
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // ✅ vertical center
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/TaleborderIcon.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              customTextField(_emailController, "Email"),
              const SizedBox(height: 12),
              customTextField(_passwordController, "Password", obscure: true),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _loginUser, child: const Text("Login")),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: const Text("Register as Customer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
