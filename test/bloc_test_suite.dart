import 'package:flutter_test/flutter_test.dart';

// BLoC tests
import 'bloc/menu/menu_bloc_test.dart' as menu_bloc_test;
import 'bloc/transaction/transaction_bloc_test.dart' as transaction_bloc_test;
import 'bloc/stock/stock_bloc_test.dart' as stock_bloc_test;
import 'bloc/profit_loss/profit_loss_bloc_test.dart' as profit_loss_bloc_test;
import 'bloc/stock/stock_history/stock_history_bloc_test.dart' as stock_history_bloc_test;

// Model tests
import 'models/model_test_suite.dart' as model_test_suite;

void main() {
  group('The Djenggot Test Suite', () {
    group('BLoC Tests', () {
      menu_bloc_test.main();
      transaction_bloc_test.main();
      stock_bloc_test.main();
      profit_loss_bloc_test.main();
      stock_history_bloc_test.main();
    });

    group('Model Tests', () {
      model_test_suite.main();
    });
  });
} 