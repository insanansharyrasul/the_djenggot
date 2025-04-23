import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/type/stock_type.dart';

abstract class StockTypeEvent extends Equatable {
  const StockTypeEvent();

  @override
  List<Object?> get props => [];
}

class LoadStockTypes extends StockTypeEvent {}

class AddStockType extends StockTypeEvent {
  final String name;
  final String icon;
  final String unit;

  const AddStockType(this.name, this.icon, this.unit);

  @override
  List<Object?> get props => [name, icon, unit];
}

class UpdateStockType extends StockTypeEvent {
  final StockType stockType;
  final String name;
  final String icon;
  final String unit;

  const UpdateStockType(this.stockType, this.name, this.icon, this.unit);

  @override
  List<Object?> get props => [stockType, name, icon, unit];
}

class DeleteStockType extends StockTypeEvent {
  final StockType stockType;

  const DeleteStockType(this.stockType);

  @override
  List<Object?> get props => [stockType];
}
