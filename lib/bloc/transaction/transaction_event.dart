import 'dart:typed_data';
import 'package:the_djenggot/models/transaction/transaction_item.dart';

abstract class TransactionEvent {}

class LoadTransactions extends TransactionEvent {}

class LoadTransactionById extends TransactionEvent {
  final String id;

  LoadTransactionById(this.id);
}

class AddNewTransaction extends TransactionEvent {
  final String transactionTypeId;
  final double amount;
  final Uint8List evident;
  final List<TransactionItem> items;

  AddNewTransaction(this.transactionTypeId, this.amount, this.evident, this.items);
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  DeleteTransactionEvent(this.id);
}
