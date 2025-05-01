import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/screens/home_screen/widgets/loading_error_widget.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stat_value.dart';

class TotalStockStat extends StatelessWidget {
  const TotalStockStat({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoaded) {
          final int uniqueStocksCount = state.stocks.length;

          return StatValue(
            value: uniqueStocksCount.toString(),
            percentage: "",
            showPercentage: false,
          );
        }
        return const LoadingErrorWidget();
      },
    );
  }
}
