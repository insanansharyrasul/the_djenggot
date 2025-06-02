import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:the_djenggot/bloc/profit_loss/profit_loss_bloc.dart';
import 'package:the_djenggot/bloc/profit_loss/profit_loss_event.dart';
import 'package:the_djenggot/bloc/profit_loss/profit_loss_state.dart';
import 'package:the_djenggot/models/profit_loss/profit_loss.dart';
import 'package:the_djenggot/repository/profit_loss/profit_loss_repository.dart';

// Mock classes
class MockProfitLossRepository extends Mock implements ProfitLossRepository {}

void main() {
  group('ProfitLossBloc', () {
    late ProfitLossBloc profitLossBloc;
    late MockProfitLossRepository mockProfitLossRepository;

    // Test data
    final startDate = DateTime(2023);
    final endDate = DateTime(2023, 1, 31);

    final testProfitLossData = [
      ProfitLoss(
        date: DateTime(2023),
        income: 100000,
        expenses: 60000,
        netProfit: 40000,
      ),
      ProfitLoss(
        date: DateTime(2023, 1, 2),
        income: 150000,
        expenses: 80000,
        netProfit: 70000,
      ),
    ];

    final testExpenseCategories = [
      ExpenseCategory(name: 'Raw Materials', amount: 50000),
      ExpenseCategory(name: 'Packaging', amount: 30000),
    ];

    final testSummary = ProfitLoss(
      date: startDate,
      income: 250000,
      expenses: 140000,
      netProfit: 110000,
    );

    setUp(() {
      mockProfitLossRepository = MockProfitLossRepository();
      profitLossBloc = ProfitLossBloc(profitLossRepository: mockProfitLossRepository);
    });

    tearDown(() {
      profitLossBloc.close();
    });

    test('initial state is ProfitLossInitial', () {
      expect(profitLossBloc.state, isA<ProfitLossInitial>());
    });

    group('LoadProfitLossData', () {
      final loadEvent = LoadProfitLossData(startDate: startDate, endDate: endDate);

      blocTest<ProfitLossBloc, ProfitLossState>(
        'emits [ProfitLossLoading, ProfitLossLoaded] when LoadProfitLossData is successful',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenAnswer((_) async => testProfitLossData);
          when(() => mockProfitLossRepository.getExpenseCategories(any(), any()))
              .thenAnswer((_) async => testExpenseCategories);
          when(() => mockProfitLossRepository.getSummary(any(), any()))
              .thenAnswer((_) async => testSummary);
          return profitLossBloc;
        },
        act: (bloc) => bloc.add(loadEvent),
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossLoaded>().having(
            (state) => state.profitLossData,
            'profitLossData',
            equals(testProfitLossData),
          ).having(
            (state) => state.expenseCategories,
            'expenseCategories',
            equals(testExpenseCategories),
          ).having(
            (state) => state.summary,
            'summary',
            equals(testSummary),
          ).having(
            (state) => state.startDate,
            'startDate',
            equals(startDate),
          ).having(
            (state) => state.endDate,
            'endDate',
            equals(endDate),
          ),
        ],
        verify: (_) {
          verify(() => mockProfitLossRepository.getProfitLossData(startDate, endDate)).called(1);
          verify(() => mockProfitLossRepository.getExpenseCategories(startDate, endDate)).called(1);
          verify(() => mockProfitLossRepository.getSummary(startDate, endDate)).called(1);
        },
      );

      blocTest<ProfitLossBloc, ProfitLossState>(
        'emits [ProfitLossLoading, ProfitLossLoaded] with empty data when no data found',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenAnswer((_) async => <ProfitLoss>[]);
          when(() => mockProfitLossRepository.getExpenseCategories(any(), any()))
              .thenAnswer((_) async => <ExpenseCategory>[]);
          when(() => mockProfitLossRepository.getSummary(any(), any()))
              .thenAnswer((_) async => ProfitLoss(
                    date: startDate,
                    income: 0,
                    expenses: 0,
                    netProfit: 0,
                  ));
          return profitLossBloc;
        },
        act: (bloc) => bloc.add(loadEvent),
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossLoaded>().having(
            (state) => state.profitLossData,
            'profitLossData',
            isEmpty,
          ).having(
            (state) => state.expenseCategories,
            'expenseCategories',
            isEmpty,
          ),
        ],
      );

      blocTest<ProfitLossBloc, ProfitLossState>(
        'emits [ProfitLossLoading, ProfitLossError] when LoadProfitLossData fails on getProfitLossData',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenThrow(Exception('Database error'));
          return profitLossBloc;
        },
        act: (bloc) => bloc.add(loadEvent),
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );

      blocTest<ProfitLossBloc, ProfitLossState>(
        'emits [ProfitLossLoading, ProfitLossError] when LoadProfitLossData fails on getExpenseCategories',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenAnswer((_) async => testProfitLossData);
          when(() => mockProfitLossRepository.getExpenseCategories(any(), any()))
              .thenThrow(Exception('Database error'));
          return profitLossBloc;
        },
        act: (bloc) => bloc.add(loadEvent),
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );

      blocTest<ProfitLossBloc, ProfitLossState>(
        'emits [ProfitLossLoading, ProfitLossError] when LoadProfitLossData fails on getSummary',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenAnswer((_) async => testProfitLossData);
          when(() => mockProfitLossRepository.getExpenseCategories(any(), any()))
              .thenAnswer((_) async => testExpenseCategories);
          when(() => mockProfitLossRepository.getSummary(any(), any()))
              .thenThrow(Exception('Database error'));
          return profitLossBloc;
        },
        act: (bloc) => bloc.add(loadEvent),
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );
    });

    group('ChangeProfitLossDateRange', () {
      final newStartDate = DateTime(2023, 2);
      final newEndDate = DateTime(2023, 2, 28);
      final changeDateRangeEvent = ChangeProfitLossDateRange(
        startDate: newStartDate,
        endDate: newEndDate,
      );

      final newProfitLossData = [
        ProfitLoss(
          date: DateTime(2023, 2),
          income: 120000,
          expenses: 70000,
          netProfit: 50000,
        ),
      ];

      final newExpenseCategories = [
        ExpenseCategory(name: 'Utilities', amount: 20000),
      ];

      final newSummary = ProfitLoss(
        date: newStartDate,
        income: 120000,
        expenses: 70000,
        netProfit: 50000,
      );

      blocTest<ProfitLossBloc, ProfitLossState>(
        'emits [ProfitLossLoading, ProfitLossLoaded] when ChangeProfitLossDateRange is successful',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(newStartDate, newEndDate))
              .thenAnswer((_) async => newProfitLossData);
          when(() => mockProfitLossRepository.getExpenseCategories(newStartDate, newEndDate))
              .thenAnswer((_) async => newExpenseCategories);
          when(() => mockProfitLossRepository.getSummary(newStartDate, newEndDate))
              .thenAnswer((_) async => newSummary);
          return profitLossBloc;
        },
        seed: () => ProfitLossLoaded(
          profitLossData: testProfitLossData,
          expenseCategories: testExpenseCategories,
          summary: testSummary,
          startDate: startDate,
          endDate: endDate,
        ),
        act: (bloc) => bloc.add(changeDateRangeEvent),
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossLoaded>().having(
            (state) => state.profitLossData,
            'profitLossData',
            equals(newProfitLossData),
          ).having(
            (state) => state.expenseCategories,
            'expenseCategories',
            equals(newExpenseCategories),
          ).having(
            (state) => state.summary,
            'summary',
            equals(newSummary),
          ).having(
            (state) => state.startDate,
            'startDate',
            equals(newStartDate),
          ).having(
            (state) => state.endDate,
            'endDate',
            equals(newEndDate),
          ),
        ],
        verify: (_) {
          verify(() => mockProfitLossRepository.getProfitLossData(newStartDate, newEndDate)).called(1);
          verify(() => mockProfitLossRepository.getExpenseCategories(newStartDate, newEndDate)).called(1);
          verify(() => mockProfitLossRepository.getSummary(newStartDate, newEndDate)).called(1);
        },
      );

      blocTest<ProfitLossBloc, ProfitLossState>(
        'emits [ProfitLossLoading, ProfitLossError] when ChangeProfitLossDateRange fails',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenThrow(Exception('Database error'));
          return profitLossBloc;
        },
        seed: () => ProfitLossLoaded(
          profitLossData: testProfitLossData,
          expenseCategories: testExpenseCategories,
          summary: testSummary,
          startDate: startDate,
          endDate: endDate,
        ),
        act: (bloc) => bloc.add(changeDateRangeEvent),
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossError>().having(
            (state) => state.message,
            'message',
            contains('Exception: Database error'),
          ),
        ],
      );
    });

    group('State transitions', () {
      blocTest<ProfitLossBloc, ProfitLossState>(
        'maintains state consistency during multiple date range changes',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenAnswer((_) async => testProfitLossData);
          when(() => mockProfitLossRepository.getExpenseCategories(any(), any()))
              .thenAnswer((_) async => testExpenseCategories);
          when(() => mockProfitLossRepository.getSummary(any(), any()))
              .thenAnswer((_) async => testSummary);
          return profitLossBloc;
        },
        act: (bloc) {
          bloc.add(LoadProfitLossData(startDate: startDate, endDate: endDate));
          bloc.add(ChangeProfitLossDateRange(
            startDate: DateTime(2023, 2),
            endDate: DateTime(2023, 2, 28),
          ));
        },
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossLoaded>(),
          isA<ProfitLossLoaded>(),
        ],
      );

      blocTest<ProfitLossBloc, ProfitLossState>(
        'handles load after error state correctly',
        build: () {
          when(() => mockProfitLossRepository.getProfitLossData(any(), any()))
              .thenThrow(Exception('Database error'));
          return profitLossBloc;
        },
        act: (bloc) {
          bloc.add(LoadProfitLossData(startDate: startDate, endDate: endDate));
          // Add another event to test recovery
          bloc.add(LoadProfitLossData(startDate: startDate, endDate: endDate));
        },
        expect: () => [
          isA<ProfitLossLoading>(),
          isA<ProfitLossError>(),
          isA<ProfitLossLoading>(),
          isA<ProfitLossError>(),
        ],
      );
    });
  });
} 