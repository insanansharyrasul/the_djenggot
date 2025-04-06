import 'dart:typed_data';

class Menu {
  final String id;
  final String name;
  final double price;
  final Uint8List? image;
  Menu({
    required this.id,
    required this.name,
    this.price = 0,
    this.image
  });

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      image: map['image'] != null ? Uint8List.fromList(map['image']) : null,
    );
  }
}
