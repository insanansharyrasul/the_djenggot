import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/repository/stock_repository.dart';
import 'package:uuid/uuid.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository _stockRepository;
  StockBloc(this._stockRepository) : super(StockLoading()) {
    on<LoadStock>((event, emit) async {
      emit(StockLoading());
      final stocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(stocks));
    });

    on<AddStock>((event, emit) async {
      final String uniqueId = "stok-${const Uuid().v4()}";
      await _stockRepository.addStok(
        {
          'id_stock': uniqueId,
          'stock_name': event.stockName,
          'stock_quantity': event.stockQuantity,
          'id_stock_type': event.stockType!.idStockType,
          'stock_threshold': event.threshold,
        },
      );
      final stocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(stocks));
    });

    on<UpdateStock>((event, emit) async {
      await _stockRepository.updateStok(
        {
          'stock_name': event.newName,
          'stock_quantity': event.newQuantity,
          'id_stock_type': event.newStockType,
          'stock_threshold': event.threshold,
        },
        event.stock.idStock,
      );
      final stocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(stocks));
    });

    on<DeleteStock>((event, emit) async {
      await _stockRepository.deleteStok(event.id);
      final stocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(stocks));
    });

    on<SearchStock>((event, emit) async {
      final stocks = await _stockRepository.searchStocks(event.query);
      emit(StockLoaded(stocks));
    });
  }
}
