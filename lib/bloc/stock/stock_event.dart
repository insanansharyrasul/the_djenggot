part of 'stock_bloc.dart';

abstract class StockEvent {}

class LoadStock extends StockEvent {}

class AddStock extends StockEvent {
  final String stockName;
  final int stockQuantity;
  final StockType? stockType;
  final int threshold;
  final int price;
  AddStock({
    required this.stockName,
    required this.stockQuantity,
    required this.stockType,
    required this.threshold,
    required this.price,
  });
}

class UpdateStock extends StockEvent {
  final Stock stock;
  final String newName;
  final String newQuantity;
  final String newStockType;
  final int threshold;
  final int price;
  UpdateStock(
    this.stock,
    this.newName,
    this.newQuantity,
    this.newStockType,
    this.threshold,
    this.price,
  );
}

class DeleteStock extends StockEvent {
  final String id;
  DeleteStock(this.id);
}

class SearchStock extends StockEvent {
  final String query;
  SearchStock(this.query);
}
