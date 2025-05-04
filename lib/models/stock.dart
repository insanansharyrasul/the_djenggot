import 'package:the_djenggot/models/type/stock_type.dart';

class Stock {
  final String idStock;
  final String stockName;
  final int stockQuantity;
  final StockType idStockType;
  final int? stockThreshold;
  final int price; 

  Stock({
    required this.idStock,
    required this.stockName,
    required this.stockQuantity,
    required this.idStockType,
    this.stockThreshold,
    this.price = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_stock': idStock,
      'stock_name': stockName,
      'stock_quantity': stockQuantity,
      'id_stock_type': idStockType.idStockType,
      'stock_threshold': stockThreshold ?? 0,
      'price': price,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      idStock: map['id_stock'],
      stockName: map['stock_name'],
      stockQuantity: int.parse(map['stock_quantity'].toString()),
      idStockType: StockType.fromMap(map['id_stock_type']),
      stockThreshold:
          map['stock_threshold'] != null ? int.parse(map['stock_threshold'].toString()) : 0,
      price: map['price'] != null ? int.parse(map['price'].toString()) : 0,
    );
  }
}
