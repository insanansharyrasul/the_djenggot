import 'package:equatable/equatable.dart';

class TransactionType extends Equatable {
  final String id;
  final String name;

  const TransactionType({required this.id, required this.name});

  factory TransactionType.fromMap(Map<String, dynamic> map) {
    return TransactionType(
      id: map['id_transaction_type'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaction_type': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
