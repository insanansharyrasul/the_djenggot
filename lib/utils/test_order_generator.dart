import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class TestOrderGenerator {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> generateTestOrder() async {
    try {
      await _firestore.collection('orders').add({
        'makanan': 'Test Makanan',
        'nama': 'Test Customer',
        'pembayaran': 'Cash',
        'phoneNumber': '+628123456789',
        'status': 'Pending',
        'timestamp': FieldValue.serverTimestamp(),
      });

      debugPrint('Test order generated successfully');
    } catch (e) {
      debugPrint('Error generating test order: $e');
    }
  }
}
