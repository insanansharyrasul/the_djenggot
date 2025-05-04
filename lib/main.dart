import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/database/dummy_generator.dart';
import 'package:the_djenggot/routing/app_router.dart';
import 'package:the_djenggot/bloc/providers.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'dart:io';

void main() async {
  if (kReleaseMode) {
    WidgetsFlutterBinding.ensureInitialized();
    await _requestPermissions();

    runApp(MultiBlocProvider(
      providers: getTypeProviders(),
      child: const MainApp(),
    ));
  } else {
    print('Running in debug mode');
    WidgetsFlutterBinding.ensureInitialized();
    await _requestPermissions();

    final dummyDataGenerator = DummyDataGenerator();
    await dummyDataGenerator.generateDummyData();

    runApp(MultiBlocProvider(
      providers: getTypeProviders(),
      child: const MainApp(),
    ));
  }
}

Future<void> _requestPermissions() async {
  if (Platform.isAndroid) {
    await Permission.storage.request();
    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      openAppSettings();
    } else {
      await Permission.manageExternalStorage.request();
    }
  }
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
        fontFamily: AppTheme.fontName,
        primaryColor: AppTheme.white,
        cardTheme: CardTheme(
          color: AppTheme.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        scaffoldBackgroundColor: AppTheme.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: AppTheme.white,
          iconTheme: IconThemeData(
            color: AppTheme.nearlyBlack,
          ),
          shadowColor: AppTheme.white,
          surfaceTintColor: AppTheme.white,
          // centerTitle: true,
          titleTextStyle: AppTheme.appBarTitle,
          scrolledUnderElevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
        canvasColor: AppTheme.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primary,
          primary: AppTheme.primary,
        ),
        dialogTheme: const DialogTheme(
          backgroundColor: AppTheme.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
        ),
      ),
    );
  }
}
