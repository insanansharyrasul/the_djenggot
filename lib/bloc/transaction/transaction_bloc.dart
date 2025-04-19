import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/repository/transaction/transaction_repository.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _transactionRepository;

  TransactionBloc(this._transactionRepository) : super(TransactionLoading()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionById>(_onLoadTransactionById);
    on<AddNewTransaction>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  void _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactions = await _transactionRepository.getAllTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onLoadTransactionById(
    LoadTransactionById event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    emit(TransactionDetailLoading());
    try {
      final transaction = await _transactionRepository.getTransactionById(event.id);
      if (transaction != null) {
        emit(TransactionDetailLoaded(transaction));
      } else {
        emit(TransactionError('Transaction not found'));
      }
    } catch (e) {
      if (currentState is TransactionLoaded) {
        emit(currentState);
      } else {
        emit(TransactionError(e.toString()));
      }
    }
  }

  void _onAddTransaction(
    AddNewTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      final transactionId = await _transactionRepository.addTransaction(
        event.transactionTypeId,
        event.amount,
        event.evident,
        event.items,
      );
      emit(TransactionAdded(transactionId));
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }

  void _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    try {
      await _transactionRepository.deleteTransaction(event.id);
      emit(TransactionDeleted());
    } catch (e) {
      emit(TransactionError(e.toString()));
    }
  }
}
