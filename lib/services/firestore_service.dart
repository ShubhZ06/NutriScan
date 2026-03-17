import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add scan to history using a normalized payload that is Firestore-safe.
  Future<void> addScan(Map<String, dynamic> product) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final scanDoc = _buildScanDocument(product);

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .collection('scan_history')
          .add({
        ...scanDoc,
        'scan_timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error adding scan: $e');
      rethrow;
    }
  }

  Map<String, dynamic> _buildScanDocument(Map<String, dynamic> product) {
    return {
      'code': _asString(product['code']),
      'product_name': _asString(product['product_name']),
      'brands': _asString(product['brands']),
      'image_url': _asString(product['image_url']),
      'ingredients_text': _asString(product['ingredients_text']),
      'allergens': _asString(product['allergens']),
      'packaging': _asString(product['packaging']),
      'recommendations': _asString(product['recommendations']),
      'nutriments': _buildNutriments(product['nutriments']),
    };
  }

  Map<String, dynamic> _buildNutriments(dynamic rawNutriments) {
    if (rawNutriments is! Map) {
      return const {};
    }

    return {
      'energy': _safePrimitive(rawNutriments['energy']),
      'fat': _safePrimitive(rawNutriments['fat']),
      'carbohydrates': _safePrimitive(rawNutriments['carbohydrates']),
      'proteins': _safePrimitive(rawNutriments['proteins']),
    };
  }

  dynamic _safePrimitive(dynamic value) {
    if (value == null) return null;
    if (value is num || value is bool || value is String) return value;
    return value.toString();
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    return value.toString();
  }

  // Get scan history stream
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

  // Clear history
  Future<void> clearHistory() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _db.batch();
    final snapshots = await _db
        .collection('users')
        .doc(user.uid)
        .collection('scan_history')
        .get();

    for (final doc in snapshots.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
