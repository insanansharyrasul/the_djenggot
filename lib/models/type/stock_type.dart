import 'package:equatable/equatable.dart';

class StockType extends Equatable {
  final String idStockType;
  final String stockName;
  final String? stockIcon;

  const StockType({required this.idStockType, required this.stockName, this.stockIcon});

  factory StockType.fromMap(Map<String, dynamic> map) {
    return StockType(
      idStockType: map['id_stock_type'],
      stockName: map['stock_name'],
      stockIcon: map['stock_icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_stock_type': idStockType,
      'stock_name': stockName,
      'stock_icon': stockIcon,
    };
  }

  @override
  List<Object?> get props => [idStockType, stockName, stockIcon];
}
