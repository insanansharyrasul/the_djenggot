import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/stock/stock_history.dart';
import 'package:the_djenggot/repository/stock_repository.dart';

class StockHistoryRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  final StockRepository _stockRepository = StockRepository();

  // Record a stock history entry
  Future<int> recordStockHistory(String stockId, int amount, String actionType) async {
    final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    final stockHistoryId = const Uuid().v4();

    // Get the stock to calculate the total price
    final stock = await _stockRepository.getStockById(stockId);
    final int totalPrice = stock!.price * amount;

    final stockHistory = StockHistory(
      stockHistoryId: stockHistoryId,
      timestamp: timestamp,
      idStock: stockId,
      amount: amount,
      actionType: actionType,
      totalPrice: totalPrice,
    );

    return await _databaseHelper.insertQuery(
      'STOCK_HISTORY',
      stockHistory.toMap(),
    );
  }

  // Get all stock history entries
  Future<List<StockHistory>> getAllStockHistory() async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getAllQuery('STOCK_HISTORY', '', []);

    return maps.map((map) => StockHistory.fromMap(map)).toList();
  }

  // Get stock history with related stock data
  Future<List<StockHistory>> getStockHistoryWithStockDetails() async {
    final db = await _databaseHelper.db;
    final results = await db.rawQuery('''
      SELECT sh.stock_history_id, sh.timestamp, sh.id_stock, sh.amount, sh.action_type, sh.total_price,
             s.stock_name, s.stock_quantity, s.id_stock_type, s.stock_threshold, s.price
      FROM STOCK_HISTORY sh
      JOIN STOCK s ON sh.id_stock = s.id_stock
      ORDER BY sh.timestamp DESC
    ''');

    return await Future.wait(results.map((map) async {
      final stockTypeId = map['id_stock_type'];
      final stockType = await _stockRepository.getStockTypeForId(stockTypeId as String);

      final stock = Stock(
        idStock: map['id_stock'] as String,
        stockName: map['stock_name'] as String,
        stockQuantity: int.parse(map['stock_quantity'].toString()),
        stockThreshold:
            map['stock_threshold'] != null ? int.parse(map['stock_threshold'].toString()) : null,
        idStockType: stockType,
        price: map['price'] != null ? int.parse(map['price'].toString()) : 0,
      );

      return StockHistory(
        stockHistoryId: map['stock_history_id'] as String,
        timestamp: map['timestamp'] as String,
        idStock: map['id_stock'] as String,
        amount: int.parse(map['amount'].toString()),
        actionType: map['action_type'] as String,
        totalPrice: map['total_price'] != null ? int.parse(map['total_price'].toString()) : 0,
        stock: stock,
      );
    }));
  }

  // Get stock history for a specific stock
  Future<List<StockHistory>> getStockHistoryForStock(String stockId) async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getAllQuery('STOCK_HISTORY', 'id_stock = ?', [stockId]);

    return maps.map((map) => StockHistory.fromMap(map)).toList();
  }
}
