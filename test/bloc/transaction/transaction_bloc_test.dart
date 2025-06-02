import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/transaction/transaction_history.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/repository/transaction/transaction_repository.dart';

// Mock classes
class MockTransactionRepository extends Mock implements TransactionRepository {}

void main() {
  // Set up fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(<TransactionItem>[]);
  });

  group('TransactionBloc', () {
    late TransactionBloc transactionBloc;
    late MockTransactionRepository mockTransactionRepository;

    // Test data
    const transactionType = TransactionType(
      idTransactionType: 'type-1',
      transactionTypeName: 'Sale',
      transactionTypeIcon: 'sale_icon',
    );

    const menuType = MenuType(
      idMenuType: 'menu-type-1',
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

    final testTransactionItem = TransactionItem(
      idTransactionItem: 'item-1',
      idTransactionHistory: 'transaction-1',
      menu: testMenu,
      transactionQuantity: 2,
    );

    final testTransaction = TransactionHistory(
      idTransactionHistory: 'transaction-1',
      transactionType: transactionType,
      transactionAmount: 30000,
      moneyReceived: 35000,
      imageEvident: Uint8List.fromList([5, 6, 7, 8]),
      timestamp: '2023-01-01T10:00:00.000Z',
      items: [testTransactionItem],
    );

    final testTransactions = [testTransaction];

    setUp(() {
      mockTransactionRepository = MockTransactionRepository();
      transactionBloc = TransactionBloc(mockTransactionRepository);
    });

    tearDown(() {
      transactionBloc.close();
    });

    test('initial state is TransactionLoading', () {
      expect(transactionBloc.state, isA<TransactionLoading>());
    });

    group('LoadTransactions', () {
      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionLoading, TransactionLoaded] when LoadTransactions is successful',
        build: () {
          when(() => mockTransactionRepository.getAllTransactions())
              .thenAnswer((_) async => testTransactions);
          return transactionBloc;
        },
        act: (bloc) => bloc.add(LoadTransactions()),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>().having(
            (state) => state.transactions,
            'transactions',
            equals(testTransactions),
          ),
        ],
        verify: (_) {
          verify(() => mockTransactionRepository.getAllTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionLoading, TransactionLoaded] with empty list when no transactions found',
        build: () {
          when(() => mockTransactionRepository.getAllTransactions())
              .thenAnswer((_) async => <TransactionHistory>[]);
          return transactionBloc;
        },
        act: (bloc) => bloc.add(LoadTransactions()),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>().having(
            (state) => state.transactions,
            'transactions',
            isEmpty,
          ),
        ],
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionLoading, TransactionError] when LoadTransactions fails',
        build: () {
          when(() => mockTransactionRepository.getAllTransactions())
              .thenThrow(Exception('Database error'));
          return transactionBloc;
        },
        act: (bloc) => bloc.add(LoadTransactions()),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );

      blocTest<TransactionBloc, TransactionState>(
        'preserves previous state when LoadTransactions fails and there was a loaded state',
        build: () {
          when(() => mockTransactionRepository.getAllTransactions())
              .thenThrow(Exception('Database error'));
          return transactionBloc;
        },
        seed: () => TransactionLoaded(testTransactions),
        act: (bloc) => bloc.add(LoadTransactions()),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>().having(
            (state) => state.transactions,
            'transactions',
            equals(testTransactions),
          ),
        ],
      );
    });

    group('LoadTransactionById', () {
      const transactionId = 'transaction-1';

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionDetailLoading, TransactionDetailLoaded] when LoadTransactionById is successful',
        build: () {
          when(() => mockTransactionRepository.getTransactionById(transactionId))
              .thenAnswer((_) async => testTransaction);
          return transactionBloc;
        },
        act: (bloc) => bloc.add(LoadTransactionById(transactionId)),
        expect: () => [
          isA<TransactionDetailLoading>(),
          isA<TransactionDetailLoaded>().having(
            (state) => state.transaction,
            'transaction',
            equals(testTransaction),
          ),
        ],
        verify: (_) {
          verify(() => mockTransactionRepository.getTransactionById(transactionId)).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionDetailLoading, TransactionError] when transaction not found',
        build: () {
          when(() => mockTransactionRepository.getTransactionById(transactionId))
              .thenAnswer((_) async => null);
          return transactionBloc;
        },
        act: (bloc) => bloc.add(LoadTransactionById(transactionId)),
        expect: () => [
          isA<TransactionDetailLoading>(),
          isA<TransactionError>().having(
            (state) => state.message,
            'message',
            equals('Transaction not found'),
          ),
        ],
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionDetailLoading, TransactionError] when LoadTransactionById fails',
        build: () {
          when(() => mockTransactionRepository.getTransactionById(transactionId))
              .thenThrow(Exception('Database error'));
          return transactionBloc;
        },
        act: (bloc) => bloc.add(LoadTransactionById(transactionId)),
        expect: () => [
          isA<TransactionDetailLoading>(),
          isA<TransactionError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );
    });

    group('AddNewTransaction', () {
      final addTransactionEvent = AddNewTransaction(
        'type-1',
        30000,
        35000,
        Uint8List.fromList([9, 10, 11, 12]),
        [testTransactionItem],
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionLoading, TransactionLoaded] when AddNewTransaction is successful',
        build: () {
          when(() => mockTransactionRepository.addTransaction(
                any(),
                any(),
                any(),
                any(),
                any(),
              )).thenAnswer((_) async {});
          when(() => mockTransactionRepository.getAllTransactions())
              .thenAnswer((_) async => testTransactions);
          return transactionBloc;
        },
        act: (bloc) => bloc.add(addTransactionEvent),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>().having(
            (state) => state.transactions,
            'transactions',
            equals(testTransactions),
          ),
        ],
        verify: (_) {
          verify(() => mockTransactionRepository.addTransaction(
                'type-1',
                30000,
                35000,
                any(),
                any(),
              )).called(1);
          verify(() => mockTransactionRepository.getAllTransactions()).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionLoading, TransactionError] when AddNewTransaction fails',
        build: () {
          when(() => mockTransactionRepository.addTransaction(
                any(),
                any(),
                any(),
                any(),
                any(),
              )).thenThrow(Exception('Database error'));
          return transactionBloc;
        },
        act: (bloc) => bloc.add(addTransactionEvent),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );
    });

    group('DeleteTransactionEvent', () {
      const transactionId = 'transaction-1';
      final deleteTransactionEvent = DeleteTransactionEvent(transactionId);

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionLoading, TransactionDeleted] when DeleteTransactionEvent is successful',
        build: () {
          when(() => mockTransactionRepository.deleteTransaction(transactionId))
              .thenAnswer((_) async => 1);
          return transactionBloc;
        },
        act: (bloc) => bloc.add(deleteTransactionEvent),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionDeleted>(),
        ],
        verify: (_) {
          verify(() => mockTransactionRepository.deleteTransaction(transactionId)).called(1);
        },
      );

      blocTest<TransactionBloc, TransactionState>(
        'emits [TransactionLoading, TransactionError] when DeleteTransactionEvent fails',
        build: () {
          when(() => mockTransactionRepository.deleteTransaction(transactionId))
              .thenThrow(Exception('Database error'));
          return transactionBloc;
        },
        act: (bloc) => bloc.add(deleteTransactionEvent),
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );
    });

    group('State transitions', () {
      blocTest<TransactionBloc, TransactionState>(
        'maintains state consistency during multiple operations',
        build: () {
          when(() => mockTransactionRepository.getAllTransactions())
              .thenAnswer((_) async => testTransactions);
          when(() => mockTransactionRepository.deleteTransaction(any()))
              .thenAnswer((_) async => 1);
          return transactionBloc;
        },
        act: (bloc) {
          bloc.add(LoadTransactions());
          bloc.add(DeleteTransactionEvent('transaction-1'));
        },
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>(),
          isA<TransactionLoading>(),
          isA<TransactionDeleted>(),
        ],
      );

      blocTest<TransactionBloc, TransactionState>(
        'handles switching between different state types correctly',
        build: () {
          when(() => mockTransactionRepository.getAllTransactions())
              .thenAnswer((_) async => testTransactions);
          when(() => mockTransactionRepository.getTransactionById(any()))
              .thenAnswer((_) async => testTransaction);
          return transactionBloc;
        },
        act: (bloc) {
          bloc.add(LoadTransactions());
          bloc.add(LoadTransactionById('transaction-1'));
        },
        expect: () => [
          isA<TransactionLoading>(),
          isA<TransactionLoaded>(),
          isA<TransactionDetailLoading>(),
          isA<TransactionDetailLoaded>(),
        ],
      );
    });
  });
} 