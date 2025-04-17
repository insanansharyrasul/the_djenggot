import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/type/stock_type.dart';

class StockTypeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<StockType>> getAllStockTypes() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('STOCK_TYPE', '', []);
    return maps.map((map) => StockType.fromMap(map)).toList();
  }

  Future<List<StockType>> searchStockTypes(String query) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery(
      'STOCK_TYPE',
      'stock_type_name LIKE ?',
      ['%$query%'],
    );
    return maps.map((map) => StockType.fromMap(map)).toList();
  }

  Future<int> addStockType(StockType stockType) async {
    return await _databaseHelper.insertQuery(
      'STOCK_TYPE',
      stockType.toMap()
    );
  }

  Future<int> updateStockType(StockType stockType) async {
    final db = await _databaseHelper.db;
    return await db.update(
      'STOCK_TYPE',
      stockType.toMap(),
      where: 'id_stock_type = ?',
      whereArgs: [stockType.idStockType],
    );
  }

  Future<int> deleteStockType(String id) async {
    return await _databaseHelper.deleteQuery('STOCK_TYPE', id);
  }
}
