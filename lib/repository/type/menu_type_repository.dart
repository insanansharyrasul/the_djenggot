import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:uuid/uuid.dart';

class MenuTypeRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<MenuType>> getAllMenuTypes() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('MENU_TYPE', '', []);
    return maps.map((map) => MenuType.fromMap(map)).toList();
  }

  Future<List<MenuType>> searchMenuTypes(String query) async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery(
      'MENU_TYPE',
      'menu_type_name LIKE ?',
      ['%$query%'],
    );
    return maps.map((map) => MenuType.fromMap(map)).toList();
  }

  Future<int> addMenuType(String name, {String? icon}) async {
    final String uniqueId = "menu-type-${const Uuid().v4()}";
    return await _databaseHelper.insertQuery(
      'MENU_TYPE',
      {
        'id_menu_type': uniqueId,
        'menu_type_name': name,
        'menu_type_icon': icon,
      },
    );
  }

  Future<int> updateMenuType(MenuType menuType, String newName, {String? icon}) async {
    return await _databaseHelper.updateQuery(
      'MENU_TYPE',
      {
        'menu_type_name': newName,
        'menu_type_icon': icon ?? menuType.menuTypeIcon,
      },
      menuType.idMenuType,
    );
  }

  Future<int> deleteMenuType(String id) async {
    return await _databaseHelper.deleteQuery('MENU_TYPE', id);
  }
}
