import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:uuid/uuid.dart';

class TransactionTypeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<TransactionType>> getAllTransactionTypes() async {
    try {
      final List<Map<String, dynamic>> maps =
          await _databaseHelper.getAllQuery('TRANSACTION_TYPE', '', []);
      return maps.map((map) => TransactionType.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to load transaction types: $e');
    }
  }

  Future<List<TransactionType>> searchTransactionTypes(String query) async {
    try {
      final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery(
        'TRANSACTION_TYPE',
        'transaction_type_name LIKE ?',
        ['%$query%'],
      );
      return maps.map((map) => TransactionType.fromMap(map)).toList();
    } catch (e) {
      throw Exception('Failed to search transaction types: $e');
    }
  }

  Future<int> addTransactionType(String name,
      {String? icon, bool needEvidence = true}) async {
    try {
      final String uniqueId = "transaction-type-${const Uuid().v4()}";
      return await _databaseHelper.insertQuery(
        'TRANSACTION_TYPE',
        {
          'id_transaction_type': uniqueId,
          'transaction_type_name': name,
          'transaction_type_icon': icon,
          'need_evidence': needEvidence ? 1 : 0,
        },
      );
    } catch (e) {
      throw Exception('Failed to add transaction type: $e');
    }
  }

  Future<int> updateTransactionType(
    TransactionType transactionType,
    String newName, {
    String? icon,
    bool? needEvidence,
  }) async {
    try {
      final db = await _databaseHelper.db;
      return await db.update(
        'TRANSACTION_TYPE',
        {
          'transaction_type_name': newName,
          'transaction_type_icon': icon ?? transactionType.transactionTypeIcon,
          'need_evidence': needEvidence != null
              ? (needEvidence ? 1 : 0)
              : transactionType.needEvidence
                  ? 1
                  : 0,
        },
        where: 'id_transaction_type = ?',
        whereArgs: [transactionType.idTransactionType],
      );
    } catch (e) {
      throw Exception('Failed to update transaction type: $e');
    }
  }

  Future<int> deleteTransactionType(String id) async {
    try {
      final db = await _databaseHelper.db;
      return await db.delete(
        'TRANSACTION_TYPE',
        where: 'id_transaction_type = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw Exception('Failed to delete transaction type: $e');
    }
  }
}
