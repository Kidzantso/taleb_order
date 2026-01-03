import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_widget.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  Future<void> registerCustomer() async {
    if (!validateField(context, _nameController.text, "Full Name") ||
        !validateEmail(context, _emailController.text) ||
        !validateField(context, _passwordController.text, "Password")) {
      return;
    }

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'email': _emailController.text.trim(),
        'full_name': _nameController.text.trim(),
        'role': 'customer',
        'branch_id': null,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer registered successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      _emailController.clear();
      _passwordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password format")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Customer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(_nameController, "Full Name"),
            customTextField(_emailController, "Email"),
            customTextField(_passwordController, "Password", obscure: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerCustomer,
              child: Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
