import 'package:cloud_firestore/cloud_firestore.dart';

// used once to backfill created_at field for existing users
Future<void> backfillCreatedAt() async {
  final firestore = FirebaseFirestore.instance;

  final snapshot = await firestore.collection('users').get();

  for (var doc in snapshot.docs) {
    final data = doc.data();

    if (data['created_at'] == null) {
      await firestore.collection('users').doc(doc.id).update({
        'created_at': FieldValue.serverTimestamp(),
      });
      print("✅ Updated ${doc.id} with created_at");
    } else {
      print("⏭️ Skipped ${doc.id}, already has created_at");
    }
  }

  print("🎉 Backfill complete");
}
