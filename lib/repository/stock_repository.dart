import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/stock.dart';

class StockRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Stock>> getAllStocks() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('STOCK', '', []);
    return maps.map((map) => Stock.fromMap(map)).toList();
  }

  Future<List<Stock>> searchStocks(String query) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery(
      'STOCK',
      'name LIKE ?',
      ['%$query%'],
    );
    return maps.map((map) => Stock.fromMap(map)).toList();
  }

  Future<List<Stock>> getAllStok() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('STOCK', '', []);
    return maps.map((map) => Stock.fromMap(map)).toList();
  }

  Future<int> addStok(Map<String, dynamic> model) async {
    return await _databaseHelper.insertQuery(
      'STOCK',
      model,
    );
  }

  Future<int> updateStok(Map<String, dynamic> model, String id) async {
    return await _databaseHelper.updateQuery(
      'MENU',
      model,
      id,
    );
  }

  Future<int> deleteStok(String id) async {
    return await _databaseHelper.deleteQuery('MENU', id);
  }
}
