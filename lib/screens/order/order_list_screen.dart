import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/models/order.dart';
import 'package:the_djenggot/screens/order/order_detail_screen.dart';
import 'package:the_djenggot/services/firestore_service.dart';
import 'package:the_djenggot/services/notification_service.dart';
import 'package:the_djenggot/utils/test_order_generator.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final NotificationService _notificationService = NotificationService();
  final TestOrderGenerator _testOrderGenerator = TestOrderGenerator();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle),
            tooltip: 'Generate Test Order',
            onPressed: () async {
              await _testOrderGenerator.generateTestOrder();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Test order generated')));
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Test Notification',
            onPressed: () {
              _notificationService.showNewOrderNotification(
                  customerName: "Test Customer", orderItems: "Test Order Item");
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _firestoreService.streamCollection('orders'),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
        
            if (snapshot.hasError) {
              return Center(
                child:
                    Text('Error: ${snapshot.error}', style: const TextStyle(color: AppTheme.danger)),
              );
            }
        
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Tidak ada pesanan', style: TextStyle(fontSize: 16)),
              );
            }
        
            final orders = snapshot.data!.map((data) => WAOrder.fromMap(data)).toList();
        
            orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
        
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      order.nama,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          order.phoneNumber,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateFormat.format(order.timestamp),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildStatusBadge(order.status),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderDetailScreen(order: order),
                        ),
                      ).then((_) {
                        // Refresh the list when coming back from details
                        setState(() {});
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color badgeColor;

    switch (status) {
      case 'Pending':
        badgeColor = Colors.amber;
        break;
      case 'On work':
        badgeColor = Colors.blue;
        break;
      case 'Selesai!':
      case 'Finished':
        badgeColor = Colors.green;
        break;
      default:
        badgeColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 51),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: badgeColor),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: badgeColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}
