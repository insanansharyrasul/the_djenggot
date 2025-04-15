import 'package:equatable/equatable.dart';

class TransactionType extends Equatable {
  final String id;
  final String name;
  final String? icon;

  const TransactionType({required this.id, required this.name, this.icon});

  factory TransactionType.fromMap(Map<String, dynamic> map) {
    return TransactionType(
      id: map['id_transaction_type'],
      name: map['name'],
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_transaction_type': id,
      'name': name,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [id, name, icon];
}
