# Test Suite Documentation

This directory contains comprehensive unit tests for **The Djenggot** Flutter application, covering both BLoC (Business Logic Components) and Model classes.

## Test Structure

```
test/
├── bloc/                          # BLoC unit tests
│   ├── menu/
│   │   └── menu_bloc_test.dart
│   ├── transaction/
│   │   └── transaction_bloc_test.dart
│   ├── stock/
│   │   ├── stock_bloc_test.dart
│   │   └── stock_history/
│   │       └── stock_history_bloc_test.dart
│   └── profit_loss/
│       └── profit_loss_bloc_test.dart
├── models/                        # Model unit tests
│   ├── type/                      # Type model tests
│   │   ├── menu_type_test.dart
│   │   ├── stock_type_test.dart
│   │   └── transaction_type_test.dart
│   ├── menu_test.dart
│   ├── stock_test.dart
│   └── model_test_suite.dart      # Model test runner
├── bloc_test_suite.dart           # Main test runner
└── README.md                      # This file
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Categories

**BLoC Tests Only:**
```bash
flutter test test/bloc/
```

**Model Tests Only:**
```bash
flutter test test/models/
```

**Individual BLoC Tests:**
```bash
flutter test test/bloc/menu/menu_bloc_test.dart
flutter test test/bloc/transaction/transaction_bloc_test.dart
flutter test test/bloc/stock/stock_bloc_test.dart
flutter test test/bloc/profit_loss/profit_loss_bloc_test.dart
flutter test test/bloc/stock/stock_history/stock_history_bloc_test.dart
```

**Individual Model Tests:**
```bash
flutter test test/models/menu_test.dart
flutter test test/models/stock_test.dart
flutter test test/models/type/menu_type_test.dart
flutter test test/models/type/stock_type_test.dart
flutter test test/models/type/transaction_type_test.dart
```

**Test Suites:**
```bash
flutter test test/bloc_test_suite.dart          # All tests
flutter test test/models/model_test_suite.dart  # Models only
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Categories

### 1. BLoC Tests

Tests the business logic components using the `bloc_test` package. Each BLoC test covers:

- **State Management**: Initial states, state transitions, and state consistency
- **Event Handling**: All events are processed correctly with proper parameters
- **Repository Integration**: Mocked repository calls with verification
- **Error Handling**: Exception scenarios and error state management
- **Data Flow**: Complex scenarios with multiple sequential events

#### BLoC Test Coverage:
- **MenuBloc** (10 tests): Menu CRUD operations
- **TransactionBloc** (12 tests): Transaction management and history
- **StockBloc** (11 tests): Stock inventory operations
- **ProfitLossBloc** (8 tests): Financial data and date range filtering
- **StockHistoryBloc** (9 tests): Stock movement tracking

### 2. Model Tests

Tests the data models and their serialization logic. Each model test covers:

- **Construction**: Object creation with valid, invalid, and edge case parameters
- **Serialization**: `toMap()` and `fromMap()` methods with data type handling
- **Equality**: Equatable implementation (where applicable)
- **Immutability**: Data integrity and immutable properties
- **Edge Cases**: Large data, special characters, null values, empty data
- **Business Logic**: Domain-specific validation and behavior

#### Model Test Coverage:

**Type Models:**
- **MenuType** (15 tests): Menu categorization with equality testing
- **StockType** (18 tests): Stock categorization with units and equality
- **TransactionType** (21 tests): Transaction categorization with evidence flags and copyWith

**Main Models:**
- **Menu** (15 tests): Menu items with image handling and MenuType relationships
- **Stock** (20 tests): Stock items with StockType relationships and business logic

## Test Patterns and Best Practices

### BLoC Testing Pattern
```dart
blocTest<MyBloc, MyState>(
  'description of what is being tested',
  build: () {
    // Setup mocks and dependencies
    when(() => mockRepository.method()).thenAnswer((_) async => result);
    return myBloc;
  },
  act: (bloc) => bloc.add(MyEvent()),
  expect: () => [
    isA<LoadingState>(),
    isA<LoadedState>().having((state) => state.data, 'data', expectedData),
  ],
  verify: (_) {
    // Verify repository calls
    verify(() => mockRepository.method()).called(1);
  },
);
```

### Model Testing Pattern
```dart
group('ModelName', () {
  group('Constructor', () {
    test('creates model with valid parameters', () {
      final model = ModelName(/* parameters */);
      expect(model.property, equals(expectedValue));
    });
  });

  group('Serialization', () {
    test('fromMap creates correct model', () {
      final model = ModelName.fromMap(testMap);
      expect(model.property, equals(expectedValue));
    });

    test('toMap creates correct map', () {
      final map = testModel.toMap();
      expect(map, equals(expectedMap));
    });
  });
});
```

## Dependencies

### Required Test Dependencies
- `flutter_test`: Flutter testing framework
- `bloc_test`: BLoC testing utilities  
- `mocktail`: Mocking framework for repositories

### Test Data Management
- **Mock Repositories**: Using `mocktail` for clean dependency isolation
- **Test Data**: Consistent test data across all tests
- **Fallback Values**: Registered for complex types (Uint8List, Lists)

## Coverage Goals

- **BLoC Tests**: 100% line coverage for business logic
- **Model Tests**: 100% coverage for serialization and validation
- **Integration**: Repository calls and data transformations
- **Edge Cases**: Null safety, error conditions, boundary values

## Maintenance Guidelines

### Adding New Tests
1. Follow the established directory structure
2. Use consistent naming conventions (`*_test.dart`)
3. Include comprehensive test coverage (construction, serialization, edge cases)
4. Update the test suites (`bloc_test_suite.dart`, `model_test_suite.dart`)
5. Document any new test patterns or dependencies

### Test Data Standards
- Use realistic but simple test data
- Include edge cases (null, empty, large values)
- Test both success and failure scenarios
- Maintain data consistency across related tests

### Mock Standards
- Mock all external dependencies
- Verify important method calls
- Use `any()` matchers appropriately
- Register fallback values for complex types

## Current Test Status

✅ **Total Tests**: 166 tests passing
- **BLoC Tests**: 62 tests
- **Model Tests**: 104 tests

✅ **Coverage Areas**:
- State management and transitions
- Data serialization and validation
- Repository integration
- Error handling and edge cases
- Business logic validation

🔧 **Areas for Future Enhancement**:
- Integration tests for complete workflows
- Widget tests for UI components  
- Performance tests for large datasets
- Database integration tests

---

This testing strategy ensures robust, maintainable code with high confidence in the application's business logic and data handling capabilities. 