import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/screens/home_screen/widgets/loading_error_widget.dart';
import 'package:the_djenggot/utils/currency_formatter_util.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class SalesByCategory extends StatelessWidget {
  const SalesByCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded && state is! TransactionLoading) {
          // Get current month transactions
          final now = DateTime.now();
          final currentMonth = DateTime(now.year, now.month);

          // Create a map to store category totals
          final Map<String, double> categoryTotals = {};

          // Calculate totals by category
          for (var transaction in state.transactions) {
            final transactionDate = DateTime.parse(transaction.timestamp);
            if (transactionDate.year == currentMonth.year &&
                transactionDate.month == currentMonth.month) {
              for (var item in transaction.items ?? []) {
                final categoryName = item.menu.idMenuType?.menuTypeName ?? "Uncategorized";
                final amount = item.transactionQuantity * item.menu.menuPrice;
                categoryTotals[categoryName] = (categoryTotals[categoryName] ?? 0.0) + amount;
              }
            }
          }

          // Sort categories by sales amount
          final sortedCategories = categoryTotals.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value));

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
                          Iconsax.category,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Penjualan per Kategori",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  sortedCategories.isEmpty
                      ? const Center(child: Text("Data tidak tersedia"))
                      : Column(
                          children: sortedCategories.take(5).map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        entry.key,
                                        style: const TextStyle(fontWeight: FontWeight.w500),
                                      ),
                                      const Spacer(),
                                      Text(
                                        CurrencyFormatterUtil.formatCurrency(entry.value.toInt()),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  LinearProgressIndicator(
                                    value: entry.value / (sortedCategories.first.value),
                                    backgroundColor: Colors.grey[200],
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
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
