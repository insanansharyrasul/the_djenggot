import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/stock.dart';

class StockRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

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

    // Create a StockType map from the joined data
    final stockTypeMap = {
      'id_stock_type': map['id_stock_type'],
      'stock_type_name': map['stock_type_name'],
      'stock_type_icon': map['stock_type_icon'],
    };

    // Create a modified map with the StockType as a nested object
    final stockMap = {
      'id_stock': map['id_stock'],
      'stock_name': map['stock_name'],
      'stock_price': map['stock_price'],
      'stock_image': map['stock_image'],
      'id_stock_type': stockTypeMap, // Pass the entire StockType as a map
    };

    return Stock.fromMap(stockMap);
  }

  Future<List<Stock>> getAllStocks() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('STOCK', '', []);
    return maps.map((map) => Stock.fromMap(map)).toList();
  }

  Future<List<Stock>> searchStocks(String query) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery(
      'STOCK',
      'stock_name LIKE ?',
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
    final db = await _databaseHelper.db;
    return await db.update(
      'STOCK',
      model,
      where: 'id_stock = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteStok(String id) async {
    final db = await _databaseHelper.db;
    return await db.delete(
      'STOCK',
      where: 'id_stock = ?',
      whereArgs: [id],
    );
  }
}
