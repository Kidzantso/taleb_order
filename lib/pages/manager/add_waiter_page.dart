import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_widget.dart';

class AddWaiterPage extends StatefulWidget {
  const AddWaiterPage({super.key});

  @override
  State<AddWaiterPage> createState() => _AddWaiterPageState();
}

class _AddWaiterPageState extends State<AddWaiterPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> addWaiter() async {
    if (!validateField(context, _firstNameController.text, "First Name") ||
        !validateField(context, _lastNameController.text, "Last Name") ||
        !validateEmail(context, _emailController.text) ||
        !validateField(context, _passwordController.text, "Password")) {
      return;
    }

    try {
      // ✅ Get current manager user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Manager not logged in")));
        return;
      }
      final managerDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      final managerData = managerDoc.data();
      final branchId = managerData?['branch_id'];

      if (branchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Manager has no branch assigned")),
        );
        return;
      }

      // ✅ Create waiter account
      UserCredential waiterCred = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final fullName =
          "${_firstNameController.text.trim()} ${_lastNameController.text.trim()}";

      await _firestore.collection('users').doc(waiterCred.user!.uid).set({
        'email': _emailController.text.trim(),
        'full_name': fullName,
        'role': 'waiter',
        'branch_id': branchId, // ✅ linked to manager's branch
        'created_at': FieldValue.serverTimestamp(),
      });

      _firstNameController.clear();
      _lastNameController.clear();
      _emailController.clear();
      _passwordController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Waiter added and linked to branch ✅")),
      );
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
      appBar: AppBar(title: const Text("Add Waiter")),
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
              onPressed: addWaiter,
              child: const Text("Add Waiter"),
            ),
          ],
        ),
      ),
    );
  }
}
