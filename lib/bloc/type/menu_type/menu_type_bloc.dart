import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/repository/type/menu_type_repository.dart';

class MenuTypeBloc extends Bloc<MenuTypeEvent, MenuTypeState> {
  final MenuTypeRepository _repository;

  MenuTypeBloc(this._repository) : super(MenuTypeLoading()) {
    on<LoadMenuTypes>((event, emit) async {
      emit(MenuTypeLoading());
      try {
        final menuTypes = await _repository.getAllMenuTypes();
        emit(MenuTypeLoaded(menuTypes));
      } catch (e) {
        emit(MenuTypeError(e.toString()));
      }
    });

    on<AddMenuType>((event, emit) async {
      try {
        await _repository.addMenuType(event.name, icon: event.icon);
        final menuTypes = await _repository.getAllMenuTypes();
        emit(MenuTypeLoaded(menuTypes));
      } catch (e) {
        emit(MenuTypeError(e.toString()));
      }
    });

    on<UpdateMenuType>((event, emit) async {
      try {
        await _repository.updateMenuType(event.menuType, event.newName, icon: event.icon);
        final menuTypes = await _repository.getAllMenuTypes();
        emit(MenuTypeLoaded(menuTypes));
      } catch (e) {
        emit(MenuTypeError(e.toString()));
      }
    });

    on<DeleteMenuType>((event, emit) async {
      try {
        await _repository.deleteMenuType(event.id);
        final menuTypes = await _repository.getAllMenuTypes();
        emit(MenuTypeLoaded(menuTypes));
      } catch (e) {
        emit(MenuTypeError(e.toString()));
      }
    });

    on<SearchMenuTypes>((event, emit) async {
      try {
        final menuTypes = await _repository.searchMenuTypes(event.query);
        emit(MenuTypeLoaded(menuTypes));
      } catch (e) {
        emit(MenuTypeError(e.toString()));
      }
    });
  }
}
