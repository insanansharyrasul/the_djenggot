import 'package:equatable/equatable.dart';

class StockType extends Equatable {
  final String idStockType;
  final String stockTypeName;
  final String stockTypeIcon;
  final String stockUnit;

  const StockType({
    required this.idStockType,
    required this.stockTypeName,
    required this.stockTypeIcon,
    required this.stockUnit,
  });

  factory StockType.fromMap(Map<String, dynamic> map) {
    return StockType(
      idStockType: map['id_stock_type'],
      stockTypeName: map['stock_type_name'],
      stockTypeIcon: map['stock_type_icon'],
      stockUnit: map['stock_unit'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_stock_type': idStockType,
      'stock_type_name': stockTypeName,
      'stock_type_icon': stockTypeIcon,
      'stock_unit': stockUnit,
    };
  }

  @override
  List<Object?> get props => [idStockType, stockTypeName, stockTypeIcon, stockUnit];
}
