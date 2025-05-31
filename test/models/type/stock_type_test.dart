import 'package:flutter_test/flutter_test.dart';
import 'package:the_djenggot/models/type/stock_type.dart';

void main() {
  group('StockType', () {
    const testStockType = StockType(
      idStockType: 'type-1',
      stockTypeName: 'Raw Material',
      stockTypeIcon: 'material_icon',
      stockUnit: 'kg',
    );

    const testMap = {
      'id_stock_type': 'type-1',
      'stock_type_name': 'Raw Material',
      'stock_type_icon': 'material_icon',
      'stock_unit': 'kg',
    };

    group('Constructor', () {
      test('creates StockType with valid parameters', () {
        expect(testStockType.idStockType, equals('type-1'));
        expect(testStockType.stockTypeName, equals('Raw Material'));
        expect(testStockType.stockTypeIcon, equals('material_icon'));
        expect(testStockType.stockUnit, equals('kg'));
      });

      test('creates StockType with empty strings', () {
        const emptyStockType = StockType(
          idStockType: '',
          stockTypeName: '',
          stockTypeIcon: '',
          stockUnit: '',
        );

        expect(emptyStockType.idStockType, equals(''));
        expect(emptyStockType.stockTypeName, equals(''));
        expect(emptyStockType.stockTypeIcon, equals(''));
        expect(emptyStockType.stockUnit, equals(''));
      });

      test('creates StockType with different units', () {
        const stockTypes = [
          StockType(
            idStockType: 'type-1',
            stockTypeName: 'Liquid',
            stockTypeIcon: 'liquid_icon',
            stockUnit: 'L',
          ),
          StockType(
            idStockType: 'type-2',
            stockTypeName: 'Piece',
            stockTypeIcon: 'piece_icon',
            stockUnit: 'pcs',
          ),
          StockType(
            idStockType: 'type-3',
            stockTypeName: 'Weight',
            stockTypeIcon: 'weight_icon',
            stockUnit: 'g',
          ),
        ];

        expect(stockTypes[0].stockUnit, equals('L'));
        expect(stockTypes[1].stockUnit, equals('pcs'));
        expect(stockTypes[2].stockUnit, equals('g'));
      });
    });

    group('fromMap', () {
      test('creates StockType from valid map', () {
        final stockType = StockType.fromMap(testMap);

        expect(stockType.idStockType, equals('type-1'));
        expect(stockType.stockTypeName, equals('Raw Material'));
        expect(stockType.stockTypeIcon, equals('material_icon'));
        expect(stockType.stockUnit, equals('kg'));
      });

      test('creates StockType from map with null values', () {
        final mapWithNulls = {
          'id_stock_type': null,
          'stock_type_name': null,
          'stock_type_icon': null,
          'stock_unit': null,
        };

        expect(() => StockType.fromMap(mapWithNulls), throwsA(isA<TypeError>()));
      });

      test('creates StockType from empty map', () {
        final emptyMap = <String, dynamic>{};

        expect(() => StockType.fromMap(emptyMap), throwsA(isA<TypeError>()));
      });

      test('creates StockType from map with partial data', () {
        final partialMap = {
          'id_stock_type': 'type-1',
          'stock_type_name': 'Raw Material',
        };

        expect(() => StockType.fromMap(partialMap), throwsA(isA<TypeError>()));
      });
    });

    group('toMap', () {
      test('converts StockType to map correctly', () {
        final map = testStockType.toMap();

        expect(map, equals(testMap));
      });

      test('converts StockType with empty values to map', () {
        const emptyStockType = StockType(
          idStockType: '',
          stockTypeName: '',
          stockTypeIcon: '',
          stockUnit: '',
        );

        final map = emptyStockType.toMap();

        expect(map, equals({
          'id_stock_type': '',
          'stock_type_name': '',
          'stock_type_icon': '',
          'stock_unit': '',
        }));
      });
    });

    group('Serialization', () {
      test('fromMap and toMap are reversible', () {
        const originalStockType = testStockType;
        final map = originalStockType.toMap();
        final reconstructedStockType = StockType.fromMap(map);

        expect(reconstructedStockType, equals(originalStockType));
      });

      test('round-trip serialization with various units', () {
        const stockTypes = [
          StockType(
            idStockType: 'liquid',
            stockTypeName: 'Liquid',
            stockTypeIcon: 'liquid',
            stockUnit: 'mL',
          ),
          StockType(
            idStockType: 'solid',
            stockTypeName: 'Solid',
            stockTypeIcon: 'solid',
            stockUnit: 'kg',
          ),
        ];

        for (final stockType in stockTypes) {
          final map = stockType.toMap();
          final reconstructed = StockType.fromMap(map);
          expect(reconstructed, equals(stockType));
        }
      });
    });

    group('Equality and HashCode', () {
      test('two StockTypes with same properties are equal', () {
        const stockType1 = StockType(
          idStockType: 'type-1',
          stockTypeName: 'Raw Material',
          stockTypeIcon: 'material_icon',
          stockUnit: 'kg',
        );

        const stockType2 = StockType(
          idStockType: 'type-1',
          stockTypeName: 'Raw Material',
          stockTypeIcon: 'material_icon',
          stockUnit: 'kg',
        );

        expect(stockType1, equals(stockType2));
        expect(stockType1.hashCode, equals(stockType2.hashCode));
      });

      test('two StockTypes with different properties are not equal', () {
        const stockType1 = StockType(
          idStockType: 'type-1',
          stockTypeName: 'Raw Material',
          stockTypeIcon: 'material_icon',
          stockUnit: 'kg',
        );

        const stockType2 = StockType(
          idStockType: 'type-2',
          stockTypeName: 'Liquid',
          stockTypeIcon: 'liquid_icon',
          stockUnit: 'L',
        );

        expect(stockType1, isNot(equals(stockType2)));
        expect(stockType1.hashCode, isNot(equals(stockType2.hashCode)));
      });

      test('StockTypes with different units are not equal', () {
        const stockType1 = StockType(
          idStockType: 'type-1',
          stockTypeName: 'Material',
          stockTypeIcon: 'icon',
          stockUnit: 'kg',
        );

        const stockType2 = StockType(
          idStockType: 'type-1',
          stockTypeName: 'Material',
          stockTypeIcon: 'icon',
          stockUnit: 'g',
        );

        expect(stockType1, isNot(equals(stockType2)));
      });
    });

    group('Props', () {
      test('props contains all properties', () {
        expect(testStockType.props, equals([
          'type-1',
          'Raw Material',
          'material_icon',
          'kg',
        ]));
      });
    });

    group('Edge Cases', () {
      test('handles very long strings', () {
        final longString = 'a' * 1000;
        final stockType = StockType(
          idStockType: longString,
          stockTypeName: longString,
          stockTypeIcon: longString,
          stockUnit: longString,
        );

        expect(stockType.idStockType, equals(longString));
        expect(stockType.stockTypeName, equals(longString));
        expect(stockType.stockTypeIcon, equals(longString));
        expect(stockType.stockUnit, equals(longString));
      });

      test('handles special characters and unicode', () {
        const stockType = StockType(
          idStockType: 'type-1!@#\$%^&*()',
          stockTypeName: 'Raw Material 🏭',
          stockTypeIcon: 'icon_with_chars_éàü',
          stockUnit: 'kg/m³',
        );

        expect(stockType.idStockType, equals('type-1!@#\$%^&*()'));
        expect(stockType.stockTypeName, equals('Raw Material 🏭'));
        expect(stockType.stockTypeIcon, equals('icon_with_chars_éàü'));
        expect(stockType.stockUnit, equals('kg/m³'));
      });

      test('handles common measurement units', () {
        final commonUnits = ['kg', 'g', 'L', 'mL', 'pcs', 'dozen', 'm', 'cm', 'mm'];
        
        for (int i = 0; i < commonUnits.length; i++) {
          final stockType = StockType(
            idStockType: 'type-$i',
            stockTypeName: 'Type $i',
            stockTypeIcon: 'icon_$i',
            stockUnit: commonUnits[i],
          );
          
          expect(stockType.stockUnit, equals(commonUnits[i]));
        }
      });
    });
  });
} 