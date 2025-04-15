import 'package:equatable/equatable.dart';
import 'package:the_djenggot/models/type/menu_type.dart';

abstract class MenuTypeEvent extends Equatable {
  const MenuTypeEvent();

  @override
  List<Object?> get props => [];
}

class LoadMenuTypes extends MenuTypeEvent {}

class AddMenuType extends MenuTypeEvent {
  final String name;

  const AddMenuType(this.name);

  @override
  List<Object?> get props => [name];
}

class UpdateMenuType extends MenuTypeEvent {
  final MenuType menuType;
  final String newName;

  const UpdateMenuType(this.menuType, this.newName);

  @override
  List<Object?> get props => [menuType, newName];
}

class DeleteMenuType extends MenuTypeEvent {
  final String id;

  const DeleteMenuType(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchMenuTypes extends MenuTypeEvent {
  final String query;

  const SearchMenuTypes(this.query);

  @override
  List<Object?> get props => [query];
}
