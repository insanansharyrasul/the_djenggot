import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/screens/home_screen/widgets/loading_error_widget.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class DailySalesChart extends StatelessWidget {
  const DailySalesChart({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          // Calculate daily sales for the last 7 days
          final now = DateTime.now();
          final List<double> dailyValues = List.filled(7, 0.0);
          final List<String> dayLabels = [];

          // Generate labels for the last 7 days
          for (int i = 6; i >= 0; i--) {
            final day = now.subtract(Duration(days: i));
            dayLabels.add(DateFormat('E').format(day)); // Short day name

            // Calculate sales for each day
            for (var transaction in state.transactions) {
              final transactionDate = DateTime.parse(transaction.timestamp);
              if (transactionDate.year == day.year &&
                  transactionDate.month == day.month &&
                  transactionDate.day == day.day) {
                dailyValues[6 - i] += transaction.transactionAmount;
              }
            }
          }

          // Find the maximum value for scaling
          final maxValue = dailyValues.isNotEmpty
              ? dailyValues.reduce((max, value) => value > max ? value : max)
              : 0.0;

          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withAlpha(26),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Iconsax.graph,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Penjualan 7 Hari Terakhir",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: List.generate(7, (index) {
                        final value = dailyValues[index];
                        final height = maxValue > 0 ? (value / maxValue) * 80 : 0.0;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: height.clamp(4, 80),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  dayLabels[index],
                                  style: const TextStyle(fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const LoadingErrorWidget();
      },
    );
  }
}
