import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/repository/menu_repository.dart';

// Mock classes
class MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  group('MenuBloc', () {
    late MenuBloc menuBloc;
    late MockMenuRepository mockMenuRepository;

    // Test data
    const menuType = MenuType(
      idMenuType: 'type-1',
      menuTypeName: 'Food',
      menuTypeIcon: 'food_icon',
    );

    final testMenu = Menu(
      idMenu: 'menu-1',
      menuName: 'Test Menu',
      menuPrice: 15000,
      menuImage: Uint8List.fromList([1, 2, 3, 4]),
      idMenuType: menuType,
    );

    final testMenus = [testMenu];

    setUp(() {
      mockMenuRepository = MockMenuRepository();
      menuBloc = MenuBloc(mockMenuRepository);
    });

    tearDown(() {
      menuBloc.close();
    });

    test('initial state is MenuLoading', () {
      expect(menuBloc.state, isA<MenuLoading>());
    });

    group('LoadMenu', () {
      blocTest<MenuBloc, MenuState>(
        'emits [MenuLoading, MenuLoaded] when LoadMenu is successful',
        build: () {
          when(() => mockMenuRepository.getMenusWithTypeObjects())
              .thenAnswer((_) async => testMenus);
          return menuBloc;
        },
        act: (bloc) => bloc.add(LoadMenu()),
        expect: () => [
          isA<MenuLoading>(),
          isA<MenuLoaded>().having(
            (state) => state.menus,
            'menus',
            equals(testMenus),
          ),
        ],
        verify: (_) {
          verify(() => mockMenuRepository.getMenusWithTypeObjects()).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'emits [MenuLoading, MenuLoaded] with empty list when no menus found',
        build: () {
          when(() => mockMenuRepository.getMenusWithTypeObjects())
              .thenAnswer((_) async => <Menu>[]);
          return menuBloc;
        },
        act: (bloc) => bloc.add(LoadMenu()),
        expect: () => [
          isA<MenuLoading>(),
          isA<MenuLoaded>().having(
            (state) => state.menus,
            'menus',
            isEmpty,
          ),
        ],
      );
    });

    group('AddMenu', () {
      final newMenuImage = Uint8List.fromList([5, 6, 7, 8]);
      final addMenuEvent = AddMenu(
        menuName: 'New Menu',
        menuPrice: 20000,
        menuType: 'type-1',
        menuImage: newMenuImage,
      );

      blocTest<MenuBloc, MenuState>(
        'emits [MenuLoading, MenuLoaded] when AddMenu is successful',
        build: () {
          when(() => mockMenuRepository.addMenu(any()))
              .thenAnswer((_) async => 1);
          when(() => mockMenuRepository.getMenusWithTypeObjects())
              .thenAnswer((_) async => testMenus);
          return menuBloc;
        },
        act: (bloc) => bloc.add(addMenuEvent),
        expect: () => [
          isA<MenuLoading>(),
          isA<MenuLoaded>().having(
            (state) => state.menus,
            'menus',
            equals(testMenus),
          ),
        ],
        verify: (_) {
          verify(() => mockMenuRepository.addMenu(any())).called(1);
          verify(() => mockMenuRepository.getMenusWithTypeObjects()).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'calls addMenu with correct parameters',
        build: () {
          when(() => mockMenuRepository.addMenu(any()))
              .thenAnswer((_) async => 1);
          when(() => mockMenuRepository.getMenusWithTypeObjects())
              .thenAnswer((_) async => testMenus);
          return menuBloc;
        },
        act: (bloc) => bloc.add(addMenuEvent),
        verify: (_) {
          final capturedArgs = verify(() => mockMenuRepository.addMenu(captureAny()))
              .captured.first as Map<String, dynamic>;
          
          expect(capturedArgs['menu_name'], equals('New Menu'));
          expect(capturedArgs['menu_price'], equals(20000));
          expect(capturedArgs['id_menu_type'], equals('type-1'));
          expect(capturedArgs['menu_image'], equals(newMenuImage));
          expect(capturedArgs['id_menu'], startsWith('menu-'));
        },
      );
    });

    group('UpdateMenu', () {
      final updatedMenuImage = Uint8List.fromList([9, 10, 11, 12]);
      final updateMenuEvent = UpdateMenu(
        testMenu,
        'Updated Menu',
        25000,
        'type-2',
        updatedMenuImage,
      );

      blocTest<MenuBloc, MenuState>(
        'emits [MenuLoading, MenuLoaded] when UpdateMenu is successful',
        build: () {
          when(() => mockMenuRepository.updateMenu(any(), any()))
              .thenAnswer((_) async => 1);
          when(() => mockMenuRepository.getMenusWithTypeObjects())
              .thenAnswer((_) async => testMenus);
          return menuBloc;
        },
        seed: () => MenuLoaded(testMenus),
        act: (bloc) => bloc.add(updateMenuEvent),
        expect: () => [
          isA<MenuLoading>(),
          isA<MenuLoaded>(),
        ],
        verify: (_) {
          verify(() => mockMenuRepository.updateMenu(any(), testMenu.idMenu)).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'calls updateMenu with correct parameters',
        build: () {
          when(() => mockMenuRepository.updateMenu(any(), any()))
              .thenAnswer((_) async => 1);
          when(() => mockMenuRepository.getMenusWithTypeObjects())
              .thenAnswer((_) async => testMenus);
          return menuBloc;
        },
        seed: () => MenuLoaded(testMenus),
        act: (bloc) => bloc.add(updateMenuEvent),
        verify: (_) {
          final capturedArgs = verify(() => mockMenuRepository.updateMenu(
            captureAny(),
            testMenu.idMenu,
          )).captured.first as Map<String, dynamic>;
          
          expect(capturedArgs['id_menu'], equals(testMenu.idMenu));
          expect(capturedArgs['menu_name'], equals('Updated Menu'));
          expect(capturedArgs['menu_price'], equals(25000));
          expect(capturedArgs['id_menu_type'], equals('type-2'));
          expect(capturedArgs['menu_image'], equals(updatedMenuImage));
        },
      );
    });

    group('DeleteMenu', () {
      const menuIdToDelete = 'menu-1';
      final deleteMenuEvent = DeleteMenu(menuIdToDelete);

      blocTest<MenuBloc, MenuState>(
        'emits [MenuLoading, MenuLoaded] when DeleteMenu is successful',
        build: () {
          when(() => mockMenuRepository.deleteMenu(any()))
              .thenAnswer((_) async => 1);
          return menuBloc;
        },
        seed: () => MenuLoaded(testMenus),
        act: (bloc) => bloc.add(deleteMenuEvent),
        expect: () => [
          isA<MenuLoading>(),
          isA<MenuLoaded>().having(
            (state) => state.menus,
            'menus',
            isEmpty, // Menu should be removed from cached list
          ),
        ],
        verify: (_) {
          verify(() => mockMenuRepository.deleteMenu(menuIdToDelete)).called(1);
        },
      );

      blocTest<MenuBloc, MenuState>(
        'removes menu from cached list without repository call when menu exists in cache',
        build: () {
          when(() => mockMenuRepository.deleteMenu(any()))
              .thenAnswer((_) async => 1);
          return menuBloc;
        },
        seed: () => MenuLoaded(testMenus),
        act: (bloc) => bloc.add(deleteMenuEvent),
        expect: () => [
          isA<MenuLoading>(),
          isA<MenuLoaded>().having(
            (state) => state.menus.length,
            'menus length',
            equals(0),
          ),
        ],
      );
    });

    group('State transitions', () {
      blocTest<MenuBloc, MenuState>(
        'maintains state consistency during multiple operations',
        build: () {
          when(() => mockMenuRepository.getMenusWithTypeObjects())
              .thenAnswer((_) async => testMenus);
          when(() => mockMenuRepository.deleteMenu(any()))
              .thenAnswer((_) async => 1);
          return menuBloc;
        },
        act: (bloc) {
          bloc.add(LoadMenu());
          bloc.add(DeleteMenu('menu-1'));
        },
        expect: () => [
          isA<MenuLoading>(),
          isA<MenuLoaded>(),
          isA<MenuLoading>(),
          isA<MenuLoaded>(),
        ],
      );
    });
  });
} 