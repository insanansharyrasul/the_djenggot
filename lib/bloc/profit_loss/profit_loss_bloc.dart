import 'package:flutter_bloc/flutter_bloc.dart';

import '../../repository/profit_loss/profit_loss_repository.dart';
import 'profit_loss_event.dart';
import 'profit_loss_state.dart';

class ProfitLossBloc extends Bloc<ProfitLossEvent, ProfitLossState> {
  final ProfitLossRepository _profitLossRepository;

  ProfitLossBloc({
    required ProfitLossRepository profitLossRepository,
  })  : _profitLossRepository = profitLossRepository,
        super(ProfitLossInitial()) {
    on<LoadProfitLossData>(_onLoadProfitLossData);
    on<ChangeProfitLossDateRange>(_onChangeDateRange);
  }

  Future<void> _onLoadProfitLossData(
    LoadProfitLossData event,
    Emitter<ProfitLossState> emit,
  ) async {
    emit(ProfitLossLoading());
    try {
      final profitLossData = await _profitLossRepository.getProfitLossData(
        event.startDate,
        event.endDate,
      );

      final expenseCategories = await _profitLossRepository.getExpenseCategories(
        event.startDate,
        event.endDate,
      );

      final summary = await _profitLossRepository.getSummary(
        event.startDate,
        event.endDate,
      );

      emit(ProfitLossLoaded(
        profitLossData: profitLossData,
        expenseCategories: expenseCategories,
        summary: summary,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ProfitLossError(message: e.toString()));
    }
  }

  Future<void> _onChangeDateRange(
    ChangeProfitLossDateRange event,
    Emitter<ProfitLossState> emit,
  ) async {
    emit(ProfitLossLoading());
    try {
      final profitLossData = await _profitLossRepository.getProfitLossData(
        event.startDate,
        event.endDate,
      );

      final expenseCategories = await _profitLossRepository.getExpenseCategories(
        event.startDate,
        event.endDate,
      );

      final summary = await _profitLossRepository.getSummary(
        event.startDate,
        event.endDate,
      );

      emit(ProfitLossLoaded(
        profitLossData: profitLossData,
        expenseCategories: expenseCategories,
        summary: summary,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e) {
      emit(ProfitLossError(message: e.toString()));
    }
  }
}
