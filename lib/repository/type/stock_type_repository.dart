import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:uuid/uuid.dart';

class StockTypeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<StockType>> getAllStockTypes() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('STOCK_TYPE', '', []);
    return maps.map((map) => StockType.fromMap(map)).toList();
  }

  Future<List<StockType>> searchStockTypes(String query) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery(
      'STOCK_TYPE',
      'name LIKE ?',
      ['%$query%'],
    );
    return maps.map((map) => StockType.fromMap(map)).toList();
  }

  Future<int> addStockType(String name) async {
    final String uniqueId = "stock-type-${const Uuid().v4()}";
    return await _databaseHelper.insertQuery(
      'STOCK_TYPE',
      {
        'id_stock_type': uniqueId,
        'name': name,
      },
    );
  }

  Future<int> updateStockType(StockType stockType, String newName) async {
    return await _databaseHelper.updateQuery(
      'STOCK_TYPE',
      {'name': newName},
      stockType.id,
    );
  }

  Future<int> deleteStockType(String id) async {
    return await _databaseHelper.deleteQuery('STOCK_TYPE', id);
  }
}
