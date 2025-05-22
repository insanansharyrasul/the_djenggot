import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/models/order.dart';
import 'package:the_djenggot/services/firestore_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final WAOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String currentStatus;
  final FirestoreService _firestoreService = FirestoreService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    currentStatus = widget.order.status;
  }

  Future<void> _updateOrderStatus(String newStatus) async {
    setState(() {
      isLoading = true;
    });

    try {
      await _firestoreService.updateDocument(
        'orders',
        widget.order.id,
        {'status': newStatus},
      );

      setState(() {
        currentStatus = newStatus;
        widget.order.status = newStatus;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status pesanan diubah ke $newStatus'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildStatusSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informasi Pesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoItem('Nama', widget.order.nama),
            _buildInfoItem('No. Telepon', widget.order.phoneNumber),
            _buildInfoItem('Pesanan', widget.order.makanan),
            _buildInfoItem('Pembayaran', widget.order.pembayaran),
            _buildInfoItem('Waktu', dateFormat.format(widget.order.timestamp)),
            _buildInfoItem('Status', widget.order.status),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Update Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            _buildStatusButton(
              'Pending',
              currentStatus == 'Pending',
              Colors.amber,
            ),
            const SizedBox(height: 12),
            _buildStatusButton(
              'On work',
              currentStatus == 'On work',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildStatusButton(
              'Selesai!',
              currentStatus == 'Selesai!',
              Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusButton(String status, bool isSelected, Color color) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: isSelected ? null : () => _updateOrderStatus(status),
        style: OutlinedButton.styleFrom(
          backgroundColor: isSelected ? color.withOpacity(0.2) : null,
          side: BorderSide(
            color: isSelected ? color : Colors.grey,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isSelected ? color : Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
