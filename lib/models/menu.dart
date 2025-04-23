import 'dart:typed_data';

import 'package:the_djenggot/models/type/menu_type.dart';

class Menu {
  final String idMenu;
  final String menuName;
  final double menuPrice;
  final Uint8List menuImage;
  final MenuType idMenuType;
  Menu({
    required this.idMenu,
    required this.menuName,
    required this.menuImage,
    this.menuPrice = 0,
    required this.idMenuType,
  });

  factory Menu.fromMap(Map<String, dynamic> map) {
    MenuType menuType;
    if (map['id_menu_type'] is Map) {
      menuType = MenuType.fromMap(map['id_menu_type']);
    } else {
      menuType = MenuType(
        idMenuType: map['menu_type_id'],
        menuTypeName: map['menu_type_name'],
        menuTypeIcon: map['menu_type_icon'],
      );
    }

    return Menu(
      idMenu: map['id_menu']?.toString() ?? '',
      menuName: map['menu_name']?.toString() ?? '',
      menuPrice: map['menu_price'] != null ? (map['menu_price']).toDouble() : 0.0,
      menuImage: map['menu_image'] != null ? Uint8List.fromList(map['menu_image']) : Uint8List(0),
      idMenuType: menuType,
    );
  }
}
