import 'dart:typed_data';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:equatable/equatable.dart';

class TransactionHistory extends Equatable {
  final String idTransactionHistory;
  final TransactionType transactionType;
  final int transactionAmount;
  final int moneyReceived;
  final Uint8List imageEvident;
  final String timestamp;
  final List<TransactionItem>? items;

  const TransactionHistory({
    required this.idTransactionHistory,
    required this.transactionType,
    required this.transactionAmount,
    required this.moneyReceived,
    required this.imageEvident,
    required this.timestamp,
    this.items,
  });

  factory TransactionHistory.fromMap(Map<String, dynamic> map,
      {TransactionType? type, List<TransactionItem>? items}) {
    return TransactionHistory(
      idTransactionHistory: map['id_transaction_history'],
      transactionType: type ?? TransactionType.fromMap(map),
      transactionAmount: map['transaction_amount'],
      moneyReceived: map['money_received'] ?? 0.0,
      imageEvident: map['image_evident'],
      timestamp: map['timestamp'],
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaction_history': idTransactionHistory,
      'id_transaction_type': transactionType.idTransactionType,
      'transaction_amount': transactionAmount,
      'money_received': moneyReceived,
      'image_evident': imageEvident,
      'timestamp': timestamp,
    };
  }

  TransactionHistory copyWith({
    String? idTransactionHistory,
    TransactionType? transactionType,
    int? transactionAmount,
    int? moneyReceived,
    Uint8List? imageEvident,
    String? timestamp,
    List<TransactionItem>? items,
  }) {
    return TransactionHistory(
      idTransactionHistory: idTransactionHistory ?? this.idTransactionHistory,
      transactionType: transactionType ?? this.transactionType,
      transactionAmount: transactionAmount ?? this.transactionAmount,
      moneyReceived: moneyReceived ?? this.moneyReceived,
      imageEvident: imageEvident ?? this.imageEvident,
      timestamp: timestamp ?? this.timestamp,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [
        idTransactionHistory,
        transactionType,
        transactionAmount,
        moneyReceived,
        imageEvident,
        timestamp,
        items,
      ];
}
