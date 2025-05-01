import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/screens/home_screen/widgets/loading_error_widget.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class TopSellingProducts extends StatelessWidget {
  const TopSellingProducts({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          // Get transactions from the current month
          final now = DateTime.now();
          final currentMonth = DateTime(now.year, now.month);

          // Create a map to count item occurrences
          final Map<String, int> productCounts = {};
          final Map<String, String> productNames = {};

          // Count item occurrences in transactions
          for (var transaction in state.transactions) {
            final transactionDate = DateTime.parse(transaction.timestamp);
            if (transactionDate.year == currentMonth.year &&
                transactionDate.month == currentMonth.month) {
              for (var item in transaction.items ?? []) {
                final id = item.menu.idMenu.toString();
                productCounts[id] = (productCounts[id] ?? 0) + (item.transactionQuantity as int);
                productNames[id] = item.menu.menuName;
              }
            }
          }

          // Sort products by quantity sold
          final sortedProducts = productCounts.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

          // Take top 5 products
          final topProducts = sortedProducts.take(5).toList();

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
                          Iconsax.chart_success,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Menu Terlaris",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  topProducts.isEmpty
                      ? const Center(child: Text("Data tidak tersedia"))
                      : Column(
                          children: topProducts
                              .map((entry) => Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        Text(
                                          productNames[entry.key] ?? "Unknown",
                                          style: const TextStyle(fontWeight: FontWeight.w500),
                                        ),
                                        const Spacer(),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary.withAlpha(26),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "${entry.value} terjual",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primary,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                              .toList(),
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
