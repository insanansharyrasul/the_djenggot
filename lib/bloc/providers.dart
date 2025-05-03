import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/profit_loss/profit_loss_bloc.dart';
import 'package:the_djenggot/bloc/profit_loss/profit_loss_event.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_event.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_bloc.dart';
import 'package:the_djenggot/bloc/type/transaction_type/transaction_type_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/repository/menu_repository.dart';
import 'package:the_djenggot/repository/type/menu_type_repository.dart';
import 'package:the_djenggot/repository/profit_loss/profit_loss_repository.dart';
import 'package:the_djenggot/repository/stock_repository.dart';
import 'package:the_djenggot/repository/stock/stock_history_repository.dart';
import 'package:the_djenggot/repository/type/stock_type_repository.dart';
import 'package:the_djenggot/repository/type/transaction_type_repository.dart';
import 'package:the_djenggot/repository/transaction/transaction_repository.dart';

List<BlocProvider> getTypeProviders() {
  return [
    BlocProvider<StockBloc>(
      create: (context) => StockBloc(
        StockRepository(),
      )..add(LoadStock()),
    ),
    BlocProvider<StockHistoryBloc>(
      create: (context) => StockHistoryBloc(
        stockHistoryRepository: StockHistoryRepository(),
      )..add(LoadStockHistory()),
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
        stockTypeRepository: StockTypeRepository(),
      )..add(LoadStockTypes()),
    ),
    BlocProvider<TransactionTypeBloc>(
      create: (context) => TransactionTypeBloc(
        TransactionTypeRepository(),
      )..add(LoadTransactionTypes()),
    ),
    BlocProvider<TransactionBloc>(
      create: (context) => TransactionBloc(
        TransactionRepository(),
      )..add(LoadTransactions()),
    ),
    BlocProvider<ProfitLossBloc>(
      create: (context) => ProfitLossBloc(
        profitLossRepository: ProfitLossRepository(),
      )..add(LoadProfitLossData(
          startDate: DateTime.now().subtract(const Duration(days: 30)),
          endDate: DateTime.now(),
        )),
    ),
  ];
}
