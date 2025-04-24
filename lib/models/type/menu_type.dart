import 'package:equatable/equatable.dart';

class MenuType extends Equatable {
  final String idMenuType;
  final String menuTypeName;
  final String menuTypeIcon;

  const MenuType({
    required this.idMenuType,
    required this.menuTypeName,
    required this.menuTypeIcon,
  });

  factory MenuType.fromMap(Map<String, dynamic> map) {
    return MenuType(
      idMenuType: map['id_menu_type'],
      menuTypeName: map['menu_type_name'],
      menuTypeIcon: map['menu_type_icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_menu_type': idMenuType,
      'menu_type_name': menuTypeName,
      'menu_type_icon': menuTypeIcon,
    };
  }

  @override
  List<Object?> get props => [idMenuType, menuTypeName, menuTypeIcon];
}
