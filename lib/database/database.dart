import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:the_djenggot/models/stock.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._instance();
  static Database? _database;

  DatabaseHelper._instance();

  Future<Database> get db async {
    _database ??= await initDb();
    return _database!;
  }

  Future<Database> initDb() async {
    String databasesPath = await getDatabasesPath();
    String path = join(databasesPath, 'djenggot.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE stok (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllQuery(
      String tableName, String where, List<dynamic> whereAgrs) async {
    Database db = await instance.db;
    return await db.query(
      tableName,
      where: (where != '' && where.isNotEmpty) ? where : null,
      whereArgs: (whereAgrs.isNotEmpty) ? whereAgrs : null,
    );
  }

  Future<int> countQuery(String tableName, String where, List<dynamic> whereAgrs) async {
    Database db = await instance.db;
    final result = await db.query(
      tableName,
      where: where,
      whereArgs: whereAgrs,
    );
    return result.length;
  }

  Future<int> insertQuery(String tableName, Map<String, dynamic> model) async {
    Database db = await instance.db;
    return await db.insert(
      tableName,
      model,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> deleteQuery(String tableName, String id) async {
    Database db = await instance.db;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> truncateQuery(String tableName) async {
    Database db = await instance.db;
    return await db.delete(tableName);
  }

  Future<int> updateQuery(String tableName, Map<String, dynamic> model, String id) async {
    Database db = await instance.db;
    return await db.update(
      tableName,
      model,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Stock>> getAllStocks() async {
    final List<Map<String, dynamic>> maps = await getAllQuery('stok', '', []);
    return maps.map((map) => Stock.fromMap(map)).toList();
  }

  Future<List<Stock>> searchStocks(String query) async {
    final List<Map<String, dynamic>> maps = await getAllQuery(
      'stok',
      'name LIKE ?',
      ['%$query%'],
    );
    return maps.map((map) => Stock.fromMap(map)).toList();
  }
}
