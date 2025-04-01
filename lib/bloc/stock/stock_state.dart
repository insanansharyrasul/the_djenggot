part of 'stock_bloc.dart';

abstract class StockState {}

final class StockLoading extends StockState {}

final class StockLoaded extends StockState {
  final List<Stock> stocks;
  StockLoaded(this.stocks);
}

