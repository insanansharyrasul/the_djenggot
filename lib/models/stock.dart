import 'package:uuid/uuid.dart';

class Stock {
  String id;
  String name;
  int quantity;

  Stock({
    required this.id,
    required this.name,
    required this.quantity,
  });

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      name: map['name'],
      quantity: map['quantity'],
    );
  }

  // factory Stock.create({required String name, required int quantity}) {
  //   final String uniqueId = const Uuid().v4(); // Generate a unique ID
  //   return Stock(
  //     id: uniqueId,
  //     name: name,
  //     quantity: quantity,
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
    };
  }
}
