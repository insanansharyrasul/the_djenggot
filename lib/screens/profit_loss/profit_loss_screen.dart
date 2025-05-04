import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/profit_loss/profit_loss_bloc.dart';
import '../../bloc/profit_loss/profit_loss_event.dart';
import '../../bloc/profit_loss/profit_loss_state.dart';
import '../../models/profit_loss/profit_loss.dart';
import '../../utils/currency_formatter_util.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTimeRange _dateRange = DateTimeRange(
    start: DateTime.now().subtract(const Duration(days: 30)),
    end: DateTime.now(),
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  void _loadData() {
    context.read<ProfitLossBloc>().add(LoadProfitLossData(
          startDate: _dateRange.start,
          endDate: _dateRange.end,
        ));
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _dateRange,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF5B4D36),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dateRange) {
      setState(() {
        _dateRange = picked;
      });
      context.read<ProfitLossBloc>().add(ChangeProfitLossDateRange(
            startDate: _dateRange.start,
            endDate: _dateRange.end,
          ));
    }
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
        title: const Text('Profit and Loss'),
        actions: [
          IconButton(
            onPressed: () => _selectDateRange(context),
            icon: const Icon(Icons.date_range),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Profit Chart'),
            Tab(text: 'Expenses'),
          ],
        ),
      ),
      body: BlocBuilder<ProfitLossBloc, ProfitLossState>(
        builder: (context, state) {
          if (state is ProfitLossLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfitLossLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(state),
                _buildProfitChartTab(state),
                _buildExpensesTab(state),
              ],
            );
          } else if (state is ProfitLossError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Select a date range to view data'));
          }
        },
      ),
    );
  }

  Widget _buildOverviewTab(ProfitLossLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary (${DateFormat('dd MMM yyyy').format(_dateRange.start)} - ${DateFormat('dd MMM yyyy').format(_dateRange.end)})',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  _buildSummaryItem('Total Income', state.summary.income),
                  _buildSummaryItem('Total Expenses', state.summary.expenses),
                  const Divider(),
                  _buildSummaryItem('Net Profit', state.summary.netProfit, isTotal: true),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Profit Overview',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildDailyProfitBarChart(state.profitLossData),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitChartTab(ProfitLossLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Profit Trends',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildProfitLineChart(state.profitLossData),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Income vs. Expenses',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildIncomeExpenseComparisonChart(state.profitLossData),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesTab(ProfitLossLoaded state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Expense Breakdown',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: _buildExpensePieChart(state.expenseCategories),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildExpenseCategoriesList(state.expenseCategories),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, int amount, {bool isTotal = false}) {
    final style = isTotal
        ? Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(
            CurrencyFormatterUtil.format(amount),
            style: style?.copyWith(
              color: amount >= 0 ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyProfitBarChart(List<ProfitLoss> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: data.map((e) => e.income + e.expenses).reduce((a, b) => a > b ? a : b) * 1.2,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey[800]!,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final profit = data[groupIndex].netProfit;
              return BarTooltipItem(
                '${DateFormat('dd/MM').format(data[groupIndex].date)}\n${CurrencyFormatterUtil.format(profit)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(data[index].date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 56,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) {
                  return const Text('');
                } else if (value == meta.min) {
                  return const Text('');
                }
                return Text(
                  CurrencyFormatterUtil.format(value.toInt()),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final profit = item.netProfit;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: profit.abs().toDouble(),
                color: profit >= 0 ? Colors.green : Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProfitLineChart(List<ProfitLoss> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = data.map((e) => e.netProfit).reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = data.map((e) => e.netProfit).reduce((a, b) => a < b ? a : b) * 1.2;

    return LineChart(
      LineChartData(
        gridData: const FlGridData(
          drawVerticalLine: false,
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length && index % 5 == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(data[index].date),
                      style: const TextStyle(fontSize: 8),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 56,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) {
                  return const Text('');
                } else if (value == meta.min) {
                  return const Text('');
                }
                return Text(
                  CurrencyFormatterUtil.format(value.toInt()),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        minX: 0,
        maxX: data.length - 1.0,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.netProfit.toDouble());
            }).toList(),
            isCurved: true,
            color: const Color(0xFF5B4D36),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              // show: false,
              color: const Color(0xFF5B4D36).withAlpha(51),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.grey[800]!,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = data[spot.x.toInt()].date;
                final profit = data[spot.x.toInt()].netProfit;
                return LineTooltipItem(
                  '${DateFormat('dd/MM').format(date)}\n${CurrencyFormatterUtil.format(profit)}',
                  const TextStyle(color: Colors.white),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIncomeExpenseComparisonChart(List<ProfitLoss> data) {
    if (data.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final maxY = data
            .map((e) => e.income > e.expenses ? e.income : e.expenses)
            .reduce((a, b) => a > b ? a : b) *
        1.2;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: 0,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.grey[800]!,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final item = data[groupIndex];
              final String label;
              final int value;

              if (rodIndex == 0) {
                label = 'Income';
                value = item.income;
              } else {
                label = 'Expense';
                value = item.expenses;
              }

              return BarTooltipItem(
                '$label: ${CurrencyFormatterUtil.format(value)}',
                const TextStyle(color: Colors.white),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index >= 0 && index < data.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('dd/MM').format(data[index].date),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }
                return const SizedBox();
              },
              reservedSize: 56,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 56,
              getTitlesWidget: (value, meta) {
                if (value == meta.max) {
                  return const Text('');
                } else if (value == meta.min) {
                  return const Text('');
                }
                return Text(
                  CurrencyFormatterUtil.format(value.toInt()),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: data.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: item.income.toDouble(),
                color: Colors.green,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              BarChartRodData(
                toY: item.expenses.toDouble(),
                color: Colors.red,
                width: 16,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpensePieChart(List<ExpenseCategory> categories) {
    if (categories.isEmpty) {
      return const Center(child: Text('No expense data available'));
    }

    // Take top 5 categories and group the rest as "Others"
    final topCategories = categories.take(5).toList();
    int othersAmount = 0;
    if (categories.length > 5) {
      for (int i = 5; i < categories.length; i++) {
        othersAmount += categories[i].amount;
      }
    }

    final List<ExpenseCategory> chartData = [...topCategories];
    if (othersAmount > 0) {
      chartData.add(ExpenseCategory(name: 'Others', amount: othersAmount));
    }

    final total = chartData.fold(0, (sum, item) => sum + item.amount);

    final List<Color> colors = [
      const Color(0xFF5B4D36), // Brown
      const Color(0xFF8D7B61), // Light brown
      const Color(0xFFC2B8A3), // Beige
      const Color(0xFF3A3224), // Dark brown
      const Color(0xFFDFD3C3), // Light beige
      Colors.grey, // Others
    ];

    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: chartData.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final percent = item.amount / total * 100;

          return PieChartSectionData(
            color: colors[index % colors.length],
            value: item.amount.toDouble(),
            title: '${percent.toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseCategoriesList(List<ExpenseCategory> categories) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Categories',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...categories.map((category) => _buildExpenseItem(category)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseItem(ExpenseCategory category) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(category.name),
          Text(CurrencyFormatterUtil.format(category.amount)),
        ],
      ),
    );
  }
}
