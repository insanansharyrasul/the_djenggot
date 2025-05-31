import 'package:flutter_test/flutter_test.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/stock_type.dart';

void main() {
  group('Stock', () {
    const testStockType = StockType(
      idStockType: 'type-1',
      stockTypeName: 'Raw Material',
      stockTypeIcon: 'material_icon',
      stockUnit: 'kg',
    );

    final testStock = Stock(
      idStock: 'stock-1',
      stockName: 'Test Stock',
      stockQuantity: 100,
      idStockType: testStockType,
      stockThreshold: 10,
      price: 5000,
    );

    group('Constructor', () {
      test('creates Stock with valid parameters', () {
        expect(testStock.idStock, equals('stock-1'));
        expect(testStock.stockName, equals('Test Stock'));
        expect(testStock.stockQuantity, equals(100));
        expect(testStock.idStockType, equals(testStockType));
        expect(testStock.stockThreshold, equals(10));
        expect(testStock.price, equals(5000));
      });

      test('creates Stock with default values', () {
        final stock = Stock(
          idStock: 'stock-1',
          stockName: 'Test Stock',
          stockQuantity: 100,
          idStockType: testStockType,
        );

        expect(stock.stockThreshold, isNull);
        expect(stock.price, equals(0));
      });

      test('creates Stock with null threshold', () {
        final stock = Stock(
          idStock: 'stock-1',
          stockName: 'Test Stock',
          stockQuantity: 100,
          idStockType: testStockType,
          price: 1000,
        );

        expect(stock.stockThreshold, isNull);
        expect(stock.price, equals(1000));
      });

      test('creates Stock with zero values', () {
        final stock = Stock(
          idStock: '',
          stockName: '',
          stockQuantity: 0,
          idStockType: testStockType,
          stockThreshold: 0,
        );

        expect(stock.idStock, equals(''));
        expect(stock.stockName, equals(''));
        expect(stock.stockQuantity, equals(0));
        expect(stock.stockThreshold, equals(0));
        expect(stock.price, equals(0));
      });

      test('creates Stock with negative values', () {
        final stock = Stock(
          idStock: 'stock-1',
          stockName: 'Test Stock',
          stockQuantity: -10,
          idStockType: testStockType,
          stockThreshold: -5,
          price: -1000,
        );

        expect(stock.stockQuantity, equals(-10));
        expect(stock.stockThreshold, equals(-5));
        expect(stock.price, equals(-1000));
      });
    });

    group('toMap', () {
      test('converts Stock to map correctly', () {
        final map = testStock.toMap();

        expect(map, equals({
          'id_stock': 'stock-1',
          'stock_name': 'Test Stock',
          'stock_quantity': 100,
          'id_stock_type': 'type-1',
          'stock_threshold': 10,
          'price': 5000,
        }));
      });

      test('converts Stock with null threshold to map', () {
        final stock = Stock(
          idStock: 'stock-1',
          stockName: 'Test Stock',
          stockQuantity: 100,
          idStockType: testStockType,
          price: 5000,
        );

        final map = stock.toMap();

        expect(map, equals({
          'id_stock': 'stock-1',
          'stock_name': 'Test Stock',
          'stock_quantity': 100,
          'id_stock_type': 'type-1',
          'stock_threshold': 0,
          'price': 5000,
        }));
      });

      test('converts Stock with default price to map', () {
        final stock = Stock(
          idStock: 'stock-1',
          stockName: 'Test Stock',
          stockQuantity: 100,
          idStockType: testStockType,
          stockThreshold: 10,
        );

        final map = stock.toMap();

        expect(map['price'], equals(0));
      });

      test('converts Stock with empty values to map', () {
        final stock = Stock(
          idStock: '',
          stockName: '',
          stockQuantity: 0,
          idStockType: const StockType(
            idStockType: '',
            stockTypeName: '',
            stockTypeIcon: '',
            stockUnit: '',
          ),
          stockThreshold: 0,
        );

        final map = stock.toMap();

        expect(map, equals({
          'id_stock': '',
          'stock_name': '',
          'stock_quantity': 0,
          'id_stock_type': '',
          'stock_threshold': 0,
          'price': 0,
        }));
      });
    });

    group('fromMap', () {
      test('creates Stock from valid map', () {
        final map = {
          'id_stock': 'stock-1',
          'stock_name': 'Test Stock',
          'stock_quantity': 100,
          'id_stock_type': {
            'id_stock_type': 'type-1',
            'stock_type_name': 'Raw Material',
            'stock_type_icon': 'material_icon',
            'stock_unit': 'kg',
          },
          'stock_threshold': 10,
          'price': 5000,
        };

        final stock = Stock.fromMap(map);

        expect(stock.idStock, equals('stock-1'));
        expect(stock.stockName, equals('Test Stock'));
        expect(stock.stockQuantity, equals(100));
        expect(stock.idStockType.idStockType, equals('type-1'));
        expect(stock.idStockType.stockTypeName, equals('Raw Material'));
        expect(stock.stockThreshold, equals(10));
        expect(stock.price, equals(5000));
      });

      test('creates Stock from map with string numbers', () {
        final map = {
          'id_stock': 'stock-1',
          'stock_name': 'Test Stock',
          'stock_quantity': '100',
          'id_stock_type': {
            'id_stock_type': 'type-1',
            'stock_type_name': 'Raw Material',
            'stock_type_icon': 'material_icon',
            'stock_unit': 'kg',
          },
          'stock_threshold': '10',
          'price': '5000',
        };

        final stock = Stock.fromMap(map);

        expect(stock.stockQuantity, equals(100));
        expect(stock.stockThreshold, equals(10));
        expect(stock.price, equals(5000));
      });

      test('creates Stock from map with null values', () {
        final map = {
          'id_stock': 'stock-1',
          'stock_name': 'Test Stock',
          'stock_quantity': 100,
          'id_stock_type': {
            'id_stock_type': 'type-1',
            'stock_type_name': 'Raw Material',
            'stock_type_icon': 'material_icon',
            'stock_unit': 'kg',
          },
          'stock_threshold': null,
          'price': null,
        };

        final stock = Stock.fromMap(map);

        expect(stock.stockThreshold, equals(0));
        expect(stock.price, equals(0));
      });

      test('creates Stock from map with missing optional fields', () {
        final map = {
          'id_stock': 'stock-1',
          'stock_name': 'Test Stock',
          'stock_quantity': 100,
          'id_stock_type': {
            'id_stock_type': 'type-1',
            'stock_type_name': 'Raw Material',
            'stock_type_icon': 'material_icon',
            'stock_unit': 'kg',
          },
        };

        final stock = Stock.fromMap(map);

        expect(stock.stockThreshold, equals(0));
        expect(stock.price, equals(0));
      });

      test('handles different numeric data types', () {
        final testCases = [
          {
            'description': 'int values',
            'stock_quantity': 100,
            'stock_threshold': 10,
            'price': 5000,
            'expectedQuantity': 100,
            'expectedThreshold': 10,
            'expectedPrice': 5000,
          },
          {
            'description': 'string values',
            'stock_quantity': '100',
            'stock_threshold': '10',
            'price': '5000',
            'expectedQuantity': 100,
            'expectedThreshold': 10,
            'expectedPrice': 5000,
          },
          {
            'description': 'mixed types',
            'stock_quantity': '100',
            'stock_threshold': 10,
            'price': '5000',
            'expectedQuantity': 100,
            'expectedThreshold': 10,
            'expectedPrice': 5000,
          },
        ];

        for (final testCase in testCases) {
          final map = {
            'id_stock': 'test',
            'stock_name': 'Test',
            'stock_quantity': testCase['stock_quantity'],
            'id_stock_type': {
              'id_stock_type': 'type-1',
              'stock_type_name': 'Test Type',
              'stock_type_icon': 'test_icon',
              'stock_unit': 'test_unit',
            },
            'stock_threshold': testCase['stock_threshold'],
            'price': testCase['price'],
          };

          final stock = Stock.fromMap(map);
          expect(stock.stockQuantity, equals(testCase['expectedQuantity']),
              reason: 'Failed for ${testCase['description']} - quantity');
          expect(stock.stockThreshold, equals(testCase['expectedThreshold']),
              reason: 'Failed for ${testCase['description']} - threshold');
          expect(stock.price, equals(testCase['expectedPrice']),
              reason: 'Failed for ${testCase['description']} - price');
        }
      });

      test('throws FormatException with double values', () {
        final mapWithDoubles = {
          'id_stock': 'test',
          'stock_name': 'Test',
          'stock_quantity': 100.5,
          'id_stock_type': {
            'id_stock_type': 'type-1',
            'stock_type_name': 'Test Type',
            'stock_type_icon': 'test_icon',
            'stock_unit': 'test_unit',
          },
          'stock_threshold': 10.5,
          'price': 5000.99,
        };

        expect(() => Stock.fromMap(mapWithDoubles), throwsA(isA<FormatException>()));
      });
    });

    group('Serialization', () {
      test('toMap and fromMap are reversible', () {
        final originalStock = testStock;
        final map = originalStock.toMap();
        
        // Add the StockType data that would come from a join
        map['id_stock_type'] = {
          'id_stock_type': testStockType.idStockType,
          'stock_type_name': testStockType.stockTypeName,
          'stock_type_icon': testStockType.stockTypeIcon,
          'stock_unit': testStockType.stockUnit,
        };
        
        final reconstructedStock = Stock.fromMap(map);

        expect(reconstructedStock.idStock, equals(originalStock.idStock));
        expect(reconstructedStock.stockName, equals(originalStock.stockName));
        expect(reconstructedStock.stockQuantity, equals(originalStock.stockQuantity));
        expect(reconstructedStock.idStockType, equals(originalStock.idStockType));
        expect(reconstructedStock.stockThreshold, equals(originalStock.stockThreshold));
        expect(reconstructedStock.price, equals(originalStock.price));
      });

      test('round-trip serialization with different StockTypes', () {
        final stockTypes = [
          const StockType(
            idStockType: 'liquid',
            stockTypeName: 'Liquid',
            stockTypeIcon: 'liquid',
            stockUnit: 'L',
          ),
          const StockType(
            idStockType: 'solid',
            stockTypeName: 'Solid',
            stockTypeIcon: 'solid',
            stockUnit: 'kg',
          ),
        ];

        for (final stockType in stockTypes) {
          final stock = Stock(
            idStock: 'test-${stockType.idStockType}',
            stockName: 'Test ${stockType.stockTypeName}',
            stockQuantity: 50,
            idStockType: stockType,
            stockThreshold: 5,
            price: 1000,
          );

          final map = stock.toMap();
          map['id_stock_type'] = stockType.toMap();
          
          final reconstructed = Stock.fromMap(map);
          
          expect(reconstructed.idStock, equals(stock.idStock));
          expect(reconstructed.stockName, equals(stock.stockName));
          expect(reconstructed.stockQuantity, equals(stock.stockQuantity));
          expect(reconstructed.idStockType, equals(stock.idStockType));
          expect(reconstructed.stockThreshold, equals(stock.stockThreshold));
          expect(reconstructed.price, equals(stock.price));
        }
      });
    });

    group('Edge Cases', () {
      test('handles very long strings', () {
        final longString = 'a' * 1000;
        final stock = Stock(
          idStock: longString,
          stockName: longString,
          stockQuantity: 100,
          idStockType: testStockType,
        );

        expect(stock.idStock, equals(longString));
        expect(stock.stockName, equals(longString));
      });

      test('handles special characters and unicode', () {
        final stock = Stock(
          idStock: 'stock-1!@#\$%^&*()',
          stockName: 'Spicy Chili Powder 🌶️ - Extra Hot 🔥',
          stockQuantity: 100,
          idStockType: testStockType,
          stockThreshold: 10,
          price: 5000,
        );

        expect(stock.idStock, equals('stock-1!@#\$%^&*()'));
        expect(stock.stockName, equals('Spicy Chili Powder 🌶️ - Extra Hot 🔥'));
      });

      test('handles very large numeric values', () {
        final stock = Stock(
          idStock: 'large-values',
          stockName: 'Large Values Stock',
          stockQuantity: 999999999,
          idStockType: testStockType,
          stockThreshold: 888888888,
          price: 777777777,
        );

        expect(stock.stockQuantity, equals(999999999));
        expect(stock.stockThreshold, equals(888888888));
        expect(stock.price, equals(777777777));
      });

      test('handles zero and negative quantities', () {
        final testCases = [
          {'quantity': 0, 'threshold': 0, 'price': 0},
          {'quantity': -10, 'threshold': -5, 'price': -1000},
          {'quantity': 100, 'threshold': 0, 'price': 0},
        ];

        for (final testCase in testCases) {
          final stock = Stock(
            idStock: 'test-${testCase['quantity']}',
            stockName: 'Test Stock',
            stockQuantity: testCase['quantity'] as int,
            idStockType: testStockType,
            stockThreshold: testCase['threshold'] as int,
            price: testCase['price'] as int,
          );

          expect(stock.stockQuantity, equals(testCase['quantity']));
          expect(stock.stockThreshold, equals(testCase['threshold']));
          expect(stock.price, equals(testCase['price']));
        }
      });
    });

    group('Business Logic', () {
      test('can determine if stock is below threshold', () {
        final stock = Stock(
          idStock: 'low-stock',
          stockName: 'Low Stock Item',
          stockQuantity: 5,
          idStockType: testStockType,
          stockThreshold: 10,
          price: 1000,
        );

        // This would be business logic in a service layer
        expect(stock.stockQuantity < (stock.stockThreshold ?? 0), isTrue);
      });

      test('can represent different measurement units through StockType', () {
        final stockUnits = [
          'kg', 'g', 'L', 'mL', 'pcs', 'dozen', 'm', 'cm'
        ];

        for (int i = 0; i < stockUnits.length; i++) {
          final stockType = StockType(
            idStockType: 'type-$i',
            stockTypeName: 'Type $i',
            stockTypeIcon: 'icon_$i',
            stockUnit: stockUnits[i],
          );

          final stock = Stock(
            idStock: 'stock-$i',
            stockName: 'Stock with ${stockUnits[i]}',
            stockQuantity: 100,
            idStockType: stockType,
          );

          expect(stock.idStockType.stockUnit, equals(stockUnits[i]));
        }
      });

      test('can represent free items with zero price', () {
        final freeStock = Stock(
          idStock: 'free-1',
          stockName: 'Complimentary Sample',
          stockQuantity: 100,
          idStockType: testStockType,
        );

        expect(freeStock.price, equals(0));
      });

      test('can represent different stock categories', () {
        final stockCategories = [
          {'name': 'Raw Material', 'icon': 'material'},
          {'name': 'Packaging', 'icon': 'package'},
          {'name': 'Finished Goods', 'icon': 'product'},
          {'name': 'Tools & Equipment', 'icon': 'tool'},
        ];

        for (int i = 0; i < stockCategories.length; i++) {
          final category = stockCategories[i];
          final stockType = StockType(
            idStockType: 'cat-$i',
            stockTypeName: category['name']!,
            stockTypeIcon: category['icon']!,
            stockUnit: 'pcs',
          );

          final stock = Stock(
            idStock: 'stock-cat-$i',
            stockName: '${category['name']} Item',
            stockQuantity: 50,
            idStockType: stockType,
          );

          expect(stock.idStockType.stockTypeName, equals(category['name']));
          expect(stock.idStockType.stockTypeIcon, equals(category['icon']));
        }
      });
    });
  });
} 