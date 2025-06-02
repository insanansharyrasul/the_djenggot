import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/repository/stock_repository.dart';

// Mock classes
class MockStockRepository extends Mock implements StockRepository {}

void main() {
  group('StockBloc', () {
    late StockBloc stockBloc;
    late MockStockRepository mockStockRepository;

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

    final testStocks = [testStock];

    setUp(() {
      mockStockRepository = MockStockRepository();
      stockBloc = StockBloc(mockStockRepository);
    });

    tearDown(() {
      stockBloc.close();
    });

    test('initial state is StockLoading', () {
      expect(stockBloc.state, isA<StockLoading>());
    });

    group('LoadStock', () {
      blocTest<StockBloc, StockState>(
        'emits [StockLoading, StockLoaded] when LoadStock is successful',
        build: () {
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => testStocks);
          return stockBloc;
        },
        act: (bloc) => bloc.add(LoadStock()),
        expect: () => [
          isA<StockLoading>(),
          isA<StockLoaded>().having(
            (state) => state.stocks,
            'stocks',
            equals(testStocks),
          ),
        ],
        verify: (_) {
          verify(() => mockStockRepository.getAllStocks()).called(1);
        },
      );

      blocTest<StockBloc, StockState>(
        'emits [StockLoading, StockLoaded] with empty list when no stocks found',
        build: () {
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => <Stock>[]);
          return stockBloc;
        },
        act: (bloc) => bloc.add(LoadStock()),
        expect: () => [
          isA<StockLoading>(),
          isA<StockLoaded>().having(
            (state) => state.stocks,
            'stocks',
            isEmpty,
          ),
        ],
      );
    });

    group('AddStock', () {
      final addStockEvent = AddStock(
        stockName: 'New Stock',
        stockQuantity: 50,
        stockType: stockType,
        threshold: 5,
        price: 3000,
      );

      blocTest<StockBloc, StockState>(
        'emits [StockLoaded] when AddStock is successful',
        build: () {
          when(() => mockStockRepository.addStok(any()))
              .thenAnswer((_) async => 'new-stock-id');
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => testStocks);
          return stockBloc;
        },
        act: (bloc) => bloc.add(addStockEvent),
        expect: () => [
          isA<StockLoaded>().having(
            (state) => state.stocks,
            'stocks',
            equals(testStocks),
          ),
        ],
        verify: (_) {
          verify(() => mockStockRepository.addStok(any())).called(1);
          verify(() => mockStockRepository.getAllStocks()).called(1);
        },
      );

      blocTest<StockBloc, StockState>(
        'calls addStok with correct parameters',
        build: () {
          when(() => mockStockRepository.addStok(any()))
              .thenAnswer((_) async => 'new-stock-id');
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => testStocks);
          return stockBloc;
        },
        act: (bloc) => bloc.add(addStockEvent),
        verify: (_) {
          final capturedArgs = verify(() => mockStockRepository.addStok(captureAny()))
              .captured.first as Map<String, dynamic>;
          
          expect(capturedArgs['stock_name'], equals('New Stock'));
          expect(capturedArgs['stock_quantity'], equals(50));
          expect(capturedArgs['id_stock_type'], equals(stockType.idStockType));
          expect(capturedArgs['stock_threshold'], equals(5));
          expect(capturedArgs['price'], equals(3000));
          expect(capturedArgs['id_stock'], startsWith('stok-'));
        },
      );
    });

    group('UpdateStock', () {
      final updateStockEvent = UpdateStock(
        testStock,
        'Updated Stock',
        '75',
        'type-2',
        8,
        4000,
      );

      blocTest<StockBloc, StockState>(
        'emits [StockLoaded] when UpdateStock is successful',
        build: () {
          when(() => mockStockRepository.updateStok(any(), any()))
              .thenAnswer((_) async => 1);
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => testStocks);
          return stockBloc;
        },
        act: (bloc) => bloc.add(updateStockEvent),
        expect: () => [
          isA<StockLoaded>().having(
            (state) => state.stocks,
            'stocks',
            equals(testStocks),
          ),
        ],
        verify: (_) {
          verify(() => mockStockRepository.updateStok(any(), testStock.idStock)).called(1);
          verify(() => mockStockRepository.getAllStocks()).called(1);
        },
      );

      blocTest<StockBloc, StockState>(
        'calls updateStok with correct parameters',
        build: () {
          when(() => mockStockRepository.updateStok(any(), any()))
              .thenAnswer((_) async => 1);
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => testStocks);
          return stockBloc;
        },
        act: (bloc) => bloc.add(updateStockEvent),
        verify: (_) {
          final capturedArgs = verify(() => mockStockRepository.updateStok(
            captureAny(),
            testStock.idStock,
          )).captured.first as Map<String, dynamic>;
          
          expect(capturedArgs['stock_name'], equals('Updated Stock'));
          expect(capturedArgs['stock_quantity'], equals('75'));
          expect(capturedArgs['id_stock_type'], equals('type-2'));
          expect(capturedArgs['stock_threshold'], equals(8));
          expect(capturedArgs['price'], equals(4000));
        },
      );
    });

    group('DeleteStock', () {
      const stockIdToDelete = 'stock-1';
      final deleteStockEvent = DeleteStock(stockIdToDelete);

      blocTest<StockBloc, StockState>(
        'emits [StockLoaded] when DeleteStock is successful',
        build: () {
          when(() => mockStockRepository.deleteStok(any()))
              .thenAnswer((_) async => 1);
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => <Stock>[]);
          return stockBloc;
        },
        act: (bloc) => bloc.add(deleteStockEvent),
        expect: () => [
          isA<StockLoaded>().having(
            (state) => state.stocks,
            'stocks',
            isEmpty,
          ),
        ],
        verify: (_) {
          verify(() => mockStockRepository.deleteStok(stockIdToDelete)).called(1);
          verify(() => mockStockRepository.getAllStocks()).called(1);
        },
      );
    });

    group('SearchStock', () {
      const searchQuery = 'test';
      final searchStockEvent = SearchStock(searchQuery);

      blocTest<StockBloc, StockState>(
        'emits [StockLoaded] when SearchStock is successful',
        build: () {
          when(() => mockStockRepository.searchStocks(any()))
              .thenAnswer((_) async => testStocks);
          return stockBloc;
        },
        act: (bloc) => bloc.add(searchStockEvent),
        expect: () => [
          isA<StockLoaded>().having(
            (state) => state.stocks,
            'stocks',
            equals(testStocks),
          ),
        ],
        verify: (_) {
          verify(() => mockStockRepository.searchStocks(searchQuery)).called(1);
        },
      );

      blocTest<StockBloc, StockState>(
        'emits [StockLoaded] with empty list when no stocks match search',
        build: () {
          when(() => mockStockRepository.searchStocks(any()))
              .thenAnswer((_) async => <Stock>[]);
          return stockBloc;
        },
        act: (bloc) => bloc.add(searchStockEvent),
        expect: () => [
          isA<StockLoaded>().having(
            (state) => state.stocks,
            'stocks',
            isEmpty,
          ),
        ],
      );
    });

    group('State transitions', () {
      blocTest<StockBloc, StockState>(
        'maintains state consistency during multiple operations',
        build: () {
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => testStocks);
          when(() => mockStockRepository.deleteStok(any()))
              .thenAnswer((_) async => 1);
          return stockBloc;
        },
        act: (bloc) {
          bloc.add(LoadStock());
          bloc.add(DeleteStock('stock-1'));
        },
        expect: () => [
          isA<StockLoading>(),
          isA<StockLoaded>(),
          isA<StockLoaded>(),
        ],
      );

      blocTest<StockBloc, StockState>(
        'handles search then load operations correctly',
        build: () {
          when(() => mockStockRepository.searchStocks(any()))
              .thenAnswer((_) async => [testStock]);
          when(() => mockStockRepository.getAllStocks())
              .thenAnswer((_) async => testStocks);
          return stockBloc;
        },
        act: (bloc) {
          bloc.add(SearchStock('test'));
          bloc.add(LoadStock());
        },
        expect: () => [
          isA<StockLoading>(),
          isA<StockLoaded>(),
          isA<StockLoaded>(),
        ],
      );
    });
  });
} 