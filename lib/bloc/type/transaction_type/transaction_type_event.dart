import 'package:the_djenggot/models/type/transaction_type.dart';

abstract class TransactionTypeEvent {}

class LoadTransactionTypes extends TransactionTypeEvent {}

class AddTransactionType extends TransactionTypeEvent {
  final String name;
  final String icon;
  final bool? needEvidence;

  AddTransactionType(this.name, this.icon, this.needEvidence);
}

class UpdateTransactionType extends TransactionTypeEvent {
  final TransactionType transactionType;
  final String newName;
  final String icon;
  final bool needEvidence;

  UpdateTransactionType(this.transactionType, this.newName, this.icon, this.needEvidence);
}

class DeleteTransactionType extends TransactionTypeEvent {
  final String id;

  DeleteTransactionType(this.id);
}

class SearchTransactionTypes extends TransactionTypeEvent {
  final String query;

  SearchTransactionTypes(this.query);
}
