import 'package:the_djenggot/models/transaction/transaction_history.dart';

abstract class TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionDetailLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionHistory> transactions;

  TransactionLoaded(this.transactions);
}

class TransactionDetailLoaded extends TransactionState {
  final TransactionHistory transaction;

  TransactionDetailLoaded(this.transaction);
}

class TransactionError extends TransactionState {
  final String message;

  TransactionError(this.message);
}

class TransactionAdded extends TransactionState {
  final String transactionId;

  TransactionAdded(this.transactionId);
}

class TransactionDeleted extends TransactionState {}
