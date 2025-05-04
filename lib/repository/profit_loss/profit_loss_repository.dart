import 'package:intl/intl.dart';
import '../../database/database.dart';
import '../../models/profit_loss/profit_loss.dart';

class ProfitLossRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Get profit and loss data for a specific time range
  Future<List<ProfitLoss>> getProfitLossData(DateTime startDate, DateTime endDate) async {
    final String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
    final String endDateString =
        DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)));

    // Get income data from transactions
    final incomeData = await _databaseHelper.db.then((db) => db.rawQuery('''
      SELECT 
        substr(timestamp, 1, 10) as date, 
        SUM(transaction_amount) as total_income 
      FROM TRANSACTION_HISTORY 
      WHERE timestamp BETWEEN ? AND ? 
      GROUP BY substr(timestamp, 1, 10)
    ''', [startDateString, endDateString]));

    // Get expenses data from stock history
    final expensesData = await _databaseHelper.db.then((db) => db.rawQuery('''
      SELECT 
        substr(timestamp, 1, 10) as date, 
        SUM(total_price) as total_expenses 
      FROM STOCK_HISTORY 
      WHERE timestamp BETWEEN ? AND ? 
      AND action_type = 'add'
      GROUP BY substr(timestamp, 1, 10)
    ''', [startDateString, endDateString]));

    // Combine the data
    final Map<String, ProfitLoss> profitLossMap = {};

    // Process income data
    for (final row in incomeData) {
      final String date = row['date'] as String;
      final int income = row['total_income'] as int;

      profitLossMap[date] = ProfitLoss(
        date: DateTime.parse(date),
        income: income,
        expenses: 0, // Will be updated if there are expenses on this date
        netProfit: income,
      );
    }

    // Process expenses data and update the map
    for (final row in expensesData) {
      final String date = row['date'] as String;
      final int expenses = row['total_expenses'] as int;

      if (profitLossMap.containsKey(date)) {
        final existingData = profitLossMap[date]!;
        profitLossMap[date] = ProfitLoss(
          date: existingData.date,
          income: existingData.income,
          expenses: expenses,
          netProfit: existingData.income - expenses,
        );
      } else {
        profitLossMap[date] = ProfitLoss(
          date: DateTime.parse(date),
          income: 0,
          expenses: expenses,
          netProfit: -expenses,
        );
      }
    }

    // Sort by date
    final result = profitLossMap.values.toList()..sort((a, b) => a.date.compareTo(b.date));

    return result;
  }

  // Get expense categories for a specific timeframe
  Future<List<ExpenseCategory>> getExpenseCategories(DateTime startDate, DateTime endDate) async {
    final String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
    final String endDateString =
        DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)));

    final expensesData = await _databaseHelper.db.then((db) => db.rawQuery('''
      SELECT 
        s.stock_name,
        SUM(sh.total_price) as total_expense
      FROM STOCK_HISTORY sh
      INNER JOIN STOCK s ON sh.id_stock = s.id_stock
      WHERE sh.timestamp BETWEEN ? AND ?
      AND sh.action_type = 'add'
      GROUP BY s.id_stock
      ORDER BY total_expense DESC
    ''', [startDateString, endDateString]));

    return expensesData
        .map((row) => ExpenseCategory(
              name: row['stock_name'] as String,
              amount: row['total_expense'] as int,
            ))
        .toList();
  }

  // Get total summary for a specific timeframe
  Future<ProfitLoss> getSummary(DateTime startDate, DateTime endDate) async {
    final String startDateString = DateFormat('yyyy-MM-dd').format(startDate);
    final String endDateString =
        DateFormat('yyyy-MM-dd').format(endDate.add(const Duration(days: 1)));

    final incomeResult = await _databaseHelper.db.then((db) => db.rawQuery('''
      SELECT SUM(transaction_amount) as total_income
      FROM TRANSACTION_HISTORY
      WHERE timestamp BETWEEN ? AND ?
    ''', [startDateString, endDateString]));

    final expensesResult = await _databaseHelper.db.then((db) => db.rawQuery('''
      SELECT SUM(total_price) as total_expenses
      FROM STOCK_HISTORY
      WHERE timestamp BETWEEN ? AND ?
      AND action_type = 'add'
    ''', [startDateString, endDateString]));

    final int income = incomeResult.first['total_income'] as int? ?? 0;
    final int expenses = expensesResult.first['total_expenses'] as int? ?? 0;

    return ProfitLoss(
      date: startDate,
      income: income,
      expenses: expenses,
      netProfit: income - expenses,
    );
  }
}
