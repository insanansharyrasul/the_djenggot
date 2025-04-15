import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_event.dart';
import 'package:the_djenggot/repository/menu_repository.dart';
import 'package:the_djenggot/repository/type/menu_type_repository.dart';
import 'package:the_djenggot/repository/stock_repository.dart';
import 'package:the_djenggot/repository/type/stock_type_repository.dart';
import 'package:the_djenggot/repository/type/transaction_type_repository.dart';

List<BlocProvider> getTypeProviders() {
  return [
    BlocProvider<StockBloc>(
      create: (context) => StockBloc(
        StockRepository(),
      )..add(LoadStock()),
    ),
    BlocProvider<MenuBloc>(
      create: (context) => MenuBloc(
        MenuRepository(),
      )..add(LoadMenu()),
    ),
    BlocProvider<MenuTypeBloc>(
      create: (context) => MenuTypeBloc(
        MenuTypeRepository(),
      )..add(LoadMenuTypes()),
    ),
    BlocProvider<StockTypeBloc>(
      create: (context) => StockTypeBloc(
        StockTypeRepository(),
      )..add(LoadStockTypes()),
    ),
    BlocProvider<TransactionTypeBloc>(
      create: (context) => TransactionTypeBloc(
        TransactionTypeRepository(),
      )..add(LoadTransactionTypes()),
    ),
  ];
}
