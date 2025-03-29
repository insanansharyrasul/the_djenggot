part of 'stock_bloc.dart';

@immutable
sealed class StockEvent {}

class LoadStock extends StockEvent {}

class AddStock extends StockEvent {
  // final Stock stock;
  final String stockName;
  final int stockQuantity;
  AddStock({
    required this.stockName,
    required this.stockQuantity,
  });
}

class UpdateStock extends StockEvent {
  final Stock stock;
  UpdateStock(this.stock);
}

class DeleteStock extends StockEvent {
  final String id;
  DeleteStock(this.id);
}
