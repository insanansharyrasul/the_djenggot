import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:uuid/uuid.dart';

class TransactionTypeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<TransactionType>> getAllTransactionTypes() async {
    final List<Map<String, dynamic>> maps =
        await _databaseHelper.getAllQuery('TRANSACTION_TYPE', '', []);
    return maps.map((map) => TransactionType.fromMap(map)).toList();
  }

  Future<List<TransactionType>> searchTransactionTypes(String query) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery(
      'TRANSACTION_TYPE',
      'name LIKE ?',
      ['%$query%'],
    );
    return maps.map((map) => TransactionType.fromMap(map)).toList();
  }

  Future<int> addTransactionType(String name, {String? icon}) async {
    final String uniqueId = "transaction-type-${const Uuid().v4()}";
    return await _databaseHelper.insertQuery(
      'TRANSACTION_TYPE',
      {
        'id_transaction_type': uniqueId,
        'name': name,
        'icon': icon,
      },
    );
  }

  Future<int> updateTransactionType(TransactionType transactionType, String newName,
      {String? icon}) async {
    final db = await _databaseHelper.db;
    return await db.update(
      'TRANSACTION_TYPE',
      {
        'name': newName,
        'icon': icon,
      },
      where: 'id_transaction_type = ?',
      whereArgs: [transactionType.idTransactionType],
    );
  }

  Future<int> deleteTransactionType(String id) async {
    final db  = await _databaseHelper.db;
    return await db.delete(
      'TRANSACTION_TYPE',
      where: 'id_transaction_type = ?',
      whereArgs: [id],
    );
  }
}
