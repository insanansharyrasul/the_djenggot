import 'dart:typed_data';

import 'package:the_djenggot/models/menu.dart';

abstract class MenuEvent {}

class LoadMenu extends MenuEvent {}

class AddMenu extends MenuEvent {
  final String menuName;
  final int menuPrice;
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
  final Menu menu;
  final String newName;
  final int newPrice;
  final String newMenuType;
  final Uint8List? newMenuImage;
  UpdateMenu(this.menu, this.newName, this.newPrice, this.newMenuType, this.newMenuImage);
}

class DeleteMenu extends MenuEvent {
  final String id;
  DeleteMenu(this.id);
}

class LoadMenuById extends MenuEvent {
  final String id;
  LoadMenuById(this.id);
}