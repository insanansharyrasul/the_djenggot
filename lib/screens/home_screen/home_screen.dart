import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/transaction/daily_sales_card.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

import 'widgets/stats_grid.dart';
import 'widgets/daily_sales_chart.dart';
import 'widgets/top_selling_products.dart';
import 'widgets/sales_by_category.dart';
import 'widgets/recent_transactions.dart';

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
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary, Color(0xFF2E86C1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Dashboard",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Selamat datang!",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        Text(
                          "Hari ini: ${DateFormat('dd MMMM yyyy').format(DateTime.now())}",
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              title:
                  innerBoxIsScrolled ? const Text("Dashboard", style: AppTheme.appBarTitle) : null,
              actions: [
                IconButton(
                  icon: const Icon(Iconsax.refresh),
                  onPressed: refresh,
                ),
                IconButton(
                  icon: const Icon(Iconsax.setting_2),
                  onPressed: () {
                    widget.pageController.jumpToPage(4);
                  },
                ),
              ],
            ),
          ];
        },
        body: BlocListener<TransactionBloc, TransactionState>(
          listener: (context, state) {},
          child: RefreshIndicator(
            onRefresh: () async {
              refresh();
            },
            child: ListView(
              padding: const EdgeInsets.all(8),
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
                const StatsGrid(),
                const SizedBox(height: 32),
                const DailySalesChart(),
                const SizedBox(height: 32),
                const TopSellingProducts(),
                const SizedBox(height: 32),
                const SalesByCategory(),
                const SizedBox(height: 32),
                RecentTransactions(
                  pageController: widget.pageController,
                  onRefresh: refresh,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
