import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/stock/stock_history.dart';

abstract class StockHistoryState extends Equatable {
  const StockHistoryState();

  @override
  List<Object> get props => [];
}

class StockHistoryInitial extends StockHistoryState {}

class StockHistoryLoading extends StockHistoryState {}

class StockHistoryLoaded extends StockHistoryState {
  final List<StockHistory> stockHistories;

  const StockHistoryLoaded(this.stockHistories);

  @override
  List<Object> get props => [stockHistories];
}

class StockHistoryError extends StockHistoryState {
  final String message;

  const StockHistoryError(this.message);

  @override
  List<Object> get props => [message];
}
