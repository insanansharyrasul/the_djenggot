import 'dart:typed_data';
import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/transaction/transaction_history.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:uuid/uuid.dart';

class TransactionRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Get all transactions
  Future<List<TransactionHistory>> getAllTransactions() async {
    try {
      final db = await _databaseHelper.db;

      // Get all transaction histories with type info
      final List<Map<String, dynamic>> transactions = await db.rawQuery('''
        SELECT th.*, tt.transaction_type_name, tt.transaction_type_icon
        FROM TRANSACTION_HISTORY th
        LEFT JOIN TRANSACTION_TYPE tt ON th.id_transaction_type = tt.id_transaction_type
        ORDER BY th.timestamp DESC
      ''');

      // Convert raw data to TransactionHistory objects with items
      List<TransactionHistory> result = [];

      for (var transaction in transactions) {
        // Get items for this transaction
        final List<Map<String, dynamic>> items = await db.rawQuery('''
          SELECT 
            ti.*,
            m.menu_name, 
            m.menu_price, 
            m.menu_image,
            mt.id_menu_type AS menu_type_id, 
            mt.menu_type_name, 
            mt.menu_type_icon
          FROM TRANSACTION_ITEM ti
          LEFT JOIN MENU m ON ti.id_menu = m.id_menu
          LEFT JOIN MENU_TYPE mt ON m.id_menu_type = mt.id_menu_type
          WHERE ti.id_transaction_history = ?
        ''', [transaction['id_transaction_history']]);

        // Convert items to TransactionItem objects
        List<TransactionItem> transactionItems = items.map((item) {
          return TransactionItem(
            idTransactionItem: item['id_transaction_item'],
            idTransactionHistory: item['id_transaction_history'],
            menu: Menu.fromMap(item),
            transactionQuantity: item['transaction_quantity'],
          );
        }).toList();

        // Create TransactionHistory with items
        result.add(
          TransactionHistory(
            idTransactionHistory: transaction['id_transaction_history'],
            transactionType: TransactionType(
              idTransactionType: transaction['id_transaction_type'],
              transactionTypeName: transaction['transaction_type_name'],
              transactionTypeIcon: transaction['transaction_type_icon'],
            ),
            transactionAmount: transaction['transaction_amount'],
            imageEvident: transaction['image_evident'],
            timestamp: transaction['timestamp'],
            moneyReceived: transaction['money_received'],
            items: transactionItems,
          ),
        );
      }

      return result;
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  // Get transaction by ID
  Future<TransactionHistory?> getTransactionById(String id) async {
    try {
      final db = await _databaseHelper.db;

      // Get transaction history with type info
      final List<Map<String, dynamic>> transactions = await db.rawQuery('''
        SELECT th.*, tt.transaction_type_name, tt.transaction_type_icon
        FROM TRANSACTION_HISTORY th
        LEFT JOIN TRANSACTION_TYPE tt ON th.id_transaction_type = tt.id_transaction_type
        WHERE th.id_transaction_history = ?
      ''', [id]);

      if (transactions.isEmpty) {
        return null;
      }

      // Get items for this transaction
      final List<Map<String, dynamic>> items = await db.rawQuery('''
        SELECT 
          ti.*,
          m.menu_name, 
          m.menu_price, 
          m.menu_image,
          mt.id_menu_type AS menu_type_id, 
          mt.menu_type_name, 
          mt.menu_type_icon
        FROM TRANSACTION_ITEM ti
        LEFT JOIN MENU m ON ti.id_menu = m.id_menu
        LEFT JOIN MENU_TYPE mt ON m.id_menu_type = mt.id_menu_type
        WHERE ti.id_transaction_history = ?
      ''', [id]);

      // Convert items to TransactionItem objects
      List<TransactionItem> transactionItems = items.map((item) {
        return TransactionItem(
          idTransactionItem: item['id_transaction_item'],
          idTransactionHistory: item['id_transaction_history'],
          menu: Menu.fromMap(item),
          transactionQuantity: item['transaction_quantity'],
        );
      }).toList();

      // Create and return TransactionHistory with items
      return TransactionHistory(
        idTransactionHistory: transactions[0]['id_transaction_history'],
        transactionType: TransactionType(
          idTransactionType: transactions[0]['id_transaction_type'],
          transactionTypeName: transactions[0]['transaction_type_name'],
          transactionTypeIcon: transactions[0]['transaction_type_icon'],
        ),
        transactionAmount: transactions[0]['transaction_amount'],
        moneyReceived: transactions[0]['money_received'],
        imageEvident: transactions[0]['image_evident'],
        timestamp: transactions[0]['timestamp'],
        items: transactionItems,
      );
    } catch (e) {
      throw Exception('Failed to get transaction: $e');
    }
  }

  // Add a new transaction
  Future<void> addTransaction(
    String transactionTypeId,
    int amount,
    int moneyReceived,
    Uint8List evident,
    List<TransactionItem> items,
  ) async {
    final id = "transaction-${const Uuid().v4()}";
    final timestamp = DateTime.now().toIso8601String();

    await _databaseHelper.insertQuery(
      'TRANSACTION_HISTORY',
      {
        'id_transaction_history': id,
        'id_transaction_type': transactionTypeId,
        'transaction_amount': amount,
        'money_received': moneyReceived,
        'image_evident': evident,
        'timestamp': timestamp,
      },
    );

    // Insert transaction items
    for (var item in items) {
      await _databaseHelper.insertQuery(
        'TRANSACTION_ITEM',
        {
          'id_transaction_item': "transaction-item-${const Uuid().v4()}",
          'id_transaction_history': id,
          'id_menu': item.menu.idMenu,
          'transaction_quantity': item.transactionQuantity,
        },
      );
    }
  }

  // Delete a transaction
  Future<int> deleteTransaction(String id) async {
    try {
      final db = await _databaseHelper.db;

      // The foreign key constraints will handle deleting related items
      return await db.delete(
        'TRANSACTION_HISTORY',
        where: 'id_transaction_history = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }
}
