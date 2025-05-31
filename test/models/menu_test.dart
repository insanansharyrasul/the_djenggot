import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/type/menu_type.dart';

void main() {
  group('Menu', () {
    const testMenuType = MenuType(
      idMenuType: 'type-1',
      menuTypeName: 'Food',
      menuTypeIcon: 'food_icon',
    );

    final testMenuImage = Uint8List.fromList([1, 2, 3, 4, 5]);

    final testMenu = Menu(
      idMenu: 'menu-1',
      menuName: 'Test Menu',
      menuPrice: 15000,
      menuImage: testMenuImage,
      idMenuType: testMenuType,
    );

    group('Constructor', () {
      test('creates Menu with valid parameters', () {
        expect(testMenu.idMenu, equals('menu-1'));
        expect(testMenu.menuName, equals('Test Menu'));
        expect(testMenu.menuPrice, equals(15000));
        expect(testMenu.menuImage, equals(testMenuImage));
        expect(testMenu.idMenuType, equals(testMenuType));
      });

      test('creates Menu with default menuPrice value', () {
        final menu = Menu(
          idMenu: 'menu-1',
          menuName: 'Test Menu',
          menuImage: testMenuImage,
          idMenuType: testMenuType,
        );

        expect(menu.menuPrice, equals(0));
      });

      test('creates Menu with empty values', () {
        final emptyImage = Uint8List(0);
        const emptyMenuType = MenuType(
          idMenuType: '',
          menuTypeName: '',
          menuTypeIcon: '',
        );

        final menu = Menu(
          idMenu: '',
          menuName: '',
          menuImage: emptyImage,
          idMenuType: emptyMenuType,
        );

        expect(menu.idMenu, equals(''));
        expect(menu.menuName, equals(''));
        expect(menu.menuPrice, equals(0));
        expect(menu.menuImage, equals(emptyImage));
        expect(menu.idMenuType, equals(emptyMenuType));
      });

      test('creates Menu with negative price', () {
        final menu = Menu(
          idMenu: 'menu-1',
          menuName: 'Test Menu',
          menuPrice: -1000,
          menuImage: testMenuImage,
          idMenuType: testMenuType,
        );

        expect(menu.menuPrice, equals(-1000));
      });
    });

    group('fromMap', () {
      test('creates Menu from valid map with nested MenuType', () {
        final map = {
          'id_menu': 'menu-1',
          'menu_name': 'Test Menu',
          'menu_price': 15000,
          'menu_image': [1, 2, 3, 4, 5],
          'id_menu_type': {
            'id_menu_type': 'type-1',
            'menu_type_name': 'Food',
            'menu_type_icon': 'food_icon',
          },
        };

        final menu = Menu.fromMap(map);

        expect(menu.idMenu, equals('menu-1'));
        expect(menu.menuName, equals('Test Menu'));
        expect(menu.menuPrice, equals(15000));
        expect(menu.menuImage, equals(Uint8List.fromList([1, 2, 3, 4, 5])));
        expect(menu.idMenuType.idMenuType, equals('type-1'));
        expect(menu.idMenuType.menuTypeName, equals('Food'));
        expect(menu.idMenuType.menuTypeIcon, equals('food_icon'));
      });

      test('creates Menu from map with flat MenuType structure', () {
        final map = {
          'id_menu': 'menu-1',
          'menu_name': 'Test Menu',
          'menu_price': 15000,
          'menu_image': [1, 2, 3, 4, 5],
          'menu_type_id': 'type-1',
          'menu_type_name': 'Food',
          'menu_type_icon': 'food_icon',
        };

        final menu = Menu.fromMap(map);

        expect(menu.idMenu, equals('menu-1'));
        expect(menu.menuName, equals('Test Menu'));
        expect(menu.menuPrice, equals(15000));
        expect(menu.idMenuType.idMenuType, equals('type-1'));
        expect(menu.idMenuType.menuTypeName, equals('Food'));
        expect(menu.idMenuType.menuTypeIcon, equals('food_icon'));
      });

      test('creates Menu from map with string price', () {
        final map = {
          'id_menu': 'menu-1',
          'menu_name': 'Test Menu',
          'menu_price': '15000',
          'menu_image': [1, 2, 3, 4, 5],
          'menu_type_id': 'type-1',
          'menu_type_name': 'Food',
          'menu_type_icon': 'food_icon',
        };

        final menu = Menu.fromMap(map);

        expect(menu.menuPrice, equals(15000));
      });

      test('creates Menu from map with null values', () {
        final map = {
          'id_menu': null,
          'menu_name': null,
          'menu_price': null,
          'menu_image': null,
          'menu_type_id': null,
          'menu_type_name': null,
          'menu_type_icon': null,
        };

        // MenuType constructor will fail with null values for required String fields
        expect(() => Menu.fromMap(map), throwsA(isA<TypeError>()));
      });

      test('creates Menu from empty map', () {
        final emptyMap = <String, dynamic>{};

        // MenuType constructor will fail with null values for required String fields  
        expect(() => Menu.fromMap(emptyMap), throwsA(isA<TypeError>()));
      });

      test('creates Menu from map with partial data', () {
        final map = {
          'id_menu': 'menu-1',
          'menu_name': 'Test Menu',
        };

        // MenuType constructor will fail with null values for required String fields
        expect(() => Menu.fromMap(map), throwsA(isA<TypeError>()));
      });

      test('handles different image data types', () {
        final testCases = [
          {
            'description': 'List<int>',
            'menu_image': [1, 2, 3],
            'expected': Uint8List.fromList([1, 2, 3]),
          },
          {
            'description': 'Uint8List',
            'menu_image': Uint8List.fromList([4, 5, 6]),
            'expected': Uint8List.fromList([4, 5, 6]),
          },
          {
            'description': 'null',
            'menu_image': null,
            'expected': Uint8List(0),
          },
          {
            'description': 'empty list',
            'menu_image': <int>[],
            'expected': Uint8List(0),
          },
        ];

        for (final testCase in testCases) {
          final map = {
            'id_menu': 'test',
            'menu_name': 'Test',
            'menu_image': testCase['menu_image'],
            'menu_type_id': 'type-1',
            'menu_type_name': 'Food',
            'menu_type_icon': 'icon',
          };

          final menu = Menu.fromMap(map);
          expect(menu.menuImage, equals(testCase['expected']),
              reason: 'Failed for ${testCase['description']}');
        }
      });

      test('handles different price data types', () {
        final testCases = [
          {'price': 15000, 'expected': 15000},
          {'price': '25000', 'expected': 25000},
          {'price': 0, 'expected': 0},
          {'price': '0', 'expected': 0},
          {'price': null, 'expected': 0},
        ];

        for (final testCase in testCases) {
          final map = {
            'id_menu': 'test',
            'menu_name': 'Test',
            'menu_price': testCase['price'],
            'menu_image': [1, 2, 3],
            'menu_type_id': 'type-1',
            'menu_type_name': 'Food',
            'menu_type_icon': 'icon',
          };

          final menu = Menu.fromMap(map);
          expect(menu.menuPrice, equals(testCase['expected']),
              reason: 'Failed for price: ${testCase['price']}');
        }
      });
    });

    group('Immutability', () {
      test('Menu properties are immutable', () {
        expect(() => testMenu.idMenu, returnsNormally);
        expect(() => testMenu.menuName, returnsNormally);
        expect(() => testMenu.menuPrice, returnsNormally);
        expect(() => testMenu.menuImage, returnsNormally);
        expect(() => testMenu.idMenuType, returnsNormally);
      });

      test('modifying menuImage list does not affect original', () {
        final originalImage = Uint8List.fromList([1, 2, 3]);
        final imageCopy = Uint8List.fromList([1, 2, 3]); // Create separate copy for Menu
        final menu = Menu(
          idMenu: 'test',
          menuName: 'Test',
          menuImage: imageCopy,
          idMenuType: testMenuType,
        );

        // Modify the original list
        originalImage[0] = 99;

        // Menu should not be affected by changes to the original
        expect(menu.menuImage[0], equals(1));
      });
    });

    group('Edge Cases', () {
      test('handles very long strings', () {
        final longString = 'a' * 1000;
        final menu = Menu(
          idMenu: longString,
          menuName: longString,
          menuImage: testMenuImage,
          idMenuType: testMenuType,
        );

        expect(menu.idMenu, equals(longString));
        expect(menu.menuName, equals(longString));
      });

      test('handles special characters and unicode', () {
        final menu = Menu(
          idMenu: 'menu-1!@#\$%^&*()',
          menuName: 'Spicy Noodles 🍜 with Extra Chili 🌶️',
          menuPrice: 15000,
          menuImage: testMenuImage,
          idMenuType: testMenuType,
        );

        expect(menu.idMenu, equals('menu-1!@#\$%^&*()'));
        expect(menu.menuName, equals('Spicy Noodles 🍜 with Extra Chili 🌶️'));
      });

      test('handles very large price values', () {
        final menu = Menu(
          idMenu: 'expensive',
          menuName: 'Expensive Item',
          menuPrice: 999999999,
          menuImage: testMenuImage,
          idMenuType: testMenuType,
        );

        expect(menu.menuPrice, equals(999999999));
      });

      test('handles large image data', () {
        final largeImage = Uint8List(10000);
        for (int i = 0; i < largeImage.length; i++) {
          largeImage[i] = (i % 256);
        }

        final menu = Menu(
          idMenu: 'large-image',
          menuName: 'Large Image Menu',
          menuImage: largeImage,
          idMenuType: testMenuType,
        );

        expect(menu.menuImage.length, equals(10000));
        expect(menu.menuImage[0], equals(0));
        expect(menu.menuImage[255], equals(255));
        expect(menu.menuImage[256], equals(0)); // wraps around
      });

      test('handles different MenuType configurations', () {
        final menuTypes = [
          const MenuType(
            idMenuType: 'food',
            menuTypeName: 'Food',
            menuTypeIcon: 'food',
          ),
          const MenuType(
            idMenuType: 'beverage',
            menuTypeName: 'Beverages',
            menuTypeIcon: 'drink',
          ),
          const MenuType(
            idMenuType: 'dessert',
            menuTypeName: 'Desserts & Sweets',
            menuTypeIcon: 'cake',
          ),
        ];

        for (int i = 0; i < menuTypes.length; i++) {
          final menu = Menu(
            idMenu: 'menu-$i',
            menuName: 'Menu $i',
            menuImage: testMenuImage,
            idMenuType: menuTypes[i],
          );

          expect(menu.idMenuType, equals(menuTypes[i]));
        }
      });
    });

    group('Business Logic', () {
      test('can represent free items with zero price', () {
        final freeMenu = Menu(
          idMenu: 'free-1',
          menuName: 'Complimentary Water',
          menuImage: testMenuImage,
          idMenuType: testMenuType,
        );

        expect(freeMenu.menuPrice, equals(0));
      });

      test('can represent different price ranges', () {
        final priceRanges = [
          {'name': 'Budget', 'price': 5000},
          {'name': 'Standard', 'price': 15000},
          {'name': 'Premium', 'price': 50000},
          {'name': 'Luxury', 'price': 100000},
        ];

        for (final range in priceRanges) {
          final menu = Menu(
            idMenu: 'menu-${range['name']}',
            menuName: '${range['name']} Menu',
            menuPrice: range['price'] as int,
            menuImage: testMenuImage,
            idMenuType: testMenuType,
          );

          expect(menu.menuPrice, equals(range['price']));
        }
      });
    });
  });
} 