import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_event.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_state.dart';
import 'package:the_djenggot/models/stock/stock_history.dart';
import 'package:the_djenggot/repository/stock/stock_history_repository.dart';

class StockHistoryBloc extends Bloc<StockHistoryEvent, StockHistoryState> {
  final StockHistoryRepository _stockHistoryRepository;

  StockHistoryBloc({required StockHistoryRepository stockHistoryRepository})
      : _stockHistoryRepository = stockHistoryRepository,
        super(StockHistoryInitial()) {
    on<LoadStockHistory>(_onLoadStockHistory);
    on<FilterStockHistory>(_onFilterStockHistory);
  }

  Future<void> _onLoadStockHistory(LoadStockHistory event, Emitter<StockHistoryState> emit) async {
    emit(StockHistoryLoading());
    try {
      final List<StockHistory> stockHistories =
          await _stockHistoryRepository.getStockHistoryWithStockDetails();
      emit(StockHistoryLoaded(stockHistories));
    } catch (e) {
      emit(StockHistoryError(e.toString()));
    }
  }

  Future<void> _onFilterStockHistory(
      FilterStockHistory event, Emitter<StockHistoryState> emit) async {
    emit(StockHistoryLoading());
    try {
      final List<StockHistory> stockHistories =
          await _stockHistoryRepository.getStockHistoryForStock(event.stockId);
      emit(StockHistoryLoaded(stockHistories));
    } catch (e) {
      emit(StockHistoryError(e.toString()));
    }
  }
}
