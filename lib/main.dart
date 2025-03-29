import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/routing/app_routing.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

void main() async {
  runApp(MultiBlocProvider(
    providers: [
      // BlocProvider(
      //   create: (context) => NavigationBloc(),
      // ),
      BlocProvider(
        create: (context) => StockBloc(),
      ),
    ],
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'TheDjenggot',
      theme: ThemeData(
          primaryColor: DjenggotAppTheme.background,
          scaffoldBackgroundColor: DjenggotAppTheme.background),
    );
  }
}
