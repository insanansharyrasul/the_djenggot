import 'dart:typed_data';

import 'package:the_djenggot/models/type/menu_type.dart';

class Menu {
  final String idMenu;
  final String menuName;
  final double menuPrice;
  final Uint8List? menuImage;
  final MenuType idMenuType;
  Menu({
    required this.idMenu,
    required this.menuName,
    this.menuPrice = 0,
    this.menuImage,
    required this.idMenuType,
  });

  factory Menu.fromMap(Map<String, dynamic> map) {
    return Menu(
      idMenu: map['id_menu'] ?? '',
      menuName: map['menu_name'] ?? '',
      menuPrice: (map['menu_price'] ?? 0).toDouble(),
      menuImage: map['image'] != null
          ? Uint8List.fromList(map['image'])
          : map['menu_image'] != null
              ? Uint8List.fromList(map['menu_image'])
              : null,
      idMenuType: map['id_menu_type'] is Map
          ? MenuType.fromMap(map['id_menu_type'])
          : MenuType(
              idMenuType: map['id_menu_type']?.toString() ?? '',
              menuTypeName: map['menu_type_name'] ?? '',
            ),
    );
  }
}
