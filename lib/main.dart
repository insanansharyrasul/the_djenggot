import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/database/database.dart';
import 'package:the_djenggot/repository/menu_repository.dart';
import 'package:the_djenggot/routing/app_routing.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

void main() async {
  runApp(MultiBlocProvider(
    providers: [
      BlocProvider<StockBloc>(
        create: (context) => StockBloc(
          DatabaseHelper.instance,
        )..add(LoadStock()),
      ),
      BlocProvider<MenuBloc>(
        create: (context) => MenuBloc(
          MenuRepository(),
        )..add(LoadMenu()),
      )
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
        primaryColor: AppTheme.background,
        scaffoldBackgroundColor: AppTheme.background,
      ),
    );
  }
}
