import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/models/transaction/transaction_history.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:fl_chart/fl_chart.dart';

class DailySalesCard extends StatefulWidget {
  final List<TransactionHistory> transactions;
  final Function(DateTime) onDateChanged;
  final DateTime selectedDate;

  const DailySalesCard({
    super.key,
    required this.transactions,
    required this.onDateChanged,
    required this.selectedDate,
  });

  @override
  State<DailySalesCard> createState() => _DailySalesCardState();
}

class _DailySalesCardState extends State<DailySalesCard> {
  final formatter = NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  // Get transactions for the selected date
  List<TransactionHistory> get _filteredTransactions {
    return widget.transactions.where((t) {
      final date = DateTime.parse(t.timestamp);
      return date.year == widget.selectedDate.year &&
          date.month == widget.selectedDate.month &&
          date.day == widget.selectedDate.day;
    }).toList();
  }

  // Calculate total amount for the selected date
  int get _totalAmount {
    return _filteredTransactions.fold(
        0, (sum, transaction) => sum + transaction.transactionAmount);
  }

  // Calculate percentage change from previous day
  double get _percentageChange {
    // Get previous day
    final previousDate = widget.selectedDate.subtract(const Duration(days: 1));

    // Get transactions for previous day
    final previousTransactions = widget.transactions.where((t) {
      final date = DateTime.parse(t.timestamp);
      return date.year == previousDate.year &&
          date.month == previousDate.month &&
          date.day == previousDate.day;
    }).toList();

    final previousTotal = previousTransactions.fold(
        0, (sum, transaction) => sum + transaction.transactionAmount);

    if (previousTotal == 0) return 0;
    return ((_totalAmount - previousTotal) / previousTotal) * 100;
  }

  // Generate data for the chart
  List<FlSpot> _generateChartData() {
    // Group transactions by hour
    Map<int, int> hourlyTotals = {};

    for (var transaction in _filteredTransactions) {
      final date = DateTime.parse(transaction.timestamp);
      final hour = date.hour;
      hourlyTotals[hour] =
          (hourlyTotals[hour] ?? 0) + transaction.transactionAmount;
    }

    // Create chart data
    List<FlSpot> spots = [];
    for (int i = 0; i < 24; i++) {
      spots.add(FlSpot(i.toDouble(), (hourlyTotals[i] ?? 0).toDouble()));
    }

    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final spots = _generateChartData();
    final String formattedDate =
        DateFormat('d MMM yyyy').format(widget.selectedDate);
    final bool isToday = widget.selectedDate.day == DateTime.now().day &&
        widget.selectedDate.month == DateTime.now().month &&
        widget.selectedDate.year == DateTime.now().year;

    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF42A5F5), // Blue gradient start
              Color(0xFF1E88E5), // Blue gradient end
            ],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? "Penjualan Hari Ini" : "Penjualan",
                      style: AppTheme.subtitle.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatter.format(_totalAmount),
                      style: AppTheme.headline.copyWith(
                        color: AppTheme.white,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios,
                          color: AppTheme.white, size: 18),
                      onPressed: () {
                        widget.onDateChanged(widget.selectedDate
                            .subtract(const Duration(days: 1)));
                      },
                    ),
                    Text(
                      formattedDate,
                      style: AppTheme.body2.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_ios,
                          color: AppTheme.white, size: 18),
                      onPressed: () {
                        final tomorrow =
                            widget.selectedDate.add(const Duration(days: 1));
                        if (!tomorrow.isAfter(DateTime.now())) {
                          widget.onDateChanged(tomorrow);
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                if (_percentageChange != 0)
                  Icon(
                    _percentageChange > 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: AppTheme.white,
                    size: 16,
                  ),
                const SizedBox(width: 4),
                Text(
                  _percentageChange != 0
                      ? "${_percentageChange.toStringAsFixed(1)}% dari hari sebelumnya"
                      : "Tidak ada data sebelumnya",
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (spots.isNotEmpty)
              SizedBox(
                height: 80,
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: AppTheme.white.withOpacity(0.8),
                        isStrokeCapRound: true,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(
                          show: true,
                          color: AppTheme.white.withOpacity(0.2),
                        ),
                      ),
                    ],
                    lineTouchData: const LineTouchData(enabled: false),
                    backgroundColor: Colors.transparent,
                  ),
                ),
              )
            else
              SizedBox(
                height: 80,
                child: Center(
                  child: Text(
                    "Tidak ada transaksi untuk ditampilkan",
                    style: AppTheme.body2.copyWith(color: AppTheme.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
