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
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  Future<void> registerCustomer() async {
    if (!validateField(context, _firstNameController.text, "First Name") ||
        !validateField(context, _lastNameController.text, "Last Name") ||
        !validateEmail(context, _emailController.text) ||
        !validateField(context, _passwordController.text, "Password")) {
      return;
    }

    try {
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ✅ Concatenate first + last name
      final fullName =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

      await _firestore.collection('users').doc(userCred.user!.uid).set({
        'email': _emailController.text.trim(),
        'full_name': fullName,
        'role': 'customer',
        'branch_id': null,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Customer registered successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      _emailController.clear();
      _passwordController.clear();
      _firstNameController.clear();
      _lastNameController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Invalid email or password format")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Customer")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            customTextField(_firstNameController, "First Name"),
            customTextField(_lastNameController, "Last Name"),
            customTextField(_emailController, "Email"),
            customTextField(_passwordController, "Password", obscure: true),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: registerCustomer,
              child: const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
