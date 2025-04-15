import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/type/menu_type.dart';

abstract class MenuTypeState extends Equatable {
  const MenuTypeState();

  @override
  List<Object?> get props => [];
}

class MenuTypeLoading extends MenuTypeState {}

class MenuTypeLoaded extends MenuTypeState {
  final List<MenuType> menuTypes;

  const MenuTypeLoaded(this.menuTypes);

  @override
  List<Object?> get props => [menuTypes];
}

class MenuTypeError extends MenuTypeState {
  final String message;

  const MenuTypeError(this.message);

  @override
  List<Object?> get props => [message];
}
