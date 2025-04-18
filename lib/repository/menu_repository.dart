import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/menu.dart';

class MenuRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  // Future<List<Menu>> getAllMenus() async {
  //   final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('MENU', '', []);
  //   return maps.map((map) => Menu.fromMap(map)).toList();
  // }
  Future<List<Menu>> getMenusWithTypeObjects() async {
    final List<Map<String, dynamic>> results = await getMenusWithTypes();

    return results.map((map) {
      // Create a MenuType map from the joined data
      final menuTypeMap = {
        'id_menu_type': map['id_menu_type'],
        'menu_type_name': map['menu_type_name'],
        'menu_type_icon': map['menu_type_icon'],
      };

      // Create a modified map with the MenuType as a nested object
      final menuMap = {
        'id_menu': map['id_menu'],
        'menu_name': map['menu_name'],
        'menu_price': map['menu_price'],
        'menu_image': map['menu_image'],
        'id_menu_type': menuTypeMap, // Pass the entire MenuType as a map
      };

      return Menu.fromMap(menuMap);
    }).toList();
  }

  Future<Menu?> getMenuWithType(String menuId) async {
    final db = await _databaseHelper.db;
    final results = await db.rawQuery('''
    SELECT m.id_menu, m.menu_name, m.menu_price, m.menu_image, 
           m.id_menu_type, mt.menu_type_name, mt.menu_type_icon 
    FROM MENU m
    JOIN MENU_TYPE mt ON m.id_menu_type = mt.id_menu_type
    WHERE m.id_menu = ?
  ''', [menuId]);

    if (results.isEmpty) {
      return null;
    }

    final map = results.first;

    // Create a MenuType map from the joined data
    final menuTypeMap = {
      'id_menu_type': map['id_menu_type'],
      'name': map['menu_type_name'],
      'icon': map['menu_type_icon'],
    };

    // Create a modified map with the MenuType as a nested object
    final menuMap = {
      'id_menu': map['id_menu'],
      'name': map['menu_name'],
      'price': map['menu_price'],
      'image': map['menu_image'],
      'id_menu_type': menuTypeMap,
    };

    return Menu.fromMap(menuMap);
  }

  Future<int> addMenu(Map<String, dynamic> model) async {
    return await _databaseHelper.insertQuery(
      'MENU',
      model,
    );
  }

  Future<int> updateMenu(Map<String, dynamic> model, String id) async {
    final db = await _databaseHelper.db;
    return await db.update(
      'MENU',
      model,
      where: 'id_menu = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteMenu(String id) async {
    final db = await _databaseHelper.db;
    return await db.delete(
      'MENU',
      where: 'id_menu = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getMenusWithTypes() async {
    final db = await _databaseHelper.db;
    return await db.rawQuery('''
      SELECT m.*, mt.menu_type_name, mt.menu_type_icon 
      FROM MENU m
      JOIN MENU_TYPE mt ON m.id_menu_type = mt.id_menu_type
    ''');
  }
}
