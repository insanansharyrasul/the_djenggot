import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_state.dart';
import 'package:the_djenggot/repository/type/stock_type_repository.dart';

class StockTypeBloc extends Bloc<StockTypeEvent, StockTypeState> {
  final StockTypeRepository _repository;

  StockTypeBloc(this._repository) : super(StockTypeLoading()) {
    on<LoadStockTypes>((event, emit) async {
      emit(StockTypeLoading());
      try {
        final stockTypes = await _repository.getAllStockTypes();
        emit(StockTypeLoaded(stockTypes));
      } catch (e) {
        emit(StockTypeError(e.toString()));
      }
    });

    on<AddStockType>((event, emit) async {
      try {
        await _repository.addStockType(event.name);
        final stockTypes = await _repository.getAllStockTypes();
        emit(StockTypeLoaded(stockTypes));
      } catch (e) {
        emit(StockTypeError(e.toString()));
      }
    });

    on<UpdateStockType>((event, emit) async {
      try {
        await _repository.updateStockType(event.stockType, event.newName);
        final stockTypes = await _repository.getAllStockTypes();
        emit(StockTypeLoaded(stockTypes));
      } catch (e) {
        emit(StockTypeError(e.toString()));
      }
    });

    on<DeleteStockType>((event, emit) async {
      try {
        await _repository.deleteStockType(event.id);
        final stockTypes = await _repository.getAllStockTypes();
        emit(StockTypeLoaded(stockTypes));
      } catch (e) {
        emit(StockTypeError(e.toString()));
      }
    });

    on<SearchStockTypes>((event, emit) async {
      try {
        final stockTypes = await _repository.searchStockTypes(event.query);
        emit(StockTypeLoaded(stockTypes));
      } catch (e) {
        emit(StockTypeError(e.toString()));
      }
    });
  }
}
