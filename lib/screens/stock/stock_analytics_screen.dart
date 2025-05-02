import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_event.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_state.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_bloc.dart';
import 'package:the_djenggot/bloc/type/stock_type/stock_type_event.dart';
import 'package:the_djenggot/models/stock/stock_history.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/empty_state.dart';

class StockAnalyticsScreen extends StatefulWidget {
  const StockAnalyticsScreen({super.key});

  @override
  State<StockAnalyticsScreen> createState() => _StockAnalyticsScreenState();
}

class _StockAnalyticsScreenState extends State<StockAnalyticsScreen>
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

  String _selectedPeriod = 'week';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    context.read<StockTypeBloc>().add(LoadStockTypes());
    context.read<StockBloc>().add(LoadStock());
    context.read<StockHistoryBloc>().add(LoadStockHistory());
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
          "Stock Analytics",
          style: AppTheme.appBarTitle,
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Distribusi"),
            Tab(text: "Penggunaan"),
            Tab(text: "Pergerakan"),
          ],
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.grey,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStockDistributionTab(),
          _buildUsageAnalysisTab(),
          _buildStockMovementTab(),
        ],
      ),
    );
  }

  Widget _buildStockDistributionTab() {
    return BlocBuilder<StockBloc, StockState>(
      builder: (context, stockState) {
        if (stockState is StockLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (stockState is StockLoaded && stockState.stocks.isNotEmpty) {
          final Map<String, int> stocksByType = {};
          final Map<String, String> typeNames = {};

          for (var stock in stockState.stocks) {
            final typeId = stock.idStockType.idStockType;
            final typeName = stock.idStockType.stockTypeName;

            stocksByType[typeId] = (stocksByType[typeId] ?? 0) + 1;
            typeNames[typeId] = typeName;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Distribusi Jenis Stok",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Chart ini menunjukkan distribusi inventaris anda berdasarkan kategori jenis stok.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: stocksByType.isNotEmpty
                      ? Column(
                          children: [
                            Expanded(
                              flex: 3,
                              child: PieChart(
                                PieChartData(
                                  sections: _buildPieSections(stocksByType),
                                  centerSpaceRadius: 40,
                                  sectionsSpace: 2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 2,
                              child: _buildPieChartLegend(stocksByType, typeNames),
                            ),
                          ],
                        )
                      : const Center(
                          child: Text("No stock data available"),
                        ),
                ),
              ],
            ),
          );
        }

        return const Center(
          child: EmptyState(
            icon: Iconsax.chart,
            title: "No stock data available",
            subtitle: "Add some stock items to see analytics",
          ),
        );
      },
    );
  }

  List<PieChartSectionData> _buildPieSections(Map<String, int> stocksByType) {
    final List<PieChartSectionData> sections = [];
    final total = stocksByType.values.reduce((a, b) => a + b);

    int colorIndex = 0;
    stocksByType.forEach((type, count) {
      final percentage = (count / total * 100).toStringAsFixed(1);

      sections.add(
        PieChartSectionData(
          value: count.toDouble(),
          title: '$percentage%',
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
    });

    return sections;
  }

  Widget _buildPieChartLegend(Map<String, int> stocksByType, Map<String, String> typeNames) {
    final List<Widget> legendItems = [];
    int colorIndex = 0;

    stocksByType.forEach((typeId, count) {
      final typeName = typeNames[typeId] ?? "Unknown";

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
                  typeName,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                count.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );

      colorIndex++;
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Legend",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...legendItems,
      ],
    );
  }

  Widget _buildUsageAnalysisTab() {
    return BlocBuilder<StockHistoryBloc, StockHistoryState>(
      builder: (context, state) {
        if (state is StockHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StockHistoryLoaded && state.stockHistories.isNotEmpty) {
          final Map<String, Map<String, dynamic>> stockUsage = {};

          for (var history in state.stockHistories) {
            if (history.actionType.toLowerCase() == 'decrease') {
              final stockId = history.idStock;
              final stockName = history.stock?.stockName ?? "Unknown";
              final stockUnit = history.stock?.idStockType.stockUnit ?? "";
              final stockType = history.stock?.idStockType.stockTypeName ?? "Unknown";

              if (!stockUsage.containsKey(stockId)) {
                stockUsage[stockId] = {
                  'name': stockName,
                  'unit': stockUnit,
                  'type': stockType,
                  'usage': 0,
                };
              }

              stockUsage[stockId]!['usage'] += history.amount.abs();
            }
          }

          final sortedStocks = stockUsage.entries.toList()
            ..sort((a, b) => b.value['usage'].compareTo(a.value['usage']));

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Most Used Stock Items",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "This list shows which stock items are used most frequently based on stock reduction history.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                sortedStocks.isEmpty
                    ? const Expanded(
                        child: Center(
                          child: Text("No usage data available"),
                        ),
                      )
                    : Expanded(
                        child: ListView.builder(
                          itemCount: sortedStocks.length,
                          itemBuilder: (context, index) {
                            final stock = sortedStocks[index].value;
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
                                  stock['name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  "Category: ${stock['type']}",
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
                                    "${stock['usage']} ${stock['unit']}",
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
            title: "No usage data available",
            subtitle: "Usage data will be available once stock items are used in transactions",
          ),
        );
      },
    );
  }

  Widget _buildStockMovementTab() {
    return BlocBuilder<StockHistoryBloc, StockHistoryState>(
      builder: (context, state) {
        if (state is StockHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is StockHistoryLoaded && state.stockHistories.isNotEmpty) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pergerakan Stok dari Waktu ke Waktu",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Chart ini menunjukkan bagaimana level stok telah berubah dari waktu ke waktu.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildPeriodButton('week', 'Week'),
                        const SizedBox(width: 8),
                        _buildPeriodButton('month', 'Month'),
                        const SizedBox(width: 8),
                        _buildPeriodButton('year', 'Year'),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _buildStockMovementChart(state.stockHistories),
              ),
            ],
          );
        }

        return const Center(
          child: EmptyState(
            icon: Iconsax.chart_3,
            title: "Tidak ada data pergerakan stok yang tersedia",
            subtitle:
                "Data pergerakan stok akan tersedia setelah anda menambah, menghapus, atau menyesuaikan item stok",
          ),
        );
      },
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStockMovementChart(List<StockHistory> histories) {
    final DateTime now = DateTime.now();
    DateTime startDate;

    switch (_selectedPeriod) {
      case 'week':
        startDate = now.subtract(const Duration(days: 7));
        break;
      case 'month':
        startDate = DateTime(now.year, now.month - 1, now.day);
        break;
      case 'year':
        startDate = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        startDate = now.subtract(const Duration(days: 7));
    }

    Map<String, List<FlSpot>> stockDataPoints = {};
    Map<String, String> stockNames = {};

    final filteredHistories = histories.where((history) {
      final historyDate = DateTime.parse(history.timestamp);
      return historyDate.isAfter(startDate) && historyDate.isBefore(now);
    }).toList();

    filteredHistories
        .sort((a, b) => DateTime.parse(a.timestamp).compareTo(DateTime.parse(b.timestamp)));

    for (var history in filteredHistories) {
      final stockId = history.idStock;
      final stockName = history.stock?.stockName ?? "Unknown";

      stockNames[stockId] = stockName;
      stockDataPoints[stockId] ??= [];
    }

    Map<String, int> runningTotals = {};

    for (var history in filteredHistories) {
      final stockId = history.idStock;
      final timestamp = DateTime.parse(history.timestamp);

      runningTotals[stockId] ??= 0;

      if (history.actionType == 'add' || history.actionType == 'increase') {
        runningTotals[stockId] = (runningTotals[stockId] ?? 0) + history.amount;
      } else if (history.actionType == 'decrease') {
        runningTotals[stockId] = (runningTotals[stockId] ?? 0) - history.amount.abs();
      } else if (history.actionType == 'delete') {
        runningTotals[stockId] = 0;
      }

      final daysFromStart = timestamp.difference(startDate).inHours / 24;

      stockDataPoints[stockId]!.add(FlSpot(
        daysFromStart.toDouble(),
        runningTotals[stockId]!.toDouble(),
      ));
    }

    final sortedStocks = stockDataPoints.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));

    final topStocks = sortedStocks.take(5).toList();

    if (topStocks.isEmpty) {
      return const Center(
        child: Text("Insufficient data for selected period"),
      );
    }

    String getXAxisLabel(double value) {
      final date = startDate.add(Duration(days: value.toInt()));

      switch (_selectedPeriod) {
        case 'week':
          return DateFormat('E').format(date);
        case 'month':
          return DateFormat('d/M').format(date);
        case 'year':
          return DateFormat('MMM').format(date);
        default:
          return '';
      }
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                      tooltipBgColor: Colors.blueGrey.shade800,
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((LineBarSpot spot) {
                          for (var entry in topStocks) {
                            int pointIndex =
                                entry.value.indexWhere((e) => e.x == spot.x && e.y == spot.y);

                            if (pointIndex != -1) {
                              final stockName = stockNames[entry.key] ?? "Unknown";
                              final date = startDate.add(Duration(days: spot.x.toInt()));
                              final dateFormat = DateFormat('dd/MM/yy');

                              return LineTooltipItem(
                                '$stockName\n${spot.y.toInt()} units\n${dateFormat.format(date)}',
                                const TextStyle(color: Colors.white),
                              );
                            }
                          }

                          return LineTooltipItem(
                            '${spot.y.toInt()} units',
                            const TextStyle(color: Colors.white),
                          );
                        }).toList();
                      }),
                ),
                lineBarsData: List.generate(
                  topStocks.length,
                  (index) => LineChartBarData(
                    spots: topStocks[index].value,
                    color: _chartColors[index % _chartColors.length],
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      color: _chartColors[index % _chartColors.length].withAlpha(39),
                    ),
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        if (value % 1 == 0) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              getXAxisLabel(value),
                              style: const TextStyle(fontSize: 10),
                            ),
                          );
                        }
                        return const Text('');
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.shade300),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 60,
            child: _buildLineChartLegend(topStocks, stockNames),
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartLegend(
      List<MapEntry<String, List<FlSpot>>> stockDataPoints, Map<String, String> stockNames) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: stockDataPoints.length,
      itemBuilder: (context, index) {
        final stockId = stockDataPoints[index].key;
        final stockName = stockNames[stockId] ?? "Unknown";
        final color = _chartColors[index % _chartColors.length];

        return Container(
          margin: const EdgeInsets.only(right: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(stockName),
            ],
          ),
        );
      },
    );
  }
}
