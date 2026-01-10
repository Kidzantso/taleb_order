import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> migrateItemsAndBranchMenus() async {
  final firestore = FirebaseFirestore.instance;

  // Normalize items
  final itemsSnapshot = await firestore.collection('items').get();
  for (var doc in itemsSnapshot.docs) {
    final data = doc.data();
    final updates = <String, dynamic>{};

    if (data['is_active'] == null) updates['is_active'] = true;
    if (data['created_at'] == null)
      updates['created_at'] = FieldValue.serverTimestamp();
    if (data['created_by'] == null) updates['created_by'] = "system";

    if (updates.isNotEmpty) {
      await firestore.collection('items').doc(doc.id).update(updates);
      print("✅ Updated item ${doc.id}");
    }
  }

  // Backfill branch menus
  final branchesSnapshot = await firestore.collection('branches').get();
  for (var branchDoc in branchesSnapshot.docs) {
    final branchId = branchDoc.id;
    for (var itemDoc in itemsSnapshot.docs) {
      final itemData = itemDoc.data();
      final branchMenuRef = firestore
          .collection('branch_menus')
          .doc(branchId)
          .collection('items')
          .doc(itemDoc.id);

      final branchMenuDoc = await branchMenuRef.get();
      if (!branchMenuDoc.exists) {
        await branchMenuRef.set({
          'item_id': itemDoc.id,
          'name': itemData['item_name'],
          'price': itemData['item_price'],
          'is_available': true,
          'category': itemData['item_category'],
          'photo_url': itemData['item_photo'],
          'added_at': FieldValue.serverTimestamp(),
          'added_by': "system",
        });
        print("✅ Added ${itemData['item_name']} to branch $branchId");
      }
    }
  }

  print("🎉 Migration complete");
}
