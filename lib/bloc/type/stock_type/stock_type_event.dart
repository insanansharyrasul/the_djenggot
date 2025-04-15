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
  final String? icon;

  const AddStockType(this.name, {this.icon});

  @override
  List<Object?> get props => [name, icon];
}

class UpdateStockType extends StockTypeEvent {
  final StockType stockType;
  final String newName;
  final String? icon;

  const UpdateStockType(this.stockType, this.newName, {this.icon});

  @override
  List<Object?> get props => [stockType, newName, icon];
}

class DeleteStockType extends StockTypeEvent {
  final String id;

  const DeleteStockType(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchStockTypes extends StockTypeEvent {
  final String query;

  const SearchStockTypes(this.query);

  @override
  List<Object?> get props => [query];
}
