import 'package:cloud_firestore/cloud_firestore.dart';

class WAOrder {
  final String id;
  final String makanan;
  final String nama;
  final String pembayaran;
  final String phoneNumber;
  String status;
  final DateTime timestamp;

  WAOrder({
    required this.id,
    required this.makanan,
    required this.nama,
    required this.pembayaran,
    required this.phoneNumber,
    required this.status,
    required this.timestamp,
  });

  factory WAOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WAOrder(
      id: doc.id,
      makanan: data['makanan'] ?? '',
      nama: data['nama'] ?? '',
      pembayaran: data['pembayaran'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      status: data['status'] ?? 'Pending',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  factory WAOrder.fromMap(Map<String, dynamic> map) {
    return WAOrder(
      id: map['id'] ?? '',
      makanan: map['makanan'] ?? '',
      nama: map['nama'] ?? '',
      pembayaran: map['pembayaran'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      status: map['status'] ?? 'Pending',
      timestamp:
          map['timestamp'] is Timestamp ? (map['timestamp'] as Timestamp).toDate() : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'makanan': makanan,
      'nama': nama,
      'pembayaran': pembayaran,
      'phoneNumber': phoneNumber,
      'status': status,
      'timestamp': timestamp,
    };
  }
}
