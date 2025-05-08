import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:intl/intl.dart';

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
    );
  }

  Future _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _onCreate(Database db, int version) async {
    await db.transaction((txn) async {
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

      await txn.execute('''
        CREATE TABLE STOCK (
          id_stock TEXT PRIMARY KEY NOT NULL,
          id_stock_type TEXT NOT NULL,
          stock_name TEXT NOT NULL,
          stock_quantity INTEGER NOT NULL,
          stock_threshold INTEGER NOT NULL,
          price INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (id_stock_type) REFERENCES STOCK_TYPE(id_stock_type) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

      await txn.execute('''
        CREATE TABLE STOCK_HISTORY (
          stock_history_id TEXT PRIMARY KEY NOT NULL,
          timestamp TEXT NOT NULL,
          id_stock TEXT NOT NULL,
          amount INTEGER NOT NULL,
          action_type TEXT NOT NULL,
          total_price INTEGER NOT NULL DEFAULT 0,
          FOREIGN KEY (id_stock) REFERENCES STOCK(id_stock) ON DELETE CASCADE ON UPDATE CASCADE
        )
      ''');

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

  Future<int> countQuery(String tableName, String where, List<dynamic> whereArgs) async {
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

  Future<String?> exportDatabase() async {
    try {
      if (!await _requestPermissions()) {
        return 'Storage permission denied';
      }

      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }

      final dbPath = await getDatabasesPath();
      final dbFile = join(dbPath, 'djenggot.db');

      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) {
        throw Exception('Could not access storage directory');
      }

      final exportDir = Directory('${directory.path}/DjenggotBackups');
      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final exportPath = '${exportDir.path}/djenggot_db_$timestamp.db';

      await File(dbFile).copy(exportPath);

      _database = await initDb();

      return exportPath;
    } catch (e) {
      if (_database == null || !_database!.isOpen) {
        _database = await initDb();
      }

      return null;
    }
  }

  Future<bool> importDatabase(String sourcePath) async {
    try {
      // Close current database connection if open
      if (_database != null && _database!.isOpen) {
        await _database!.close();
        _database = null;
      }

      // Get destination path for app's database
      final dbPath = await getDatabasesPath();
      final destinationPath = join(dbPath, 'djenggot.db');

      // Create source and destination file objects
      final sourceFile = File(sourcePath);

      // Check if source file exists
      if (!await sourceFile.exists()) {
        throw Exception('Import file not found');
      }

      // Copy the source file to the destination
      await sourceFile.copy(destinationPath);

      // Reopen the database connection
      _database = await initDb();

      return true;
    } catch (e) {
      // Handle any errors and ensure database is reopened
      if (_database == null || !_database!.isOpen) {
        _database = await initDb();
      }
      debugPrint('Database import error: $e');
      return false;
    }
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.storage.status;
      if (!status.isGranted) {
        status = await Permission.storage.request();
      }

      var manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        manageStatus = await Permission.manageExternalStorage.request();
      }

      return status.isGranted || manageStatus.isGranted;
    }
    return true;
  }
}
