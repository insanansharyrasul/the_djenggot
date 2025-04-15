import 'package:equatable/equatable.dart';

class MenuType extends Equatable {
  final String id;
  final String name;

  const MenuType({required this.id, required this.name});

  factory MenuType.fromMap(Map<String, dynamic> map) {
    return MenuType(
      id: map['id_menu_type'],
      name: map['name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_menu_type': id,
      'name': name,
    };
  }

  @override
  List<Object?> get props => [id, name];
}
