import 'package:flutter_test/flutter_test.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';

void main() {
  group('TransactionType', () {
    const testTransactionType = TransactionType(
      idTransactionType: 'type-1',
      transactionTypeName: 'Sale',
      transactionTypeIcon: 'sale_icon',
    );

    const testMap = {
      'id_transaction_type': 'type-1',
      'transaction_type_name': 'Sale',
      'transaction_type_icon': 'sale_icon',
      'need_evidence': 1,
    };

    group('Constructor', () {
      test('creates TransactionType with valid parameters', () {
        expect(testTransactionType.idTransactionType, equals('type-1'));
        expect(testTransactionType.transactionTypeName, equals('Sale'));
        expect(testTransactionType.transactionTypeIcon, equals('sale_icon'));
        expect(testTransactionType.needEvidence, isTrue);
      });

      test('creates TransactionType with default needEvidence value', () {
        const transactionType = TransactionType(
          idTransactionType: 'type-1',
          transactionTypeName: 'Sale',
          transactionTypeIcon: 'sale_icon',
        );

        expect(transactionType.needEvidence, isTrue);
      });

      test('creates TransactionType with needEvidence false', () {
        const transactionType = TransactionType(
          idTransactionType: 'type-1',
          transactionTypeName: 'Cash Sale',
          transactionTypeIcon: 'cash_icon',
          needEvidence: false,
        );

        expect(transactionType.needEvidence, isFalse);
      });

      test('creates TransactionType with empty strings', () {
        const emptyTransactionType = TransactionType(
          idTransactionType: '',
          transactionTypeName: '',
          transactionTypeIcon: '',
          needEvidence: false,
        );

        expect(emptyTransactionType.idTransactionType, equals(''));
        expect(emptyTransactionType.transactionTypeName, equals(''));
        expect(emptyTransactionType.transactionTypeIcon, equals(''));
        expect(emptyTransactionType.needEvidence, isFalse);
      });
    });

    group('fromMap', () {
      test('creates TransactionType from valid map', () {
        final transactionType = TransactionType.fromMap(testMap);

        expect(transactionType.idTransactionType, equals('type-1'));
        expect(transactionType.transactionTypeName, equals('Sale'));
        expect(transactionType.transactionTypeIcon, equals('sale_icon'));
        expect(transactionType.needEvidence, isTrue);
      });

      test('creates TransactionType from map with needEvidence as 0', () {
        final mapWithFalseEvidence = {
          'id_transaction_type': 'type-2',
          'transaction_type_name': 'Cash Sale',
          'transaction_type_icon': 'cash_icon',
          'need_evidence': 0,
        };

        final transactionType = TransactionType.fromMap(mapWithFalseEvidence);

        expect(transactionType.needEvidence, isFalse);
      });

      test('creates TransactionType from map with null values', () {
        final mapWithNulls = {
          'id_transaction_type': null,
          'transaction_type_name': null,
          'transaction_type_icon': null,
          'need_evidence': null,
        };

        // Non-nullable String fields can't accept null values
        expect(() => TransactionType.fromMap(mapWithNulls), throwsA(isA<TypeError>()));
      });

      test('creates TransactionType from empty map', () {
        final emptyMap = <String, dynamic>{};

        // Missing keys result in null values for non-nullable fields
        expect(() => TransactionType.fromMap(emptyMap), throwsA(isA<TypeError>()));
      });

      test('creates TransactionType from map with different evidence values', () {
        final testCases = [
          {'need_evidence': 1, 'expected': true},
          {'need_evidence': 0, 'expected': false},
          {'need_evidence': 2, 'expected': false}, // Any value != 1 is false
          {'need_evidence': -1, 'expected': false},
          {'need_evidence': true, 'expected': false}, // Only 1 is true
          {'need_evidence': false, 'expected': false},
        ];

        for (final testCase in testCases) {
          final map = {
            'id_transaction_type': 'test',
            'transaction_type_name': 'Test',
            'transaction_type_icon': 'test',
            'need_evidence': testCase['need_evidence'],
          };

          final transactionType = TransactionType.fromMap(map);
          expect(transactionType.needEvidence, equals(testCase['expected']));
        }
      });
    });

    group('toMap', () {
      test('converts TransactionType to map correctly', () {
        final map = testTransactionType.toMap();

        expect(map, equals(testMap));
      });

      test('converts TransactionType with needEvidence false to map', () {
        const transactionType = TransactionType(
          idTransactionType: 'type-2',
          transactionTypeName: 'Cash Sale',
          transactionTypeIcon: 'cash_icon',
          needEvidence: false,
        );

        final map = transactionType.toMap();

        expect(map, equals({
          'id_transaction_type': 'type-2',
          'transaction_type_name': 'Cash Sale',
          'transaction_type_icon': 'cash_icon',
          'need_evidence': 0,
        }));
      });

      test('converts TransactionType with empty values to map', () {
        const emptyTransactionType = TransactionType(
          idTransactionType: '',
          transactionTypeName: '',
          transactionTypeIcon: '',
          needEvidence: false,
        );

        final map = emptyTransactionType.toMap();

        expect(map, equals({
          'id_transaction_type': '',
          'transaction_type_name': '',
          'transaction_type_icon': '',
          'need_evidence': 0,
        }));
      });
    });

    group('copyWith', () {
      test('creates copy with updated idTransactionType', () {
        final copied = testTransactionType.copyWith(
          idTransactionType: 'new-type-1',
        );

        expect(copied.idTransactionType, equals('new-type-1'));
        expect(copied.transactionTypeName, equals('Sale'));
        expect(copied.transactionTypeIcon, equals('sale_icon'));
        expect(copied.needEvidence, isTrue);
      });

      test('creates copy with updated transactionTypeName', () {
        final copied = testTransactionType.copyWith(
          transactionTypeName: 'Purchase',
        );

        expect(copied.idTransactionType, equals('type-1'));
        expect(copied.transactionTypeName, equals('Purchase'));
        expect(copied.transactionTypeIcon, equals('sale_icon'));
        expect(copied.needEvidence, isTrue);
      });

      test('creates copy with updated transactionTypeIcon', () {
        final copied = testTransactionType.copyWith(
          transactionTypeIcon: 'purchase_icon',
        );

        expect(copied.idTransactionType, equals('type-1'));
        expect(copied.transactionTypeName, equals('Sale'));
        expect(copied.transactionTypeIcon, equals('purchase_icon'));
        expect(copied.needEvidence, isTrue);
      });

      test('creates copy with all parameters updated', () {
        final copied = testTransactionType.copyWith(
          idTransactionType: 'type-3',
          transactionTypeName: 'Refund',
          transactionTypeIcon: 'refund_icon',
        );

        expect(copied.idTransactionType, equals('type-3'));
        expect(copied.transactionTypeName, equals('Refund'));
        expect(copied.transactionTypeIcon, equals('refund_icon'));
        expect(copied.needEvidence, isTrue); // needEvidence is not in copyWith
      });

      test('creates copy with no parameters (returns same values)', () {
        final copied = testTransactionType.copyWith();

        expect(copied.idTransactionType, equals('type-1'));
        expect(copied.transactionTypeName, equals('Sale'));
        expect(copied.transactionTypeIcon, equals('sale_icon'));
        expect(copied.needEvidence, isTrue);
      });
    });

    group('Serialization', () {
      test('fromMap and toMap are reversible', () {
        const originalTransactionType = testTransactionType;
        final map = originalTransactionType.toMap();
        final reconstructedTransactionType = TransactionType.fromMap(map);

        expect(reconstructedTransactionType, equals(originalTransactionType));
      });

      test('round-trip serialization with different needEvidence values', () {
        const transactionTypes = [
          TransactionType(
            idTransactionType: 'type-1',
            transactionTypeName: 'Sale',
            transactionTypeIcon: 'sale',
          ),
          TransactionType(
            idTransactionType: 'type-2',
            transactionTypeName: 'Cash',
            transactionTypeIcon: 'cash',
            needEvidence: false,
          ),
        ];

        for (final transactionType in transactionTypes) {
          final map = transactionType.toMap();
          final reconstructed = TransactionType.fromMap(map);
          expect(reconstructed, equals(transactionType));
        }
      });
    });

    group('Equality and HashCode', () {
      test('two TransactionTypes with same properties are equal', () {
        const transactionType1 = TransactionType(
          idTransactionType: 'type-1',
          transactionTypeName: 'Sale',
          transactionTypeIcon: 'sale_icon',
        );

        const transactionType2 = TransactionType(
          idTransactionType: 'type-1',
          transactionTypeName: 'Sale',
          transactionTypeIcon: 'sale_icon',
        );

        expect(transactionType1, equals(transactionType2));
        expect(transactionType1.hashCode, equals(transactionType2.hashCode));
      });

      test('two TransactionTypes with different properties are not equal', () {
        const transactionType1 = TransactionType(
          idTransactionType: 'type-1',
          transactionTypeName: 'Sale',
          transactionTypeIcon: 'sale_icon',
        );

        const transactionType2 = TransactionType(
          idTransactionType: 'type-2',
          transactionTypeName: 'Purchase',
          transactionTypeIcon: 'purchase_icon',
          needEvidence: false,
        );

        expect(transactionType1, isNot(equals(transactionType2)));
        expect(transactionType1.hashCode, isNot(equals(transactionType2.hashCode)));
      });

      test('TransactionTypes with different needEvidence are equal (not in props)', () {
        const transactionType1 = TransactionType(
          idTransactionType: 'type-1',
          transactionTypeName: 'Sale',
          transactionTypeIcon: 'sale_icon',
        );

        const transactionType2 = TransactionType(
          idTransactionType: 'type-1',
          transactionTypeName: 'Sale',
          transactionTypeIcon: 'sale_icon',
          needEvidence: false,
        );

        // needEvidence is not in props, so they should be equal
        expect(transactionType1, equals(transactionType2));
      });
    });

    group('Props', () {
      test('props contains correct properties (excludes needEvidence)', () {
        expect(testTransactionType.props, equals([
          'type-1',
          'Sale',
          'sale_icon',
        ]));
      });
    });

    group('Edge Cases', () {
      test('handles very long strings', () {
        final longString = 'a' * 1000;
        final transactionType = TransactionType(
          idTransactionType: longString,
          transactionTypeName: longString,
          transactionTypeIcon: longString,
        );

        expect(transactionType.idTransactionType, equals(longString));
        expect(transactionType.transactionTypeName, equals(longString));
        expect(transactionType.transactionTypeIcon, equals(longString));
      });

      test('handles special characters and unicode', () {
        const transactionType = TransactionType(
          idTransactionType: 'type-1!@#\$%^&*()',
          transactionTypeName: 'Sale & Purchase 💰',
          transactionTypeIcon: 'icon_with_chars_éàü',
        );

        expect(transactionType.idTransactionType, equals('type-1!@#\$%^&*()'));
        expect(transactionType.transactionTypeName, equals('Sale & Purchase 💰'));
        expect(transactionType.transactionTypeIcon, equals('icon_with_chars_éàü'));
      });

      test('handles common transaction types', () {
        final commonTypes = [
          {'name': 'Sale', 'needEvidence': true},
          {'name': 'Purchase', 'needEvidence': true},
          {'name': 'Refund', 'needEvidence': true},
          {'name': 'Cash Sale', 'needEvidence': false},
          {'name': 'Internal Transfer', 'needEvidence': false},
        ];

        for (int i = 0; i < commonTypes.length; i++) {
          final type = commonTypes[i];
          final transactionType = TransactionType(
            idTransactionType: 'type-$i',
            transactionTypeName: type['name'] as String,
            transactionTypeIcon: 'icon_$i',
            needEvidence: type['needEvidence'] as bool,
          );

          expect(transactionType.transactionTypeName, equals(type['name']));
          expect(transactionType.needEvidence, equals(type['needEvidence']));
        }
      });
    });
  });
} 