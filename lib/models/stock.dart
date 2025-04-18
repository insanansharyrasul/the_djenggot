import 'package:the_djenggot/models/type/stock_type.dart';

class Stock {
  final String idStock;
  final String stockName;
  final int stockQuantity;
  final StockType idStockType;
  final int? stockThreshold;

  Stock({
    required this.idStock,
    required this.stockName,
    required this.stockQuantity,
    required this.idStockType,
    this.stockThreshold,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_stock': idStock,
      'stock_name': stockName,
      'stock_quantity': stockQuantity,
      'id_stock_type': idStockType.idStockType,
      'stock_threshold': stockThreshold ?? 0,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      idStock: map['id_stock'],
      stockName: map['stock_name'],
      stockQuantity: int.parse(map['stock_quantity'].toString()),
      idStockType: map['id_stock_type'] is Map
          ? StockType.fromMap(map['id_stock_type'])
          : StockType(
              idStockType: map['id_stock_type'],
              stockTypeName: '',
              stockTypeIcon: '',
            ),
      stockThreshold:
          map['stock_threshold'] != null ? int.parse(map['stock_threshold'].toString()) : 0,
    );
  }
}
