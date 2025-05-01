import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/menu.dart';

class TransactionItem extends Equatable {
  final String idTransactionItem;
  final String idTransactionHistory;
  final Menu menu;
  final int transactionQuantity;

  const TransactionItem({
    required this.idTransactionItem,
    required this.idTransactionHistory,
    required this.menu,
    required this.transactionQuantity,
  });

  factory TransactionItem.fromMap(Map<String, dynamic> map) {
    return TransactionItem(
      idTransactionItem: map['id_transaction_item'] ?? '',
      idTransactionHistory: map['id_transaction_history'] ?? '',
      menu: map['id_menu'] is Map
          ? Menu.fromMap(map['id_menu'])
          : Menu.fromMap(map),
      transactionQuantity: map['transaction_quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaction_item': idTransactionItem,
      'id_transaction_history': idTransactionHistory,
      'id_menu': menu.idMenu,
      'transaction_quantity': transactionQuantity,
    };
  }

  TransactionItem copyWith({
    String? idTransactionItem,
    String? idTransactionHistory,
    Menu? menu,
    int? transactionQuantity,
  }) {
    return TransactionItem(
      idTransactionItem: idTransactionItem ?? this.idTransactionItem,
      idTransactionHistory: idTransactionHistory ?? this.idTransactionHistory,
      menu: menu ?? this.menu,
      transactionQuantity: transactionQuantity ?? this.transactionQuantity,
    );
  }

  @override
  List<Object?> get props => [
        idTransactionItem,
        idTransactionHistory,
        menu,
        transactionQuantity,
      ];
}
