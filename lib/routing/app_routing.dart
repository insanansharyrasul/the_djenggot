import 'package:go_router/go_router.dart';
import 'package:the_djenggot/screens/homepage.dart';
import 'package:the_djenggot/screens/splash_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      builder: (context, state) {
        return SplashScreen();
      },
    ),
    GoRoute(
        path: '/home',
        builder: (context, state) {
          return Homepage();
        })
  ],
);
