import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/routing/app_router.dart';
import 'package:the_djenggot/bloc/providers.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Request storage permissions at app startup
  await _requestPermissions();

  runApp(MultiBlocProvider(
    providers: getTypeProviders(),
    child: const MainApp(),
  ));
}

Future<void> _requestPermissions() async {
  // For Android 13+ (API 33+), request the new granular permissions
  if (Platform.isAndroid) {
    // Force request these permissions to ensure the dialog appears
    await Permission.storage.request();

    // For Android 11+ (API 30+), need special permission for managing all files
    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      // Permission has been permanently denied, direct user to settings
      openAppSettings();
    } else {
      // Request the permission
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
        primaryColor: AppTheme.background,
        cardTheme: CardTheme(
          color: AppTheme.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        scaffoldBackgroundColor: AppTheme.background,
        appBarTheme: const AppBarTheme(
          elevation: 5,
          foregroundColor: AppTheme.white,
          backgroundColor: AppTheme.white,
          iconTheme: IconThemeData(
            color: AppTheme.nearlyBlack,
          ),
          shadowColor: AppTheme.white,
          surfaceTintColor: AppTheme.white,
          centerTitle: true,
          titleTextStyle: AppTheme.appBarTitle,
          scrolledUnderElevation: 5,
        ),
      ),
    );
  }
}
