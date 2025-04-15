import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';

abstract class TransactionTypeEvent extends Equatable {
  const TransactionTypeEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionTypes extends TransactionTypeEvent {}

class AddTransactionType extends TransactionTypeEvent {
  final String name;

  const AddTransactionType(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateTransactionType extends TransactionTypeEvent {
  final TransactionType transactionType;
  final String newName;

  const UpdateTransactionType(this.transactionType, this.newName);

  @override
  List<Object?> get props => [transactionType, newName];
}

class DeleteTransactionType extends TransactionTypeEvent {
  final String id;

  const DeleteTransactionType(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchTransactionTypes extends TransactionTypeEvent {
  final String query;

  const SearchTransactionTypes(this.query);

  @override
  List<Object?> get props => [query];
}
