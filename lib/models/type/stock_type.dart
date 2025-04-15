import 'package:equatable/equatable.dart';

class StockType extends Equatable {
  final String id;
  final String name;

  const StockType({required this.id, required this.name});

  factory StockType.fromMap(Map<String, dynamic> map) {
    return StockType(
      id: map['id_stock_type'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_stock_type': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
