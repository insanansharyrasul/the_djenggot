import 'package:equatable/equatable.dart';
import '../../models/profit_loss/profit_loss.dart';

abstract class ProfitLossState extends Equatable {
  const ProfitLossState();

  @override
  List<Object> get props => [];
}

class ProfitLossInitial extends ProfitLossState {}

class ProfitLossLoading extends ProfitLossState {}

class ProfitLossLoaded extends ProfitLossState {
  final List<ProfitLoss> profitLossData;
  final List<ExpenseCategory> expenseCategories;
  final ProfitLoss summary;
  final DateTime startDate;
  final DateTime endDate;

  const ProfitLossLoaded({
    required this.profitLossData,
    required this.expenseCategories,
    required this.summary,
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object> get props => [profitLossData, expenseCategories, summary, startDate, endDate];
}

class ProfitLossError extends ProfitLossState {
  final String message;

  const ProfitLossError({required this.message});

  @override
  List<Object> get props => [message];
}
