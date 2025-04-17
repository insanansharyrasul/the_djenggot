import 'package:equatable/equatable.dart';

class TransactionType extends Equatable {
  final String idTransactionType;
  final String stockName;
  final String? stockIcon;

  const TransactionType({required this.idTransactionType, required this.stockName, this.stockIcon});

  factory TransactionType.fromMap(Map<String, dynamic> map) {
    return TransactionType(
      idTransactionType: map['id_transaction_type'],
      stockName: map['stock_name'],
      stockIcon: map['stock_icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaction_type': idTransactionType,
      'stock_name': stockName,
      'stock_icon': stockIcon,
    };
  }

  @override
  List<Object?> get props => [idTransactionType, stockName, stockIcon];
}
