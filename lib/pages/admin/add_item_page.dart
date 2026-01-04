import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/custom_widget.dart';
import '../../utils/validators.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

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
  File? _localImageFile; // preview before upload
  String? _imageUrl; // final Supabase URL

  final List<String> categories = [
    "appetizers",
    "soups",
    "breakfast",
    "launch",
    "fast-food",
    "desserts",
    "hot-drinks",
    "cold-beverages",
  ];

  /// Pick image locally (no upload yet)
  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _localImageFile = File(pickedFile.path);
      });
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

      // ✅ Success can be "" or "bucketName/fileName"
      if (response == "" || response.contains(fileName)) {
        final publicUrl = Supabase.instance.client.storage
            .from('food-images')
            .getPublicUrl(fileName);
        print("Public URL: $publicUrl");
        return publicUrl;
      } else {
        print("Unexpected upload response: $response");
        return null;
      }
    } catch (e) {
      print("Upload error: $e");
      return null;
    }
  }

  Future<void> addItem() async {
    if (!validateField(context, _nameController.text, "Item Name") ||
        !validateField(context, _priceController.text, "Item Price") ||
        !validateField(
          context,
          _descriptionController.text,
          "Item Description",
        ) ||
        _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields and select a category"),
        ),
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

    // ✅ Firestore will now save the correct URL
    await _firestore.collection('items').add({
      'item_name': _nameController.text.trim(),
      'item_price': double.tryParse(_priceController.text.trim()) ?? 0,
      'item_description': _descriptionController.text.trim(),
      'item_category': _selectedCategory,
      'item_photo': _imageUrl,
    });

    print("Item saved in Firestore with ID: $_imageUrl");
    // After Firestore write
    _nameController.clear();
    _priceController.clear();
    _descriptionController.clear();

    setState(() {
      _localImageFile = null; // clear preview
      _imageUrl = null; // clear Supabase URL
      _selectedCategory = null; // reset dropdown
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Item added successfully")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Item")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            customTextField(_nameController, "Item Name"),
            customTextField(_priceController, "Item Price"),
            customTextField(_descriptionController, "Item Description"),

            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text("Select Category"),
              items: categories.map((cat) {
                return DropdownMenuItem(value: cat, child: Text(cat));
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategory = val),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF8E9F2),
              ),
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: pickImage,
              child: const Text("Choose Item Image"),
            ),

            if (_localImageFile != null) ...[
              const SizedBox(height: 10),
              const Text(
                "Preview:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  _localImageFile!,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(onPressed: addItem, child: const Text("Add Item")),
          ],
        ),
      ),
    );
  }
}
