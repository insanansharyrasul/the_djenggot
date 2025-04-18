import 'package:the_djenggot/models/type/transaction_type.dart';

abstract class TransactionTypeEvent {}

class LoadTransactionTypes extends TransactionTypeEvent {}

class AddTransactionType extends TransactionTypeEvent {
  final String name;
  final String? icon;

  AddTransactionType(this.name, {this.icon});
}

class UpdateTransactionType extends TransactionTypeEvent {
  final TransactionType transactionType;
  final String newName;
  final String? icon;

  UpdateTransactionType(this.transactionType, this.newName, {this.icon});
}

class DeleteTransactionType extends TransactionTypeEvent {
  final String id;

  DeleteTransactionType(this.id);
}

class SearchTransactionTypes extends TransactionTypeEvent {
  final String query;

  SearchTransactionTypes(this.query);
}
