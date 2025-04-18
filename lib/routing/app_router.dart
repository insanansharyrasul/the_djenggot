import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_state.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_state.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/screens/dashboard_screen.dart';
import 'package:the_djenggot/screens/menu/add_edit_menu_screen.dart';
import 'package:the_djenggot/screens/menu/add_edit_menu_type_screen.dart';
import 'package:the_djenggot/screens/stock/add_edit_stock_screen.dart';
import 'package:the_djenggot/screens/stock/add_edit_stock_type_screen.dart';
import 'package:the_djenggot/screens/transaction/add_edit_transaction_type_screen.dart';
import 'package:the_djenggot/screens/type/menu_type_list_screen.dart';
import 'package:the_djenggot/screens/type/stock_type_list_screen.dart';
import 'package:the_djenggot/screens/type/transaction_type_list_screen.dart';
// Import other necessary screens

class AppRouter {
  final MenuTypeBloc menuTypeBloc;
  final StockTypeBloc stockTypeBloc;
  final TransactionTypeBloc transactionTypeBloc;
  // Other BLoCs

  AppRouter({
    required this.menuTypeBloc,
    required this.stockTypeBloc,
    required this.transactionTypeBloc,
    // Other BLoCs
  });

  GoRouter get router => GoRouter(
        routes: [
          // Existing routes

          GoRoute(
            path: '/',
            builder: (context, state) {
              return DashboardScreen();
            },
          ),
          GoRoute(
            path: '/add-edit-stock',
            builder: (context, state) {
              final stock = state.extra as Stock?;
              return AddEditStockScreen(stock: stock);
            },
          ),
          GoRoute(
            path: '/add-edit-menu',
            builder: (context, state) {
              return const AddEditMenuScreen();
            },
          ),
          GoRoute(
            path: '/add-edit-menu-type',
            builder: (context, state) {
              final menuType = state.extra as MenuType?;
              return AddEditMenuTypeScreen(menuType: menuType);
            },
          ),
          GoRoute(
            path: '/add-edit-stock-type',
            builder: (context, state) {
              final stockType = state.extra as StockType?;
              return AddEditStockTypeScreen(stockType: stockType);
            },
          ),

          // Menu Type routes
          GoRoute(
            path: '/menu-types',
            builder: (context, state) => const MenuTypeListScreen(),
          ),

          GoRoute(
            path: '/add-menu-type',
            builder: (context, state) => const AddEditMenuTypeScreen(),
          ),
          GoRoute(
            path: '/edit-menu-type/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final menuTypeState = menuTypeBloc.state;

              if (menuTypeState is MenuTypeLoaded) {
                final menuType = menuTypeState.menuTypes.firstWhere(
                  (type) => type.idMenuType == id,
                  orElse: () => MenuType(idMenuType: '', menuTypeName: ''),
                );

                return AddEditMenuTypeScreen(menuType: menuType);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),

          // Stock Type routes
          GoRoute(
            path: '/stock-types',
            builder: (context, state) => const StockTypeListScreen(),
          ),

          GoRoute(
            path: '/add-stock-type',
            builder: (context, state) => const AddEditStockTypeScreen(),
          ),
          GoRoute(
            path: '/edit-stock-type/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final stockTypeState = stockTypeBloc.state;

              if (stockTypeState is StockTypeLoaded) {
                final stockType = stockTypeState.stockTypes.firstWhere(
                  (type) => type.idStockType == id,
                  orElse: () => StockType(idStockType: '', stockTypeName: ''),
                );

                return AddEditStockTypeScreen(stockType: stockType);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),

          // Transaction Type routes
          GoRoute(
            path: '/transaction-types',
            builder: (context, state) => const TransactionTypeListScreen(),
          ),

          GoRoute(
            path: '/add-transaction-type',
            builder: (context, state) => const AddEditTransactionTypeScreen(),
          ),

          GoRoute(
            path: '/edit-transaction-type/:id',
            builder: (context, state) {
              final id = state.pathParameters['id'] ?? '';
              final transactionTypeState = transactionTypeBloc.state;

              if (transactionTypeState is TransactionTypeLoaded) {
                final transactionType = transactionTypeState.transactionTypes.firstWhere(
                  (type) => type.idTransactionType == id,
                  orElse: () => TransactionType(idTransactionType: '', transactionTypeName: ''),
                );

                return AddEditTransactionTypeScreen(transactionType: transactionType);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      );
}
