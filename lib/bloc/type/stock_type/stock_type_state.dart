import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/type/stock_type.dart';

abstract class StockTypeState extends Equatable {
  const StockTypeState();

  @override
  List<Object?> get props => [];
}

class StockTypeLoading extends StockTypeState {}

class StockTypeLoaded extends StockTypeState {
  final List<StockType> stockTypes;

  const StockTypeLoaded(this.stockTypes);

  @override
  List<Object?> get props => [stockTypes];
}

class StockTypeError extends StockTypeState {
  final String message;

  const StockTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
