import 'package:go_router/go_router.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/models/type/menu_type.dart';
import 'package:the_djenggot/models/type/stock_type.dart';
import 'package:the_djenggot/screens/menu/add_edit_menu_screen.dart';
import 'package:the_djenggot/screens/menu/add_edit_menu_type_screen.dart';
import 'package:the_djenggot/screens/stock/add_edit_stock_screen.dart';
import 'package:the_djenggot/screens/dashboard_screen.dart';
import 'package:the_djenggot/screens/stock/add_edit_stock_type_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
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
  ],
);
