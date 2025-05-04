import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/repository/stock/stock_history_repository.dart';
import 'package:the_djenggot/repository/type/stock_type_repository.dart';
import 'package:uuid/uuid.dart';

class StockRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;
  late final StockTypeRepository _stockTypeRepository = StockTypeRepository();
  // We'll initialize historyRepo lazily to avoid circular dependency
  StockHistoryRepository? _historyRepository;

  StockHistoryRepository get historyRepository {
    _historyRepository ??= StockHistoryRepository();
    return _historyRepository!;
  }

  // Get a Stock object by its ID
  Future<Stock?> getStockById(String stockId) async {
    final db = await _databaseHelper.db;
    final List<Map<String, dynamic>> result = await db.query(
      'STOCK',
      where: 'id_stock = ?',
      whereArgs: [stockId],
    );

    if (result.isNotEmpty) {
      final stockData = result.first;
      final stockTypeId = stockData['id_stock_type'];

      // Get the complete StockType object using the ID
      final stockType = await getStockTypeForId(stockTypeId as String);

      return Stock(
        idStock: stockData['id_stock'] as String,
        stockName: stockData['stock_name'] as String,
        stockQuantity: int.parse(stockData['stock_quantity'].toString()),
        stockThreshold: stockData['stock_threshold'] != null
            ? int.parse(stockData['stock_threshold'].toString())
            : 0,
        price: stockData['price'] != null ? int.parse(stockData['price'].toString()) : 0,
        idStockType: stockType,
      );
    }
    return null;
  }

  // Get a StockType object by its ID
  Future<StockType> getStockTypeForId(String stockTypeId) async {
    return await _stockTypeRepository.getStockTypeById(stockTypeId);
  }

  Future<List<Map<String, dynamic>>> getStocksWithTypes() async {
    final db = await _databaseHelper.db;
    final results = await db.rawQuery('''
      SELECT s.id_stock, s.stock_name, s.stock_price, s.stock_image, 
             s.id_stock_type, st.stock_type_name, st.stock_type_icon 
      FROM STOCK s
      JOIN STOCK_TYPE st ON s.id_stock_type = st.id_stock_type
    ''');

    return results;
  }

  Future<List<Stock>> getStocksWithTypeObjects() async {
    final List<Map<String, dynamic>> results = await getStocksWithTypes();

    return results.map((map) {
      final stockTypeMap = {
        'id_stock_type': map['id_stock_type'],
        'stock_type_name': map['stock_type_name'],
        'stock_type_icon': map['stock_type_icon'],
      };

      final stockMap = {
        'id_stock': map['id_stock'],
        'stock_name': map['stock_name'],
        'stock_price': map['stock_price'],
        'stock_image': map['stock_image'],
        'id_stock_type': stockTypeMap,
      };

      return Stock.fromMap(stockMap);
    }).toList();
  }

  Future<Stock?> getStockWithType(String stockId) async {
    final db = await _databaseHelper.db;
    final results = await db.rawQuery(
      '''
      SELECT s.id_stock, s.stock_name, s.stock_price, s.stock_image, 
             s.id_stock_type, st.stock_type_name, st.stock_type_icon 
      FROM STOCK s
      JOIN STOCK_TYPE st ON s.id_stock_type = st.id_stock_type
      WHERE s.id_stock = ?
    ''',
      [stockId],
    );

    if (results.isEmpty) {
      return null;
    }

    final map = results.first;

    final stockTypeMap = {
      'id_stock_type': map['id_stock_type'],
      'stock_type_name': map['stock_type_name'],
      'stock_type_icon': map['stock_type_icon'],
    };

    final stockMap = {
      'id_stock': map['id_stock'],
      'stock_name': map['stock_name'],
      'stock_price': map['stock_price'],
      'stock_image': map['stock_image'],
      'id_stock_type': stockTypeMap,
    };

    return Stock.fromMap(stockMap);
  }

  Future<List<Stock>> getAllStocks() async {
    final db = await _databaseHelper.db;
    final stocksData = await db.query('STOCK');

    return await Future.wait(stocksData.map((stockData) async {
      final stockTypeId = stockData['id_stock_type'];
      final stockType = await StockTypeRepository().getStockTypeById(stockTypeId);

      return Stock(
        idStock: stockData['id_stock'] as String,
        stockName: stockData['stock_name'] as String,
        stockQuantity: stockData['stock_quantity'] as int,
        stockThreshold: stockData['stock_threshold'] as int?,
        idStockType: stockType,
        price: stockData['price'] != null ? int.parse(stockData['price'].toString()) : 0,
      );
    }));
  }

  Future<List<Stock>> searchStocks(String query) async {
    final List<Map<String, dynamic>> stocksData = await _databaseHelper.getAllQuery(
      'STOCK',
      'stock_name LIKE ?',
      ['%$query%'],
    );

    return await Future.wait(stocksData.map((stockData) async {
      final stockTypeId = stockData['id_stock_type'];
      final stockType = await StockTypeRepository().getStockTypeById(stockTypeId);

      return Stock(
        idStock: stockData['id_stock'] as String,
        stockName: stockData['stock_name'] as String,
        stockQuantity: stockData['stock_quantity'] as int,
        stockThreshold: stockData['stock_threshold'] as int?,
        idStockType: stockType,
      );
    }));
  }

  Future<List<Stock>> getAllStok() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('STOCK', '', []);
    return maps.map((map) => Stock.fromMap(map)).toList();
  }

  Future<String> addStok(Map<String, dynamic> model) async {
    // Generate a new ID for the stock
    final String stockId = const Uuid().v4();
    model['id_stock'] = stockId;

    // Add the stock
    await _databaseHelper.insertQuery('STOCK', model);

    // Record history for the new stock
    await historyRepository.recordStockHistory(stockId, model['stock_quantity'], 'add');

    return stockId;
  }

  Future<int> updateStok(Map<String, dynamic> model, String id) async {
    final db = await _databaseHelper.db;

    // Get current stock before update
    final List<Map<String, dynamic>> currentStockResult = await db.query(
      'STOCK',
      where: 'id_stock = ?',
      whereArgs: [id],
    );

    if (currentStockResult.isNotEmpty) {
      final currentStock = currentStockResult.first;
      final int oldQuantity = currentStock['stock_quantity'] as int;
      final int newQuantity = int.parse(model['stock_quantity']);
      final int difference = newQuantity - oldQuantity;

      // Update the stock
      final result = await db.update(
        'STOCK',
        model,
        where: 'id_stock = ?',
        whereArgs: [id],
      );

      // Record history only if quantity changed
      if (difference != 0) {
        await historyRepository.recordStockHistory(
            id, difference, difference > 0 ? 'increase' : 'decrease');
      }

      return result;
    }

    return 0;
  }

  Future<int> deleteStok(String id) async {
    final db = await _databaseHelper.db;

    // Get current stock before delete
    final List<Map<String, dynamic>> currentStockResult = await db.query(
      'STOCK',
      where: 'id_stock = ?',
      whereArgs: [id],
    );

    if (currentStockResult.isNotEmpty) {
      final currentStock = currentStockResult.first;
      final int quantity = currentStock['stock_quantity'] as int;

      // Record history before deleting
      await historyRepository.recordStockHistory(
          id,
          -quantity, // Negative quantity as it's being removed
          'delete');

      // Delete the stock
      return await db.delete(
        'STOCK',
        where: 'id_stock = ?',
        whereArgs: [id],
      );
    }

    return 0;
  }
}
