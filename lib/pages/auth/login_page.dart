import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../admin/admin_dashboard.dart';
import '../customer/customer_page.dart';
import '../manager/manager_page.dart';
import '../waiter/waiter_page.dart';
import 'register_page.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_widget.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> loginUser() async {
    if (!validateEmail(context, _emailController.text) ||
        !validateField(context, _passwordController.text, "Password")) {
      return;
    }

    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userCred.user!.uid)
          .get();
      String role = userDoc['role'];

      if (role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else if (role == 'customer') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const CustomerPage()),
        );
      } else if (role == 'manager') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ManagerPage()),
        );
      } else if (role == 'waiter') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WaiterPage()),
        );
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
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(_emailController, "Email"),
            customTextField(_passwordController, "Password", obscure: true),
            SizedBox(height: 20),
            ElevatedButton(onPressed: loginUser, child: Text("Login")),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("Register as Customer"),
            ),
          ],
        ),
      ),
    );
  }
}
