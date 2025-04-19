import 'dart:typed_data';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:equatable/equatable.dart';

class TransactionHistory extends Equatable {
  final String idTransactionHistory;
  final TransactionType transactionType;
  final double transactionAmount;
  final Uint8List imageEvident;
  final String timestamp;
  final List<TransactionItem>? items;

  const TransactionHistory({
    required this.idTransactionHistory,
    required this.transactionType,
    required this.transactionAmount,
    required this.imageEvident,
    required this.timestamp,
    this.items,
  });

  factory TransactionHistory.fromMap(Map<String, dynamic> map) {
    return TransactionHistory(
      idTransactionHistory: map['id_transaction_history'] ?? '',
      transactionType: map['id_transaction_type'] is Map
          ? TransactionType.fromMap(map['id_transaction_type'])
          : TransactionType(
              idTransactionType: map['id_transaction_type'] ?? '',
              transactionTypeName: map['transaction_type_name'] ?? '',
              transactionTypeIcon: map['transaction_type_icon'],
            ),
      transactionAmount: (map['transaction_amount'] ?? 0).toDouble(),
      imageEvident: map['image_evident'] != null
          ? map['image_evident'] is Uint8List
              ? map['image_evident']
              : Uint8List.fromList(map['image_evident'])
          : Uint8List(0),
      timestamp: map['timestamp'] ?? '',
      items: map['items'] != null
          ? (map['items'] as List).map((item) => TransactionItem.fromMap(item)).toList()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaction_history': idTransactionHistory,
      'id_transaction_type': transactionType.idTransactionType,
      'transaction_amount': transactionAmount,
      'image_evident': imageEvident,
      'timestamp': timestamp,
    };
  }

  TransactionHistory copyWith({
    String? idTransactionHistory,
    TransactionType? transactionType,
    double? transactionAmount,
    Uint8List? imageEvident,
    String? timestamp,
    List<TransactionItem>? items,
  }) {
    return TransactionHistory(
      idTransactionHistory: idTransactionHistory ?? this.idTransactionHistory,
      transactionType: transactionType ?? this.transactionType,
      transactionAmount: transactionAmount ?? this.transactionAmount,
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
        imageEvident,
        timestamp,
        items,
      ];
}
