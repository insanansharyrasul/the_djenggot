import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';

abstract class TransactionTypeState extends Equatable {
  const TransactionTypeState();

  @override
  List<Object?> get props => [];
}

class TransactionTypeLoading extends TransactionTypeState {}

class TransactionTypeLoaded extends TransactionTypeState {
  final List<TransactionType> transactionTypes;

  const TransactionTypeLoaded(this.transactionTypes);

  @override
  List<Object?> get props => [transactionTypes];
}

class TransactionTypeError extends TransactionTypeState {
  final String message;

  const TransactionTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
