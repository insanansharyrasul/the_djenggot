import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/repository/menu_repository.dart';
import 'package:uuid/uuid.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _menuRepository;
  MenuBloc(this._menuRepository) : super(MenuLoading()) {
    on<LoadMenu>((event, emit) async {
      emit(MenuLoading());
      final menus = await _menuRepository.getMenusWithTypeObjects();
      emit(MenuLoaded(menus));
    });

    on<AddMenu>((event, emit) async {
      final String uniqueId = "menu-${const Uuid().v4()}";
      await _menuRepository.addMenu(
        {
          'id_menu': uniqueId,
          'menu_name': event.menuName,
          'menu_price': event.menuPrice,
          'menu_image': event.menuImage,
          'id_menu_type': event.menuType
        },
      );
    });

    on<UpdateMenu>((event, emit) async {});

    on<DeleteMenu>((event, emit) async {});
  }
}
