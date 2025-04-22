import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/routing/app_router.dart';
import 'package:the_djenggot/bloc/providers.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

void main() async {
  runApp(MultiBlocProvider(
    providers: getTypeProviders(),
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final menuTypeBloc = context.read<MenuTypeBloc>();
    final stockTypeBloc = context.read<StockTypeBloc>();
    final transactionTypeBloc = context.read<TransactionTypeBloc>();
    final menuBloc = context.read<MenuBloc>();
    final appRouter = AppRouter(
      menuTypeBloc: menuTypeBloc,
      stockTypeBloc: stockTypeBloc,
      transactionTypeBloc: transactionTypeBloc,
      menuBloc: menuBloc,
    );

    return MaterialApp.router(
      routerConfig: appRouter.router,
      title: 'TheDjenggot',
      theme: ThemeData(
        primaryColor: AppTheme.background,
        scaffoldBackgroundColor: AppTheme.background,
      ),
    );
  }
}
