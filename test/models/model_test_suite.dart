import 'package:flutter_test/flutter_test.dart';

// Model tests
import 'menu_test.dart' as menu_test;
import 'stock_test.dart' as stock_test;

// Type model tests  
import 'type/menu_type_test.dart' as menu_type_test;
import 'type/stock_type_test.dart' as stock_type_test;
import 'type/transaction_type_test.dart' as transaction_type_test;

void main() {
  group('Model Tests', () {
    group('Type Models', () {
      menu_type_test.main();
      stock_type_test.main();
      transaction_type_test.main();
    });

    group('Main Models', () {
      menu_test.main();
      stock_test.main();
    });
  });
} 