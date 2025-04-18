import 'package:the_djenggot/models/type/transaction_type.dart';

abstract class TransactionTypeState {}

class TransactionTypeLoading extends TransactionTypeState {}

class TransactionTypeLoaded extends TransactionTypeState {
  final List<TransactionType> transactionTypes;

  TransactionTypeLoaded(this.transactionTypes);
}

class TransactionTypeError extends TransactionTypeState {
  final String message;

  TransactionTypeError(this.message);
}
