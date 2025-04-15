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
      id: map['id_stock'],
      name: map['name'],
      quantity: map['quantity'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
    };
  }
}
