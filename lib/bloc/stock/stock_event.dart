part of 'stock_bloc.dart';

abstract class StockEvent {}

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
  final String newName;
  final String newQuantity;
  UpdateStock(this.stock, this.newName, this.newQuantity);
}

class DeleteStock extends StockEvent {
  final String id;
  DeleteStock(this.id);
}
