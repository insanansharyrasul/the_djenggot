import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

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
      CREATE TABLE table (
        nama_kolom TIPE_DATA TAMBAHAN,
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getAllQuery(
      String tableName, String where, List<dynamic> whereAgrs) async {
    Database db = await instance.db;
    return await db.query(
      tableName,
      where: where,
      whereArgs: whereAgrs,
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

  Future<int> deleteQuery(String tableName, int id) async {
    Database db = await instance.db;
    return await db.delete(tableName, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> truncateQuery(String tableName) async {
    Database db = await instance.db;
    return await db.delete(tableName);
  }
}
