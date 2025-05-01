import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/screens/home_screen/widgets/loading_error_widget.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stat_value.dart';
import 'package:the_djenggot/utils/currency_formatter_util.dart';

class MonthlyIncomeStat extends StatelessWidget {
  const MonthlyIncomeStat({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          final now = DateTime.now();
          final currentMonth = DateTime(now.year, now.month);
          final previousMonth = DateTime(
              currentMonth.month > 1 ? currentMonth.year : currentMonth.year - 1,
              currentMonth.month > 1 ? currentMonth.month - 1 : 12);

          int totalIncome = 0;
          int previousMonthIncome = 0;

          for (var transaction in state.transactions) {
            final transactionDate = DateTime.parse(transaction.timestamp);

            if (transactionDate.year == currentMonth.year &&
                transactionDate.month == currentMonth.month) {
              totalIncome += transaction.moneyReceived;
            }

            if (transactionDate.year == previousMonth.year &&
                transactionDate.month == previousMonth.month) {
              previousMonthIncome += transaction.moneyReceived;
            }
          }

          // Use our compact currency formatter for more readable display
          String formattedTotal = CurrencyFormatterUtil.formatCurrency(totalIncome)
              .replaceAll("Rp", ""); // Remove the Rp prefix for cleaner stats display

          String percentageText = "";
          bool isPositive = true;
          double percentageChange = 0;

          if (previousMonthIncome > 0) {
            percentageChange = ((totalIncome - previousMonthIncome) / previousMonthIncome) * 100;
            isPositive = percentageChange >= 0;
            percentageText = "${percentageChange.abs().toStringAsFixed(1)}%";
          }

          return StatValue(
            value: formattedTotal,
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
