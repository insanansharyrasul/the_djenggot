import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/repository/stock_repository.dart';
import 'package:uuid/uuid.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final StockRepository _stockRepository;
  List<Stock> _cachedStocks = [];
  StockBloc(this._stockRepository) : super(StockLoading()) {
    on<LoadStock>((event, emit) async {
      emit(StockLoading());
      _cachedStocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(_cachedStocks));
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
      _cachedStocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(_cachedStocks));
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
      _cachedStocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(_cachedStocks));
    });

    on<DeleteStock>((event, emit) async {
      await _stockRepository.deleteStok(event.id);
      _cachedStocks = await _stockRepository.getAllStocks();
      emit(StockLoaded(_cachedStocks));
    });

    on<SearchStock>((event, emit) async {
      _cachedStocks = await _stockRepository.searchStocks(event.query);
      emit(StockLoaded(_cachedStocks));
    });
  }
}
