import 'package:the_djenggot/models/stock.dart';

class StockHistory {
  final String stockHistoryId;
  final String timestamp;
  final String idStock;
  final int amount;
  final String actionType;
  final int totalPrice; // Total price for this stock history entry

  // Optional property to hold the related stock object when needed
  final Stock? stock;

  StockHistory({
    required this.stockHistoryId,
    required this.timestamp,
    required this.idStock,
    required this.amount,
    required this.actionType,
    this.totalPrice = 0,
    this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'stock_history_id': stockHistoryId,
      'timestamp': timestamp,
      'id_stock': idStock,
      'amount': amount,
      'action_type': actionType,
      'total_price': totalPrice,
    };
  }

  factory StockHistory.fromMap(Map<String, dynamic> map) {
    return StockHistory(
      stockHistoryId: map['stock_history_id'],
      timestamp: map['timestamp'],
      idStock: map['id_stock'],
      amount: int.parse(map['amount'].toString()),
      actionType: map['action_type'],
      totalPrice: map['total_price'] != null ? int.parse(map['total_price'].toString()) : 0,
    );
  }
}
