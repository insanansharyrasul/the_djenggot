import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_event.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_state.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/stock/stock_history.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/repository/stock/stock_history_repository.dart';

// Mock classes
class MockStockHistoryRepository extends Mock implements StockHistoryRepository {}

void main() {
  group('StockHistoryBloc', () {
    late StockHistoryBloc stockHistoryBloc;
    late MockStockHistoryRepository mockStockHistoryRepository;

    // Test data
    const stockType = StockType(
      idStockType: 'type-1',
      stockTypeName: 'Raw Material',
      stockTypeIcon: 'material_icon',
      stockUnit: 'kg',
    );

    final testStock = Stock(
      idStock: 'stock-1',
      stockName: 'Test Stock',
      stockQuantity: 100,
      idStockType: stockType,
      stockThreshold: 10,
      price: 5000,
    );

    final testStockHistory = StockHistory(
      stockHistoryId: 'history-1',
      timestamp: '2023-01-01T10:00:00.000Z',
      idStock: 'stock-1',
      amount: 50,
      actionType: 'add',
      totalPrice: 250000,
      stock: testStock,
    );

    final testStockHistories = [testStockHistory];

    setUp(() {
      mockStockHistoryRepository = MockStockHistoryRepository();
      stockHistoryBloc = StockHistoryBloc(stockHistoryRepository: mockStockHistoryRepository);
    });

    tearDown(() {
      stockHistoryBloc.close();
    });

    test('initial state is StockHistoryInitial', () {
      expect(stockHistoryBloc.state, isA<StockHistoryInitial>());
    });

    group('LoadStockHistory', () {
      blocTest<StockHistoryBloc, StockHistoryState>(
        'emits [StockHistoryLoading, StockHistoryLoaded] when LoadStockHistory is successful',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryWithStockDetails())
              .thenAnswer((_) async => testStockHistories);
          return stockHistoryBloc;
        },
        act: (bloc) => bloc.add(LoadStockHistory()),
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryLoaded>().having(
            (state) => state.stockHistories,
            'stockHistories',
            equals(testStockHistories),
          ),
        ],
        verify: (_) {
          verify(() => mockStockHistoryRepository.getStockHistoryWithStockDetails()).called(1);
        },
      );

      blocTest<StockHistoryBloc, StockHistoryState>(
        'emits [StockHistoryLoading, StockHistoryLoaded] with empty list when no history found',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryWithStockDetails())
              .thenAnswer((_) async => <StockHistory>[]);
          return stockHistoryBloc;
        },
        act: (bloc) => bloc.add(LoadStockHistory()),
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryLoaded>().having(
            (state) => state.stockHistories,
            'stockHistories',
            isEmpty,
          ),
        ],
      );

      blocTest<StockHistoryBloc, StockHistoryState>(
        'emits [StockHistoryLoading, StockHistoryError] when LoadStockHistory fails',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryWithStockDetails())
              .thenThrow(Exception('Database error'));
          return stockHistoryBloc;
        },
        act: (bloc) => bloc.add(LoadStockHistory()),
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );
    });

    group('FilterStockHistory', () {
      const stockId = 'stock-1';
      const filterEvent = FilterStockHistory(stockId);

      final filteredStockHistories = [
        StockHistory(
          stockHistoryId: 'history-1',
          timestamp: '2023-01-01T10:00:00.000Z',
          idStock: stockId,
          amount: 50,
          actionType: 'add',
          totalPrice: 250000,
          stock: testStock,
        ),
        StockHistory(
          stockHistoryId: 'history-2',
          timestamp: '2023-01-02T10:00:00.000Z',
          idStock: stockId,
          amount: -10,
          actionType: 'decrease',
          stock: testStock,
        ),
      ];

      blocTest<StockHistoryBloc, StockHistoryState>(
        'emits [StockHistoryLoading, StockHistoryLoaded] when FilterStockHistory is successful',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryForStock(stockId))
              .thenAnswer((_) async => filteredStockHistories);
          return stockHistoryBloc;
        },
        act: (bloc) => bloc.add(filterEvent),
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryLoaded>().having(
            (state) => state.stockHistories,
            'stockHistories',
            equals(filteredStockHistories),
          ),
        ],
        verify: (_) {
          verify(() => mockStockHistoryRepository.getStockHistoryForStock(stockId)).called(1);
        },
      );

      blocTest<StockHistoryBloc, StockHistoryState>(
        'emits [StockHistoryLoading, StockHistoryLoaded] with empty list when no history found for stock',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryForStock(stockId))
              .thenAnswer((_) async => <StockHistory>[]);
          return stockHistoryBloc;
        },
        act: (bloc) => bloc.add(filterEvent),
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryLoaded>().having(
            (state) => state.stockHistories,
            'stockHistories',
            isEmpty,
          ),
        ],
      );

      blocTest<StockHistoryBloc, StockHistoryState>(
        'emits [StockHistoryLoading, StockHistoryError] when FilterStockHistory fails',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryForStock(any()))
              .thenThrow(Exception('Database error'));
          return stockHistoryBloc;
        },
        act: (bloc) => bloc.add(filterEvent),
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );

      blocTest<StockHistoryBloc, StockHistoryState>(
        'calls getStockHistoryForStock with correct parameters',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryForStock(any()))
              .thenAnswer((_) async => filteredStockHistories);
          return stockHistoryBloc;
        },
        act: (bloc) => bloc.add(filterEvent),
        verify: (_) {
          verify(() => mockStockHistoryRepository.getStockHistoryForStock(stockId)).called(1);
        },
      );
    });

    group('State transitions', () {
      blocTest<StockHistoryBloc, StockHistoryState>(
        'maintains state consistency during multiple operations',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryWithStockDetails())
              .thenAnswer((_) async => testStockHistories);
          when(() => mockStockHistoryRepository.getStockHistoryForStock(any()))
              .thenAnswer((_) async => testStockHistories);
          return stockHistoryBloc;
        },
        act: (bloc) {
          bloc.add(LoadStockHistory());
          bloc.add(const FilterStockHistory('stock-1'));
        },
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryLoaded>(),
          isA<StockHistoryLoading>(),
          isA<StockHistoryLoaded>(),
        ],
      );

      blocTest<StockHistoryBloc, StockHistoryState>(
        'handles filter then load operations correctly',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryForStock(any()))
              .thenAnswer((_) async => [testStockHistory]);
          when(() => mockStockHistoryRepository.getStockHistoryWithStockDetails())
              .thenAnswer((_) async => testStockHistories);
          return stockHistoryBloc;
        },
        act: (bloc) {
          bloc.add(const FilterStockHistory('stock-1'));
          bloc.add(LoadStockHistory());
        },
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryLoaded>(),
        ],
      );

      blocTest<StockHistoryBloc, StockHistoryState>(
        'handles recovery from error state correctly',
        build: () {
          when(() => mockStockHistoryRepository.getStockHistoryWithStockDetails())
              .thenThrow(Exception('Database error'));
          return stockHistoryBloc;
        },
        act: (bloc) {
          bloc.add(LoadStockHistory());
          bloc.add(LoadStockHistory()); // Try again
        },
        expect: () => [
          isA<StockHistoryLoading>(),
          isA<StockHistoryError>(),
          isA<StockHistoryLoading>(),
          isA<StockHistoryError>(),
        ],
      );
    });

    group('Event equality', () {
      test('LoadStockHistory events are equal', () {
        expect(LoadStockHistory(), equals(LoadStockHistory()));
      });

      test('FilterStockHistory events with same stockId are equal', () {
        const stockId = 'stock-1';
        expect(
          const FilterStockHistory(stockId),
          equals(const FilterStockHistory(stockId)),
        );
      });

      test('FilterStockHistory events with different stockId are not equal', () {
        expect(
          const FilterStockHistory('stock-1'),
          isNot(equals(const FilterStockHistory('stock-2'))),
        );
      });
    });

    group('State equality', () {
      test('StockHistoryLoaded states with same data are equal', () {
        expect(
          StockHistoryLoaded(testStockHistories),
          equals(StockHistoryLoaded(testStockHistories)),
        );
      });

      test('StockHistoryError states with same message are equal', () {
        const message = 'Test error';
        expect(
          const StockHistoryError(message),
          equals(const StockHistoryError(message)),
        );
      });
    });
  });
} 