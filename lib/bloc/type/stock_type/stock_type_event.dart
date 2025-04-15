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

  const AddStockType(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateStockType extends StockTypeEvent {
  final StockType stockType;
  final String newName;

  const UpdateStockType(this.stockType, this.newName);

  @override
  List<Object?> get props => [stockType, newName];
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
