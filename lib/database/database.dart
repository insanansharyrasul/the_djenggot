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

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
      // onUpgrade: _onUpgrade,
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
      // TYPE TABLE
      await txn.execute('''
        CREATE TABLE TRANSACTION_TYPE (
          id_transaction_type TEXT PRIMARY KEY NOT NULL,
          transaction_type_name TEXT NOT NULL,
          transaction_type_icon TEXT NOT NULL,
          need_evidence INTEGER NOT NULL DEFAULT 1
        )
      ''');

      await txn.execute('''
        CREATE TABLE MENU_TYPE (
          id_menu_type TEXT PRIMARY KEY NOT NULL,
          menu_type_name TEXT NOT NULL,
          menu_type_icon TEXT NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE STOCK_TYPE (
          id_stock_type TEXT PRIMARY KEY NOT NULL,
          stock_type_name TEXT NOT NULL,
          stock_type_icon TEXT NOT NULL,
          stock_unit TEXT NOT NULL
        )
      ''');

      // TRANSACTION TABLE
      await txn.execute('''
        CREATE TABLE TRANSACTION_HISTORY (
          id_transaction_history TEXT PRIMARY KEY NOT NULL,
          id_transaction_type TEXT NOT NULL,
          transaction_amount INTEGER NOT NULL,
          money_received INTEGER NOT NULL DEFAULT 0,
          image_evident BLOB NOT NULL,
          timestamp TEXT NOT NULL,  
          FOREIGN KEY (id_transaction_type) REFERENCES TRANSACTION_TYPE(id_transaction_type) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE TABLE TRANSACTION_ITEM (
          id_transaction_item TEXT PRIMARY KEY NOT NULL,
          id_transaction_history TEXT NOT NULL,
          id_menu TEXT NOT NULL,
          transaction_quantity INTEGER NOT NULL,
          FOREIGN KEY (id_transaction_history) REFERENCES TRANSACTION_HISTORY(id_transaction_history) ON DELETE CASCADE ON UPDATE CASCADE,
          FOREIGN KEY (id_menu) REFERENCES MENU(id_menu) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      // STOCK TABLE
      await txn.execute('''
        CREATE TABLE STOCK (
          id_stock TEXT PRIMARY KEY NOT NULL,
          id_stock_type TEXT NOT NULL,
          stock_name TEXT NOT NULL,
          stock_quantity INTEGER NOT NULL,
          stock_threshold INTEGER NOT NULL,
          FOREIGN KEY (id_stock_type) REFERENCES STOCK_TYPE(id_stock_type) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      // MENU TABLE
      await txn.execute('''
        CREATE TABLE MENU (
          id_menu TEXT PRIMARY KEY NOT NULL,
          menu_name TEXT NOT NULL,
          menu_price INTEGER NOT NULL,
          menu_image BLOB NOT NULL,
          id_menu_type TEXT NOT NULL,
          FOREIGN KEY (id_menu_type) REFERENCES MENU_TYPE(id_menu_type) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');
    });
  }

  Future<List<Map<String, dynamic>>> getAllQuery(
      String tableName, String where, List<dynamic> whereArgs) async {
    Database db = await instance.db;
    return await db.query(
      tableName,
      where: (where != '' && where.isNotEmpty) ? where : null,
      whereArgs: (whereArgs.isNotEmpty) ? whereArgs : null,
    );
  }

  Future<int> countQuery(
      String tableName, String where, List<dynamic> whereArgs) async {
    Database db = await instance.db;
    final result = await db.query(
      tableName,
      where: where,
      whereArgs: whereArgs,
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

  Future<int> truncateQuery(String tableName) async {
    Database db = await instance.db;
    return await db.delete(tableName);
  }
}
