import 'package:equatable/equatable.dart';

class MenuType extends Equatable {
  final String id;
  final String name;
  final String? icon;

  const MenuType({required this.id, required this.name, this.icon});

  factory MenuType.fromMap(Map<String, dynamic> map) {
    return MenuType(
      id: map['id_menu_type'],
      name: map['name'],
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_menu_type': id,
      'name': name,
      'icon': icon,
    };
  }

  @override
  List<Object?> get props => [id, name, icon];
}
