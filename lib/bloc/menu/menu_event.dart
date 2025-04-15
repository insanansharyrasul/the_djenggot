import 'dart:typed_data';

abstract class MenuEvent {}

class LoadMenu extends MenuEvent {}

class AddMenu extends MenuEvent {
  final String menuName;
  final double menuPrice;
  final String menuType;
  final Uint8List menuImage;
  AddMenu({
    required this.menuName,
    required this.menuType,
    required this.menuPrice,
    required this.menuImage,
  });
}

class UpdateMenu extends MenuEvent {
  final String id;
  final String newName;
  final double price;
  final String menuType;
  UpdateMenu(this.id, this.newName, this.price, this.menuType);
}

class DeleteMenu extends MenuEvent {
  final String id;
  DeleteMenu(this.id);
}
