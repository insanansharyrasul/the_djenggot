import 'package:the_djenggot/models/menu.dart';

abstract class MenuState {}

class MenuLoading extends MenuState {}

class MenuLoaded extends MenuState {
  final List<Menu> menus;
  MenuLoaded(this.menus);
}

class MenuError extends MenuState {
  final String message;

  MenuError(this.message);
}
