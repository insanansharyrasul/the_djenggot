class ProfitLoss {
  final DateTime date;
  final int income; // Revenue from sales
  final int expenses; // Cost of stock purchases
  final int netProfit; // Income - expenses

  ProfitLoss({
    required this.date,
    required this.income,
    required this.expenses,
    required this.netProfit,
  });

  factory ProfitLoss.fromJson(Map<String, dynamic> json) {
    return ProfitLoss(
      date: DateTime.parse(json['date']),
      income: json['income'],
      expenses: json['expenses'],
      netProfit: json['netProfit'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'income': income,
      'expenses': expenses,
      'netProfit': netProfit,
    };
  }
}

class ExpenseCategory {
  final String name;
  final int amount;

  ExpenseCategory({required this.name, required this.amount});
}
