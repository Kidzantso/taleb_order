import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuItemsPage extends StatelessWidget {
  final String branchId;
  const MenuItemsPage({super.key, required this.branchId});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    Future<void> toggleItem(DocumentSnapshot item) async {
      final itemId = item.id;
      final data = item.data() as Map<String, dynamic>;
      final branchItemRef = firestore
          .collection('branch_menus')
          .doc(branchId)
          .collection('items')
          .doc(itemId);

      final branchItemDoc = await branchItemRef.get();

      if (branchItemDoc.exists) {
        // Remove item from branch menu
        await branchItemRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Removed ${data['item_name']} from branch menu"),
          ),
        );
      } else {
        // Add item to branch menu
        await branchItemRef.set({
          'item_id': itemId,
          'name': data['item_name'],
          'price': data['item_price'],
          'is_available': true,
          'category': data['item_category'],
          'photo_url': data['item_photo'],
          'added_at': FieldValue.serverTimestamp(),
          'added_by': FirebaseAuth.instance.currentUser!.uid,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Added ${data['item_name']} to branch menu")),
        );
      }
    }

    Future<void> toggleAvailability(String itemId, bool current) async {
      final branchItemRef = firestore
          .collection('branch_menus')
          .doc(branchId)
          .collection('items')
          .doc(itemId);
      await branchItemRef.update({'is_available': !current});
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Manage Branch Menu")),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('items').snapshots(),
        builder: (context, globalSnapshot) {
          if (globalSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!globalSnapshot.hasData || globalSnapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No items in global catalog"));
          }

          final globalItems = globalSnapshot.data!.docs;

          return StreamBuilder<QuerySnapshot>(
            stream: firestore
                .collection('branch_menus')
                .doc(branchId)
                .collection('items')
                .snapshots(),
            builder: (context, branchSnapshot) {
              if (!branchSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final branchItems = {
                for (var doc in branchSnapshot.data!.docs) doc.id: doc,
              };

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: globalItems.length,
                itemBuilder: (context, index) {
                  final item = globalItems[index];
                  final data = item.data() as Map<String, dynamic>;
                  final branchItemDoc = branchItems[item.id];

                  final isInBranch = branchItemDoc != null;
                  final isAvailable =
                      branchItemDoc?.get('is_available') ?? false;

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading:
                          (data['item_photo'] != null &&
                              data['item_photo'].toString().isNotEmpty)
                          ? Image.network(
                              data['item_photo'],
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.fastfood, size: 40),
                      title: Text(data['item_name']),
                      subtitle: Text(
                        "${data['item_category']} • \$${data['item_price']}\n${data['item_description']}",
                      ),
                      isThreeLine: true,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              isInBranch ? Icons.remove : Icons.add,
                              color: isInBranch ? Colors.red : Colors.green,
                            ),
                            onPressed: () => toggleItem(item),
                          ),
                          if (isInBranch)
                            IconButton(
                              icon: Icon(
                                isAvailable
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: isAvailable ? Colors.blue : Colors.grey,
                              ),
                              onPressed: () =>
                                  toggleAvailability(item.id, isAvailable),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
