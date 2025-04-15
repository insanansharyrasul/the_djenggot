import 'dart:typed_data';

import 'package:the_djenggot/models/type/menu_type.dart';


class Menu {
  final String idMenu;
  final String name;
  final double price;
  final Uint8List? image;
  final MenuType idMenuType;
  Menu({
    required this.idMenu,
    required this.name,
    this.price = 0,
    this.image,
    required this.idMenuType,
  });

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      idMenu: map['id_menu'],
      name: map['name'],
      price: map['price'],
      image: map['image'] != null ? Uint8List.fromList(map['image']) : null,
      idMenuType: MenuType.fromMap(map['id_menu_type']),
    );
  }
}

