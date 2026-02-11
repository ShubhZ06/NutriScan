import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add Scan to History
  Future<void> addScan(Map<String, dynamic> product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('scan_history')
          .add({
        ...product,
        'scan_timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding scan: $e');
      throw e;
    }
  }

  // Get Scan History Stream
  Stream<QuerySnapshot> getScanHistory() {
    final user = _auth.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('scan_history')
        .orderBy('scan_timestamp', descending: true)
        .snapshots();
  }

  // Clear History
  Future<void> clearHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    var snapshots = await _db
        .collection('users')
        .doc(user.uid)
        .collection('scan_history')
        .get();

    for (var doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
