import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ for creating kitchen account
import '../../utils/validators.dart';
import '../../widgets/custom_widget.dart';

class BranchPage extends StatefulWidget {
  const BranchPage({super.key});

  @override
  State<BranchPage> createState() => _BranchPageState();
}

class _BranchPageState extends State<BranchPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _branchNameController = TextEditingController();
  String? selectedBranchId;
  String? selectedManagerId;

  Future<void> addBranch() async {
    if (!validateField(context, _branchNameController.text, "Branch Name")) {
      return;
    }

    // 1️⃣ Add branch to Firestore
    final branchDoc = await _firestore.collection('branches').add({
      'branch_name': _branchNameController.text.trim(),
      'manager_id': null,
    });

    final branchId = branchDoc.id;
    final branchName = _branchNameController.text.trim();

    // 2️⃣ Generate kitchen account credentials
    final kitchenEmail = "kitchen_$branchName@taleborder.com";
    const kitchenPassword = "taleborderkitchen#1-2-3";

    try {
      // 3️⃣ Create kitchen user in Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: kitchenEmail,
        password: kitchenPassword,
      );

      final kitchenUserId = userCredential.user!.uid;

      // 4️⃣ Save kitchen user in Firestore
      await _firestore.collection('users').doc(kitchenUserId).set({
        'full_name': "Kitchen - $branchName",
        'email': kitchenEmail,
        'role': 'kitchen',
        'branch_id': branchId,
        'created_at': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Branch + Kitchen account created")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error creating kitchen account: $e")),
      );
    }

    _branchNameController.clear();
  }

  Future<void> linkManagerToBranch() async {
    if (selectedBranchId == null || selectedManagerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Select branch and manager")),
      );
      return;
    }

    await _firestore.collection('branches').doc(selectedBranchId).update({
      'manager_id': selectedManagerId,
    });

    await _firestore.collection('users').doc(selectedManagerId).update({
      'branch_id': selectedBranchId,
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Manager linked to branch")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Branches")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Add Branch",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            customTextField(_branchNameController, "Branch Name"),
            ElevatedButton(
              onPressed: addBranch,
              child: const Text("Add Branch"),
            ),
            const Divider(height: 40),

            const Text(
              "Link Manager to Branch",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('branches').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return DropdownButton<String>(
                  hint: const Text("Select Branch"),
                  value: selectedBranchId,
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['branch_name']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedBranchId = val),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('users')
                  .where('role', isEqualTo: 'manager')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                return DropdownButton<String>(
                  hint: const Text("Select Manager"),
                  value: selectedManagerId,
                  items: snapshot.data!.docs.map((doc) {
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(doc['full_name']),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => selectedManagerId = val),
                );
              },
            ),
            ElevatedButton(
              onPressed: linkManagerToBranch,
              child: const Text("Link Manager"),
            ),
          ],
        ),
      ),
    );
  }
}
