import 'package:equatable/equatable.dart';

abstract class StockHistoryEvent extends Equatable {
  const StockHistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadStockHistory extends StockHistoryEvent {}

class FilterStockHistory extends StockHistoryEvent {
  final String stockId;

  const FilterStockHistory(this.stockId);

  @override
  List<Object> get props => [stockId];
}
