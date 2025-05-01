import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:the_djenggot/screens/home_screen/widgets/loading_error_widget.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stat_value.dart';

class TotalSoldStat extends StatelessWidget {
  const TotalSoldStat({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final yesterday = today.subtract(const Duration(days: 1));

          int totalSold = 0;
          int yesterdaySold = 0;

          for (var transaction in state.transactions) {
            final transactionDate = DateTime.parse(transaction.timestamp);
            if (transactionDate.year == today.year &&
                transactionDate.month == today.month &&
                transactionDate.day == today.day) {
              for (TransactionItem item in transaction.items ?? []) {
                totalSold += item.transactionQuantity;
              }
            }

            if (transactionDate.year == yesterday.year &&
                transactionDate.month == yesterday.month &&
                transactionDate.day == yesterday.day) {
              for (TransactionItem item in transaction.items ?? []) {
                yesterdaySold += item.transactionQuantity;
              }
            }
          }

          String percentageText = "";
          bool isPositive = true;
          double percentageChange = 0;

          if (yesterdaySold > 0) {
            percentageChange = ((totalSold - yesterdaySold) / yesterdaySold) * 100;
            isPositive = percentageChange >= 0;
            percentageText = "${percentageChange.abs().toStringAsFixed(1)}%";
          }

          return StatValue(
            value: totalSold.toString(),
            percentage: percentageText,
            isPositive: isPositive,
            showPercentage: percentageText.isNotEmpty,
          );
        }
        return const LoadingErrorWidget();
      },
    );
  }
}
