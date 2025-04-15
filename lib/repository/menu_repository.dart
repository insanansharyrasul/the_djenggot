import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/models/menu.dart';

class MenuRepository {
  final DatabaseHelper _databaseHelper = DatabaseHelper.instance;

  Future<List<Menu>> getAllMenus() async {
    final List<Map<String, dynamic>> maps = await _databaseHelper.getAllQuery('MENU', '', []);
    return maps.map((map) => Menu.fromMap(map)).toList();
  }

  Future<int> addMenu(Map<String, dynamic> model) async {
    return await _databaseHelper.insertQuery(
      'MENU',
      model,
    );
  }

  Future<int> updateMenu(Map<String, dynamic> model, String id) async {
    return await _databaseHelper.updateQuery(
      'MENU',
      model,
      id,
    );
  }

  Future<int> deleteMenu(String id) async {
    return await _databaseHelper.deleteQuery('MENU', id);
  }
}
