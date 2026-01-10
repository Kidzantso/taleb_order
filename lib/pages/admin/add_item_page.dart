import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/custom_widget.dart';
import '../../utils/validators.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';

class AddItemPage extends StatefulWidget {
  const AddItemPage({super.key});

  @override
  State<AddItemPage> createState() => _AddItemPageState();
}

class _AddItemPageState extends State<AddItemPage> {
  final _firestore = FirebaseFirestore.instance;

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  File? _localImageFile;
  String? _imageUrl;

  List<String> _selectedBranchIds = [];
  bool _selectAllBranches = false;

  final List<String> categories = [
    "appetizers",
    "soups",
    "breakfast",
    "lunch",
    "fast-food",
    "desserts",
    "hot-drinks",
    "cold-beverages",
  ];

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _localImageFile = File(pickedFile.path));
    }
  }

  Future<String?> uploadImage(File file) async {
    final bytes = await file.readAsBytes();
    final uniqueId = const Uuid().v4();
    final fileName = "$uniqueId.jpg";
    try {
      final response = await Supabase.instance.client.storage
          .from('food-images')
          .uploadBinary(fileName, bytes);
      if (response == "" || response.contains(fileName)) {
        return Supabase.instance.client.storage
            .from('food-images')
            .getPublicUrl(fileName);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> addItem() async {
    if (_selectedBranchIds.isEmpty ||
        !validateField(context, _nameController.text, "Item Name") ||
        !validateField(context, _priceController.text, "Item Price") ||
        !validateField(
          context,
          _descriptionController.text,
          "Item Description",
        ) ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields and select branches")),
      );
      return;
    }

    if (_localImageFile != null) {
      _imageUrl = await uploadImage(_localImageFile!);
    }
    if (_imageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Image upload failed, item not saved")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Save global item
    final globalItemRef = await _firestore.collection('items').add({
      'item_name': _nameController.text.trim(),
      'item_price': double.tryParse(_priceController.text.trim()) ?? 0,
      'item_description': _descriptionController.text.trim(),
      'item_category': _selectedCategory,
      'item_photo': _imageUrl,
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
      'created_by': uid,
    });

    // Assign to selected branches
    for (var branchId in _selectedBranchIds) {
      await _firestore
          .collection('branch_menus')
          .doc(branchId)
          .collection('items')
          .doc(globalItemRef.id)
          .set({
            'item_id': globalItemRef.id,
            'name': _nameController.text.trim(),
            'price': double.tryParse(_priceController.text.trim()) ?? 0,
            'is_available': true,
            'category': _selectedCategory,
            'photo_url': _imageUrl,
            'added_at': FieldValue.serverTimestamp(),
            'added_by': uid,
          });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Item added to selected branches")),
    );

    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();
    setState(() {
      _localImageFile = null;
      _imageUrl = null;
      _selectedCategory = null;
      _selectedBranchIds = [];
      _selectAllBranches = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item to Branches")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            customTextField(_nameController, "Item Name"),
            customTextField(_priceController, "Item Price"),
            customTextField(_descriptionController, "Item Description"),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text("Select Category"),
              items: categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
            ),
            const SizedBox(height: 20),
            StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('branches').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final branches = snapshot.data!.docs;
                return Column(
                  children: [
                    CheckboxListTile(
                      title: const Text("Select All Branches"),
                      value: _selectAllBranches,
                      onChanged: (val) {
                        setState(() {
                          _selectAllBranches = val ?? false;
                          _selectedBranchIds = _selectAllBranches
                              ? branches.map((b) => b.id).toList()
                              : [];
                        });
                      },
                    ),
                    ...branches.map((doc) {
                      return CheckboxListTile(
                        title: Text(doc['branch_name']),
                        value: _selectedBranchIds.contains(doc.id),
                        onChanged: (val) {
                          setState(() {
                            if (val == true) {
                              _selectedBranchIds.add(doc.id);
                            } else {
                              _selectedBranchIds.remove(doc.id);
                              _selectAllBranches = false;
                            }
                          });
                        },
                      );
                    }),
                  ],
                );
              },
            ),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Choose Image"),
            ),
            ElevatedButton(onPressed: addItem, child: const Text("Add Item")),
          ],
        ),
      ),
    );
  }
}
