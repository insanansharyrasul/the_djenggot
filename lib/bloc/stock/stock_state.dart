part of 'stock_bloc.dart';

@immutable
sealed class StockState {}

final class StockLoading extends StockState {}

final class StockLoaded extends StockState {
  final List<Stock> stocks;
  StockLoaded(this.stocks);
}

