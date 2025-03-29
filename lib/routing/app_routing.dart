import 'package:go_router/go_router.dart';
import 'package:the_djenggot/screens/stock_screen.dart';
import 'package:the_djenggot/screens/dashboard_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return DashboardScreen();
      },
    ),
    GoRoute(
      path: '/stock',
      builder: (context, state) {
        return StockScreen();
      },
    ),
  ],
);
