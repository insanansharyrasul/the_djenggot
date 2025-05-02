import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/repository/menu_repository.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:uuid/uuid.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _menuRepository;
  List<Menu> _cachedMenus = [];

  MenuBloc(this._menuRepository) : super(MenuLoading()) {
    on<LoadMenu>((event, emit) async {
      emit(MenuLoading());
      _cachedMenus = await _menuRepository.getMenusWithTypeObjects();
      emit(MenuLoaded(_cachedMenus));
    });

    on<AddMenu>((event, emit) async {
      emit(MenuLoading());
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

      _cachedMenus = await _menuRepository.getMenusWithTypeObjects();
      emit(MenuLoaded(_cachedMenus));
    });

    on<UpdateMenu>((event, emit) async {
      emit(MenuLoading());
      await _menuRepository.updateMenu(
        {
          'id_menu': event.menu.idMenu,
          'menu_name': event.newName,
          'menu_price': event.newPrice,
          'menu_image': event.newMenuImage,
          'id_menu_type': event.newMenuType
        },
        event.menu.idMenu,
      );

      final index = _cachedMenus.indexWhere((menu) => menu.idMenu == event.menu.idMenu);
      if (index != -1) {
        final updatedMenu = Menu(
          idMenu: event.menu.idMenu,
          menuName: event.newName,
          menuPrice: event.newPrice,
          menuImage: event.newMenuImage!,
          idMenuType: event.menu.idMenuType,
        );

        _cachedMenus = List.from(_cachedMenus);
        _cachedMenus[index] = updatedMenu;
        emit(MenuLoaded(_cachedMenus));
      } else {
        _cachedMenus = await _menuRepository.getMenusWithTypeObjects();
        emit(MenuLoaded(_cachedMenus));
      }
    });

    on<DeleteMenu>((event, emit) async {
      emit(MenuLoading());
      await _menuRepository.deleteMenu(event.id);

      _cachedMenus = _cachedMenus.where((menu) => menu.idMenu != event.id).toList();
      emit(MenuLoaded(_cachedMenus));
    });
  }
}
