import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:uuid/uuid.dart';

part 'stock_event.dart';
part 'stock_state.dart';

class StockBloc extends Bloc<StockEvent, StockState> {
  final DatabaseHelper _database;
  StockBloc(this._database) : super(StockLoading()) {
    on<LoadStock>((event, emit) async {
      emit(StockLoading());
      final stocks = await _database.getAllStocks();
      emit(StockLoaded(stocks));
    });

    on<AddStock>((event, emit) async {
      final String uniqueId = const Uuid().v4();
      await _database.insertQuery(
        'stok',
        {
          'id': uniqueId,
          'name': event.stockName,
          'quantity': event.stockQuantity,
        },
      );
      final stocks = await _database.getAllStocks();
      emit(StockLoaded(stocks));
    });
  }

}
