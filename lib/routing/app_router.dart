import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_state.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_state.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_state.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_state.dart';
import 'package:the_djenggot/models/menu.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/models/type/transaction_type.dart';
import 'package:the_djenggot/screens/page_manager_screen.dart';
import 'package:the_djenggot/screens/menu/add_edit_menu_screen.dart';
import 'package:the_djenggot/screens/menu/add_edit_menu_type_screen.dart';
import 'package:the_djenggot/screens/menu/menu_detail_screen.dart';
import 'package:the_djenggot/screens/stock/add_edit_stock_screen.dart';
import 'package:the_djenggot/screens/stock/add_edit_stock_type_screen.dart';
import 'package:the_djenggot/screens/stock/stock_analytics_screen.dart';
import 'package:the_djenggot/screens/stock/stock_detail_screen.dart';
import 'package:the_djenggot/screens/stock/stock_history_screen.dart';
import 'package:the_djenggot/screens/transaction/add_edit_transaction_type_screen.dart';
import 'package:the_djenggot/screens/transaction/add_transaction_screen.dart';
import 'package:the_djenggot/screens/transaction/transaction_detail_screen.dart';
import 'package:the_djenggot/screens/transaction/transaction_list_screen.dart';
import 'package:the_djenggot/screens/type/menu_type_list_screen.dart';
import 'package:the_djenggot/screens/type/stock_type_list_screen.dart';
import 'package:the_djenggot/screens/type/transaction_type_list_screen.dart';

class AppRouter {
  final MenuTypeBloc menuTypeBloc;
  final StockTypeBloc stockTypeBloc;
  final TransactionTypeBloc transactionTypeBloc;
  final MenuBloc menuBloc;

  AppRouter(
      {required this.menuTypeBloc,
      required this.stockTypeBloc,
      required this.transactionTypeBloc,
      required this.menuBloc});

  GoRouter get router => GoRouter(
        routes: [
          // ==========================================
          // DASHBOARD
          // ==========================================
          GoRoute(
            path: '/',
            builder: (context, state) {
              return const PageManagerScreen();
            },
          ),

          // ==========================================
          // MENU ROUTES
          // ==========================================
          GoRoute(
            path: '/menu-detail/:id',
            builder: (BuildContext context, GoRouterState state) {
              final menuState = menuBloc.state;
              final id = state.pathParameters['id'] ?? '';

              if (menuState is MenuLoaded) {
                final menu = menuState.menus.firstWhere(
                  (menu) => menu.idMenu == id,
                );
                return MenuDetailScreen(menu: menu);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),
          GoRoute(
            path: '/add-edit-menu',
            builder: (context, state) {
              final menu = state.extra as Menu?;
              return AddEditMenuScreen(menu: menu);
            },
          ),
          GoRoute(
            path: '/edit-menu',
            builder: (context, state) {
              final menu = state.extra as Menu;
              return AddEditMenuScreen(menu: menu);
            },
          ),

          // ==========================================
          // STOCK ROUTES
          // ==========================================
          GoRoute(
            path: '/stock-history',
            builder: (context, state) {
              return const StockHistoryScreen();
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
            path: '/add-edit-menu-type',
            builder: (context, state) {
              final menuType = state.extra as MenuType?;
              return AddEditMenuTypeScreen(menuType: menuType);
            },
          ),

          // STOCK
          GoRoute(
            path: '/add-edit-stock-type',
            builder: (context, state) {
              final stockType = state.extra as StockType?;
              return AddEditStockTypeScreen(stockType: stockType);
            },
          ),
          GoRoute(
            path: '/stock-detail',
            builder: (context, state) => StockDetailScreen(
              stock: state.extra as Stock,
            ),
          ),
          GoRoute(
            path: '/stock-analytics',
            builder: (context, state) => const StockAnalyticsScreen(),
          ),

          // ==========================================
          // MENU TYPE ROUTES
          // ==========================================
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
                  orElse: () => const MenuType(
                    idMenuType: '',
                    menuTypeName: '',
                    menuTypeIcon: '',
                  ),
                );

                return AddEditMenuTypeScreen(menuType: menuType);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),

          // ==========================================
          // STOCK TYPE ROUTES
          // ==========================================
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
                  orElse: () => const StockType(
                    idStockType: '',
                    stockTypeName: '',
                    stockUnit: '',
                    stockTypeIcon: '',
                  ),
                );

                return AddEditStockTypeScreen(stockType: stockType);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),

          // ==========================================
          // TRANSACTION TYPE ROUTES
          // ==========================================
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
              final transactionTypeState = transactionTypeBloc.state;
              final id = state.pathParameters['id'] ?? '';

              if (transactionTypeState is TransactionTypeLoaded) {
                final transactionType = transactionTypeState.transactionTypes.firstWhere(
                  (type) => type.idTransactionType == id,
                  orElse: () => const TransactionType(
                    idTransactionType: '',
                    transactionTypeName: '',
                    transactionTypeIcon: '',
                  ),
                );

                return AddEditTransactionTypeScreen(transactionType: transactionType);
              }

              return const Center(child: CircularProgressIndicator());
            },
          ),

          // ==========================================
          // TRANSACTION ROUTES
          // ==========================================
          GoRoute(
            path: '/transactions',
            builder: (BuildContext context, GoRouterState state) {
              return const TransactionListScreen();
            },
          ),
          GoRoute(
            path: '/add-transaction',
            builder: (BuildContext context, GoRouterState state) {
              return const AddTransactionScreen();
            },
          ),
          GoRoute(
            path: '/transaction-detail/:id',
            builder: (BuildContext context, GoRouterState state) {
              final id = state.pathParameters['id']!;
              return TransactionDetailScreen(id: id);
            },
          ),
        ],
      );
}
