import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/models/transaction/transaction_item.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';
import 'package:the_djenggot/widgets/transaction/daily_sales_card.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  final PageController pageController;

  const HomeScreen({super.key, required this.pageController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    context.read<MenuBloc>().add(LoadMenu());
    context.read<StockBloc>().add(LoadStock());
    context.read<MenuTypeBloc>().add(LoadMenuTypes());
    context.read<StockTypeBloc>().add(LoadStockTypes());
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Dashboard",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: BlocListener<TransactionBloc, TransactionState>(
        listener: (context, state) {},
        child: RefreshIndicator(
          onRefresh: () async {
            refresh();
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              BlocBuilder<TransactionBloc, TransactionState>(
                builder: (context, state) {
                  if (state is TransactionLoaded) {
                    return DailySalesCard(
                      transactions: state.transactions,
                      onDateChanged: (date) {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      selectedDate: selectedDate,
                    );
                  } else if (state is TransactionLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    return const Center(child: Text("Error loading transactions"));
                  }
                },
              ),
              const SizedBox(height: 32),
              _buildStatsGrid(),
              const SizedBox(height: 32),
              _buildRecentTransactions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard("Total Menu Terjual", _buildTotalSoldTodayStat(),
                  Iconsax.shopping_bag, AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  "Pemasukan Bulanan", _buildMonthlyIncomeStat(), Iconsax.money, AppTheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                  "Kuantitas Stok", _buildTotalStockStat(), Iconsax.chart_1, AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                  "Stok Hampir Habis", _buildLowStockStat(), Iconsax.warning_2, AppTheme.primary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, Widget content, IconData icon, Color color) {
    final now = DateTime.now();
    final formatter = DateFormat('dd MMM yyyy');

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
                    color: color.withAlpha(26),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
            const SizedBox(height: 8),
            Text(
              "Update: ${formatter.format(now)}",
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSoldTodayStat() {
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

          return _buildStatValue(
            totalSold.toString(),
            percentageText,
            isPositive: isPositive,
            showPercentage: percentageText.isNotEmpty,
          );
        }
        return _buildLoadingOrError();
      },
    );
  }

  Widget _buildMonthlyIncomeStat() {
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

          String formattedTotal;
          if (totalIncome >= 1000000000) {
            formattedTotal = "${(totalIncome / 1000000000).toStringAsFixed(1)}B";
          } else if (totalIncome >= 1000000) {
            formattedTotal = "${(totalIncome / 1000000).toStringAsFixed(1)}M";
          } else if (totalIncome >= 1000) {
            formattedTotal = "${(totalIncome / 1000).toStringAsFixed(1)}K";
          } else {
            formattedTotal = totalIncome.toString();
          }

          String percentageText = "";
          bool isPositive = true;
          double percentageChange = 0;

          if (previousMonthIncome > 0) {
            percentageChange = ((totalIncome - previousMonthIncome) / previousMonthIncome) * 100;
            isPositive = percentageChange >= 0;
            percentageText = "${percentageChange.abs().toStringAsFixed(1)}%";
          }

          return _buildStatValue(
            formattedTotal,
            percentageText,
            isPositive: isPositive,
            showPercentage: percentageText.isNotEmpty,
          );
        }
        return _buildLoadingOrError();
      },
    );
  }

  Widget _buildTotalStockStat() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoaded) {
          final int uniqueStocksCount = state.stocks.length;

          return _buildStatValue(
            uniqueStocksCount.toString(),
            "",
            showPercentage: false,
          );
        }
        return _buildLoadingOrError();
      },
    );
  }

  Widget _buildLowStockStat() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, state) {
        if (state is StockLoaded) {
          int lowStockCount = 0;
          for (var stock in state.stocks) {
            if (stock.stockThreshold != null && stock.stockQuantity <= stock.stockThreshold!) {
              lowStockCount++;
            }
          }

          return _buildStatValue(
            lowStockCount.toString(),
            "",
            showPercentage: false,
          );
        }
        return _buildLoadingOrError();
      },
    );
  }

  Widget _buildStatValue(String value, String percentage,
      {bool isPositive = true, bool showPercentage = true}) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (showPercentage && percentage.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  isPositive ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                  size: 12,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 2),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingOrError() {
    return const SizedBox(
      height: 30,
      child: Center(
        child: SizedBox(
          height: 15,
          width: 15,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final formatter = NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    );

    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoaded) {
          final recentTransactions = state.transactions.take(3).toList();

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
                          Iconsax.receipt,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        "Transaksi Terakhir",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          widget.pageController.jumpToPage(3);
                        },
                        child: const Text(
                          "Lihat Semua",
                          style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  recentTransactions.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text("Belum ada transaksi"),
                          ),
                        )
                      : Column(
                          children: recentTransactions.map((transaction) {
                            final date = DateTime.parse(transaction.timestamp);
                            final formattedDate = DateFormat('dd MMMM yyyy - HH:mm').format(date);

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () {
                                  context
                                      .push(
                                          '/transaction-detail/${transaction.idTransactionHistory}')
                                      .then(
                                    (value) {
                                      refresh();
                                    },
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Icon(
                                        getIconFromString(
                                            transaction.transactionType.transactionTypeIcon),
                                        color: AppTheme.primary,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              transaction.transactionType.transactionTypeName,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              formattedDate,
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        formatter.format(transaction.transactionAmount),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ],
              ),
            ),
          );
        }
        return _buildLoadingOrError();
      },
    );
  }
}
