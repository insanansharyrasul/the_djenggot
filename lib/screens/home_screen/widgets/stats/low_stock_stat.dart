import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/screens/home_screen/widgets/loading_error_widget.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stat_value.dart';

class LowStockStat extends StatelessWidget {
  const LowStockStat({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoaded) {
          int lowStockCount = 0;
          for (var stock in state.stocks) {
            if (stock.stockThreshold != null && stock.stockQuantity <= stock.stockThreshold!) {
              lowStockCount++;
            }
          }

          return StatValue(
            value: lowStockCount.toString(),
            percentage: "",
            showPercentage: false,
          );
        }
        return const LoadingErrorWidget();
      },
    );
  }
}
