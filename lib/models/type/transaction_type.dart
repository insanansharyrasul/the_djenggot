import 'package:equatable/equatable.dart';

class TransactionType extends Equatable {
  final String idTransactionType;
  final String transactionTypeName;
  final String transactionTypeIcon;
  final bool needEvidence;

  const TransactionType({
    required this.idTransactionType,
    required this.transactionTypeName,
    required this.transactionTypeIcon,
    this.needEvidence = true,
  });

  factory TransactionType.fromMap(Map<String, dynamic> map) {
    return TransactionType(
      idTransactionType: map['id_transaction_type'],
      transactionTypeName: map['transaction_type_name'],
      transactionTypeIcon: map['transaction_type_icon'],
      needEvidence: map['need_evidence'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaction_type': idTransactionType,
      'transaction_type_name': transactionTypeName,
      'transaction_type_icon': transactionTypeIcon,
      'need_evidence': needEvidence ? 1 : 0,
    };
  }

  TransactionType copyWith({
    String? idTransactionType,
    String? transactionTypeName,
    String? transactionTypeIcon,
  }) {
    return TransactionType(
      idTransactionType: idTransactionType ?? this.idTransactionType,
      transactionTypeName: transactionTypeName ?? this.transactionTypeName,
      transactionTypeIcon: transactionTypeIcon ?? this.transactionTypeIcon,
    );
  }

  @override
  List<Object?> get props => [idTransactionType, transactionTypeName, transactionTypeIcon];
}
