import 'package:flutter_test/flutter_test.dart';
import 'package:the_djenggot/models/type/menu_type.dart';

void main() {
  group('MenuType', () {
    const testMenuType = MenuType(
      idMenuType: 'type-1',
      menuTypeName: 'Food',
      menuTypeIcon: 'food_icon',
    );

    const testMap = {
      'id_menu_type': 'type-1',
      'menu_type_name': 'Food',
      'menu_type_icon': 'food_icon',
    };

    group('Constructor', () {
      test('creates MenuType with valid parameters', () {
        expect(testMenuType.idMenuType, equals('type-1'));
        expect(testMenuType.menuTypeName, equals('Food'));
        expect(testMenuType.menuTypeIcon, equals('food_icon'));
      });

      test('creates MenuType with empty strings', () {
        const emptyMenuType = MenuType(
          idMenuType: '',
          menuTypeName: '',
          menuTypeIcon: '',
        );

        expect(emptyMenuType.idMenuType, equals(''));
        expect(emptyMenuType.menuTypeName, equals(''));
        expect(emptyMenuType.menuTypeIcon, equals(''));
      });
    });

    group('fromMap', () {
      test('creates MenuType from valid map', () {
        final menuType = MenuType.fromMap(testMap);

        expect(menuType.idMenuType, equals('type-1'));
        expect(menuType.menuTypeName, equals('Food'));
        expect(menuType.menuTypeIcon, equals('food_icon'));
      });

      test('creates MenuType from map with null values', () {
        final mapWithNulls = {
          'id_menu_type': null,
          'menu_type_name': null,
          'menu_type_icon': null,
        };

        expect(() => MenuType.fromMap(mapWithNulls), throwsA(isA<TypeError>()));
      });

      test('creates MenuType from empty map', () {
        final emptyMap = <String, dynamic>{};

        expect(() => MenuType.fromMap(emptyMap), throwsA(isA<TypeError>()));
      });
    });

    group('toMap', () {
      test('converts MenuType to map correctly', () {
        final map = testMenuType.toMap();

        expect(map, equals(testMap));
      });

      test('converts MenuType with empty values to map', () {
        const emptyMenuType = MenuType(
          idMenuType: '',
          menuTypeName: '',
          menuTypeIcon: '',
        );

        final map = emptyMenuType.toMap();

        expect(map, equals({
          'id_menu_type': '',
          'menu_type_name': '',
          'menu_type_icon': '',
        }));
      });
    });

    group('Serialization', () {
      test('fromMap and toMap are reversible', () {
        const originalMenuType = testMenuType;
        final map = originalMenuType.toMap();
        final reconstructedMenuType = MenuType.fromMap(map);

        expect(reconstructedMenuType, equals(originalMenuType));
      });
    });

    group('Equality and HashCode', () {
      test('two MenuTypes with same properties are equal', () {
        const menuType1 = MenuType(
          idMenuType: 'type-1',
          menuTypeName: 'Food',
          menuTypeIcon: 'food_icon',
        );

        const menuType2 = MenuType(
          idMenuType: 'type-1',
          menuTypeName: 'Food',
          menuTypeIcon: 'food_icon',
        );

        expect(menuType1, equals(menuType2));
        expect(menuType1.hashCode, equals(menuType2.hashCode));
      });

      test('two MenuTypes with different properties are not equal', () {
        const menuType1 = MenuType(
          idMenuType: 'type-1',
          menuTypeName: 'Food',
          menuTypeIcon: 'food_icon',
        );

        const menuType2 = MenuType(
          idMenuType: 'type-2',
          menuTypeName: 'Drink',
          menuTypeIcon: 'drink_icon',
        );

        expect(menuType1, isNot(equals(menuType2)));
        expect(menuType1.hashCode, isNot(equals(menuType2.hashCode)));
      });

      test('MenuType with different idMenuType are not equal', () {
        const menuType1 = MenuType(
          idMenuType: 'type-1',
          menuTypeName: 'Food',
          menuTypeIcon: 'food_icon',
        );

        const menuType2 = MenuType(
          idMenuType: 'type-2',
          menuTypeName: 'Food',
          menuTypeIcon: 'food_icon',
        );

        expect(menuType1, isNot(equals(menuType2)));
      });
    });

    group('Props', () {
      test('props contains all properties', () {
        expect(testMenuType.props, equals([
          'type-1',
          'Food',
          'food_icon',
        ]));
      });
    });

    group('Edge Cases', () {
      test('handles very long strings', () {
        final longString = 'a' * 1000;
        final menuType = MenuType(
          idMenuType: longString,
          menuTypeName: longString,
          menuTypeIcon: longString,
        );

        expect(menuType.idMenuType, equals(longString));
        expect(menuType.menuTypeName, equals(longString));
        expect(menuType.menuTypeIcon, equals(longString));
      });

      test('handles special characters', () {
        const menuType = MenuType(
          idMenuType: 'type-1!@#\$%^&*()',
          menuTypeName: 'Food & Beverages 🍔🥤',
          menuTypeIcon: 'icon_with_special_chars_éàü',
        );

        expect(menuType.idMenuType, equals('type-1!@#\$%^&*()'));
        expect(menuType.menuTypeName, equals('Food & Beverages 🍔🥤'));
        expect(menuType.menuTypeIcon, equals('icon_with_special_chars_éàü'));
      });
    });
  });
} 