import 'dart:typed_data';

abstract class MenuEvent {}

class LoadMenu extends MenuEvent {}

class AddMenu extends MenuEvent {
  final String menuName;
  final double menuPrice;
  final Uint8List menuImage;
  AddMenu({
    required this.menuName,
    required this.menuPrice,
    required this.menuImage,
  });
}

class UpdateMenu extends MenuEvent {
  final String id;
  final String newName;
  final double price;
  UpdateMenu(this.id, this.newName, this.price);
}

class DeleteMenu extends MenuEvent {
  final String id;
  DeleteMenu(this.id);
}