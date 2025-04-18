import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_state.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/repository/type/stock_type_repository.dart';
import 'package:uuid/uuid.dart';

class StockTypeBloc extends Bloc<StockTypeEvent, StockTypeState> {
  final StockTypeRepository stockTypeRepository;

  StockTypeBloc({required this.stockTypeRepository}) : super(StockTypeInitial()) {
    on<LoadStockTypes>(_onLoadStockTypes);
    on<AddStockType>(_onAddStockType);
    on<UpdateStockType>(_onUpdateStockType);
    on<DeleteStockType>(_onDeleteStockType);
  }

  Future<void> _onLoadStockTypes(LoadStockTypes event, Emitter<StockTypeState> emit) async {
    emit(StockTypeLoading());
    try {
      final stockTypes = await stockTypeRepository.getAllStockTypes();
      emit(StockTypeLoaded(stockTypes));
    } catch (e) {
      emit(StockTypeError(e.toString()));
    }
  }

  Future<void> _onAddStockType(AddStockType event, Emitter<StockTypeState> emit) async {
    final currentState = state;
    try {
      final stockTypeId = const Uuid().v4();
      final stockType = StockType(
        idStockType: stockTypeId,
        stockTypeName: event.name,
        stockTypeIcon: event.icon,
        stockUnit: event.unit,
      );

      await stockTypeRepository.addStockType(stockType);

      if (currentState is StockTypeLoaded) {
        emit(StockTypeLoaded([...currentState.stockTypes, stockType]));
      }
    } catch (e) {
      emit(StockTypeError(e.toString()));
    }
  }

  Future<void> _onUpdateStockType(UpdateStockType event, Emitter<StockTypeState> emit) async {
    final currentState = state;
    try {
      final updatedStockType = StockType(
        idStockType: event.stockType.idStockType,
        stockTypeName: event.name,
        stockTypeIcon: event.icon,
        stockUnit: event.unit,
      );

      await stockTypeRepository.updateStockType(
        updatedStockType,
      );

      if (currentState is StockTypeLoaded) {
        final updatedStockTypes = currentState.stockTypes.map((stockType) {
          return stockType.idStockType == event.stockType.idStockType
              ? updatedStockType
              : stockType;
        }).toList();

        emit(StockTypeLoaded(updatedStockTypes));
      }
    } catch (e) {
      emit(StockTypeError(e.toString()));
    }
  }

  Future<void> _onDeleteStockType(DeleteStockType event, Emitter<StockTypeState> emit) async {
    final currentState = state;
    try {
      await stockTypeRepository.deleteStockType(event.stockType.idStockType);

      if (currentState is StockTypeLoaded) {
        final filteredStockTypes = currentState.stockTypes
            .where((stockType) => stockType.idStockType != event.stockType.idStockType)
            .toList();

        emit(StockTypeLoaded(filteredStockTypes));
      }
    } catch (e) {
      emit(StockTypeError(e.toString()));
    }
  }
}
