import 'package:equatable/equatable.dart';

abstract class ProfitLossEvent extends Equatable {
  const ProfitLossEvent();

  @override
  List<Object> get props => [];
}

class LoadProfitLossData extends ProfitLossEvent {
  final DateTime startDate;
  final DateTime endDate;

  const LoadProfitLossData({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}

class ChangeProfitLossDateRange extends ProfitLossEvent {
  final DateTime startDate;
  final DateTime endDate;

  const ChangeProfitLossDateRange({required this.startDate, required this.endDate});

  @override
  List<Object> get props => [startDate, endDate];
}
