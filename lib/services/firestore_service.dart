import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:the_djenggot/services/notification_service.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(collection).doc(docId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting document: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getCollection(String collection) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection(collection).get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      debugPrint('Error getting collection: $e');
      return [];
    }
  }

  Stream<List<Map<String, dynamic>>> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  Future<String?> addDocument(String collection, Map<String, dynamic> data) async {
    try {
      DocumentReference doc = await _firestore.collection(collection).add(data);
      return doc.id;
    } catch (e) {
      debugPrint('Error adding document: $e');
      return null;
    }
  }

  Future<bool> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(collection).doc(docId).update(data);
      return true;
    } catch (e) {
      debugPrint('Error updating document: $e');
      return false;
    }
  }

  Future<bool> deleteDocument(String collection, String docId) async {
    try {
      await _firestore.collection(collection).doc(docId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting document: $e');
      return false;
    }
  }

  Stream<int> streamPendingOrdersCount() {
    return _firestore
        .collection('orders')
        .where('status', isEqualTo: 'Pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  void listenForNewOrders() {
    DateTime lastCheckTime = DateTime.now();

    _firestore
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data() as Map<String, dynamic>;

          final timestampData = data['timestamp'];
          if (timestampData != null) {
            final timestamp = (timestampData as Timestamp).toDate();
            if (timestamp.isAfter(lastCheckTime)) {
              final customerName = data['nama'] ?? 'Customer';
              final orderItems = data['makanan'] ?? 'New order';

              _notificationService.showNewOrderNotification(
                customerName: customerName,
                orderItems: orderItems,
              );
            }
          } else {
            final customerName = data['nama'] ?? 'Customer';
            final orderItems = data['makanan'] ?? 'New order';

            _notificationService.showNewOrderNotification(
              customerName: customerName,
              orderItems: orderItems,
            );

            debugPrint('Warning: Document ${docChange.doc.id} has no timestamp');
          }
        }
      }
      lastCheckTime = DateTime.now();
    });
  }
}
