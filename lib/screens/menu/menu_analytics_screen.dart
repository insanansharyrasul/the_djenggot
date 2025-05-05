import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/menu/menu_bloc.dart';
import 'package:the_djenggot/bloc/menu/menu_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_bloc.dart';
import 'package:the_djenggot/bloc/transaction/transaction_event.dart';
import 'package:the_djenggot/bloc/transaction/transaction_state.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_bloc.dart';
import 'package:the_djenggot/bloc/type/menu_type/menu_type_event.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/empty_state.dart';

class MenuAnalyticsScreen extends StatefulWidget {
  const MenuAnalyticsScreen({super.key});

  @override
  State<MenuAnalyticsScreen> createState() => _MenuAnalyticsScreenState();
}

class _MenuAnalyticsScreenState extends State<MenuAnalyticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Color> _chartColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.amber,
    Colors.indigo,
    Colors.pink,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    context.read<MenuTypeBloc>().add(LoadMenuTypes());
    context.read<MenuBloc>().add(LoadMenu());
    context.read<TransactionBloc>().add(LoadTransactions());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Analisis Menu",
          style: AppTheme.appBarTitle,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Sering Dipesan"),
            Tab(text: "Detail Penjualan"),
            Tab(text: "Kategori Penjualan"),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.grey,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMostOrderedTab(),
          _buildSalesDetailTab(),
          _buildCategorySalesTab(),
        ],
      ),
    );
  }

  Widget _buildMostOrderedTab() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded && state.transactions.isNotEmpty) {
          // Track menu orders frequency
          final Map<String, Map<String, dynamic>> menuOrderCount = {};

          // Process all transactions to count menu orders
          for (var transaction in state.transactions) {
            for (var item in transaction.items!) {
              final menuId = item.menu.idMenu;
              final menuName = item.menu.menuName;
              final menuType = item.menu.idMenuType.menuTypeName;
              final menuPrice = item.menu.menuPrice;

              if (!menuOrderCount.containsKey(menuId)) {
                menuOrderCount[menuId] = {
                  'name': menuName,
                  'type': menuType,
                  'price': menuPrice,
                  'orderCount': 0,
                  'totalQuantity': 0,
                  'totalRevenue': 0.0,
                };
              }

              menuOrderCount[menuId]!['orderCount'] += 1;
              menuOrderCount[menuId]!['totalQuantity'] += item.transactionQuantity;
              menuOrderCount[menuId]!['totalRevenue'] += (menuPrice * item.transactionQuantity);
            }
          }

          // Sort menus by order count
          final sortedMenus = menuOrderCount.entries.toList()
            ..sort((a, b) => b.value['totalQuantity'].compareTo(a.value['totalQuantity']));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Menu Paling Laris",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Daftar ini menunjukkan menu yang paling sering dipesan berdasarkan riwayat transaksi.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                sortedMenus.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text("Belum ada data pesanan"),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: sortedMenus.length,
                          itemBuilder: (context, index) {
                            final menu = sortedMenus[index].value;
                            final rankColor = index < 3 ? _chartColors[index] : Colors.grey;

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: rankColor.withAlpha(51),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "#${index + 1}",
                                      style: TextStyle(
                                        color: rankColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  menu['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Kategori: ${menu['type']}",
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withAlpha(25),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "${menu['totalQuantity']} terjual",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        }

        return const Center(
          child: EmptyState(
            icon: Iconsax.chart_1,
            title: "Belum ada data pesanan",
            subtitle: "Data akan tersedia setelah beberapa transaksi dilakukan",
          ),
        );
      },
    );
  }

  Widget _buildSalesDetailTab() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded && state.transactions.isNotEmpty) {
          // Track menu sales details
          final Map<String, Map<String, dynamic>> menuSalesDetail = {};

          // Process all transactions for sales details
          for (var transaction in state.transactions) {
            for (var item in transaction.items!) {
              final menuId = item.menu.idMenu;
              final menuName = item.menu.menuName;
              final menuType = item.menu.idMenuType.menuTypeName;
              final menuPrice = item.menu.menuPrice;
              final quantity = item.transactionQuantity;
              final revenue = menuPrice * quantity;

              if (!menuSalesDetail.containsKey(menuId)) {
                menuSalesDetail[menuId] = {
                  'name': menuName,
                  'type': menuType,
                  'price': menuPrice,
                  'totalQuantity': 0,
                  'totalRevenue': 0.0,
                };
              }

              menuSalesDetail[menuId]!['totalQuantity'] += quantity;
              menuSalesDetail[menuId]!['totalRevenue'] += revenue;
            }
          }

          // Sort menus by revenue
          final sortedBySales = menuSalesDetail.entries.toList()
            ..sort((a, b) => b.value['totalRevenue'].compareTo(a.value['totalRevenue']));

          final formatter = NumberFormat.currency(
            locale: 'id_ID',
            symbol: 'Rp ',
            decimalDigits: 0,
          );

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Rincian Penjualan Menu",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Daftar ini menunjukkan rincian penjualan untuk setiap menu.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                sortedBySales.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text("Belum ada data penjualan"),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: sortedBySales.length,
                          itemBuilder: (context, index) {
                            final menuData = sortedBySales[index].value;
                            final revenue = menuData['totalRevenue'];
                            final quantity = menuData['totalQuantity'];
                            final price = menuData['price'];

                            return Card(
                              elevation: 2,
                              margin: const EdgeInsets.symmetric(vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            menuData['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withAlpha(25),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            formatter.format(revenue),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailChip(
                                      Iconsax.tag,
                                      "Kategori: ${menuData['type']}",
                                      Colors.blue,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailChip(
                                      Iconsax.money,
                                      "Harga: ${formatter.format(price)}",
                                      Colors.purple,
                                    ),
                                    const SizedBox(height: 8),
                                    _buildDetailChip(
                                      Iconsax.percentage_circle,
                                      "Pendapatan: ${formatter.format(revenue)}",
                                      Colors.green,
                                    ),
                                    _buildDetailChip(
                                      Iconsax.shopping_cart,
                                      "Terjual: $quantity",
                                      Colors.orange,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          );
        }

        return const Center(
          child: EmptyState(
            icon: Iconsax.chart,
            title: "Belum ada data penjualan",
            subtitle: "Data akan tersedia setelah beberapa transaksi dilakukan",
          ),
        );
      },
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySalesTab() {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state is TransactionLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TransactionLoaded && state.transactions.isNotEmpty) {
          // Group sales by menu category
          final Map<String, Map<String, dynamic>> salesByCategory = {};
          double totalRevenue = 0;

          // Calculate total revenue by category
          for (var transaction in state.transactions) {
            for (var item in transaction.items!) {
              final categoryId = item.menu.idMenuType.idMenuType;
              final categoryName = item.menu.idMenuType.menuTypeName;
              final revenue = item.menu.menuPrice * item.transactionQuantity;
              totalRevenue += revenue;

              if (!salesByCategory.containsKey(categoryId)) {
                salesByCategory[categoryId] = {
                  'name': categoryName,
                  'totalRevenue': 0.0,
                  'totalQuantity': 0,
                };
              }

              salesByCategory[categoryId]!['totalRevenue'] += revenue;
              salesByCategory[categoryId]!['totalQuantity'] += item.transactionQuantity;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Penjualan per Kategori",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Chart ini menunjukkan persentase penjualan berdasarkan kategori menu.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: salesByCategory.isNotEmpty
                      ? Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildPieSections(salesByCategory, totalRevenue),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildPieChartLegend(salesByCategory, totalRevenue),
                            ),
                          ],
                        )
                      : const Center(
                          child: Text("Belum ada data penjualan per kategori"),
                        ),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: EmptyState(
            icon: Iconsax.chart,
            title: "Belum ada data penjualan",
            subtitle: "Data akan tersedia setelah beberapa transaksi dilakukan",
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieSections(
      Map<String, Map<String, dynamic>> salesByCategory, double totalRevenue) {
    final List<PieChartSectionData> sections = [];

    int colorIndex = 0;
    for (var entry in salesByCategory.entries) {
      final categoryData = entry.value;
      final categoryRevenue = categoryData['totalRevenue'];
      final percentage = (categoryRevenue / totalRevenue * 100);

      sections.add(
        PieChartSectionData(
          value: categoryRevenue,
          title: '${percentage.toStringAsFixed(1)}%',
          color: _chartColors[colorIndex % _chartColors.length],
          radius: 100,
          titleStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );

      colorIndex++;
    }

    return sections;
  }

  Widget _buildPieChartLegend(
      Map<String, Map<String, dynamic>> salesByCategory, double totalRevenue) {
    final List<Widget> legendItems = [];
    int colorIndex = 0;
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final sortedCategories = salesByCategory.entries.toList()
      ..sort((a, b) => b.value['totalRevenue'].compareTo(a.value['totalRevenue']));

    for (var entry in sortedCategories) {
      final categoryData = entry.value;
      final categoryName = categoryData['name'];
      final categoryRevenue = categoryData['totalRevenue'];
      final percentage = (categoryRevenue / totalRevenue * 100);

      legendItems.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _chartColors[colorIndex % _chartColors.length],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  categoryName,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                "${percentage.toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                formatter.format(categoryRevenue),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );

      colorIndex++;
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Kategori",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                formatter.format(totalRevenue),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...legendItems,
        ],
      ),
    );
  }
}
