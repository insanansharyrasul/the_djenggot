import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_bloc.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_event.dart';
import 'package:the_djenggot/bloc/stock/stock_history/stock_history_state.dart';
import 'package:the_djenggot/models/stock/stock_history.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/empty_state.dart';

class StockHistoryScreen extends StatefulWidget {
  const StockHistoryScreen({super.key});

  @override
  State<StockHistoryScreen> createState() => _StockHistoryScreenState();
}

class _StockHistoryScreenState extends State<StockHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<StockHistoryBloc>().add(LoadStockHistory());
  }

  String _getActionTypeLabel(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'add':
        return 'Added';
      case 'increase':
        return 'Increased';
      case 'decrease':
        return 'Decreased';
      case 'delete':
        return 'Deleted';
      default:
        return actionType;
    }
  }

  IconData _getActionTypeIcon(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'add':
        return Iconsax.add_circle;
      case 'increase':
        return Iconsax.arrow_circle_up;
      case 'decrease':
        return Iconsax.arrow_circle_down;
      case 'delete':
        return Iconsax.trash;
      default:
        return Iconsax.refresh;
    }
  }

  Color _getActionTypeColor(String actionType) {
    switch (actionType.toLowerCase()) {
      case 'add':
        return Colors.green;
      case 'increase':
        return Colors.blue;
      case 'decrease':
        return Colors.orange;
      case 'delete':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Stock Taking History",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: BlocBuilder<StockHistoryBloc, StockHistoryState>(
        builder: (context, state) {
          if (state is StockHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is StockHistoryLoaded) {
            if (state.stockHistories.isEmpty) {
              return _buildEmptyState();
            }
            return _buildHistoryList(state.stockHistories);
          } else if (state is StockHistoryError) {
            return Center(child: Text("Error: ${state.message}"));
          } else {
            return _buildEmptyState();
          }
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: EmptyState(
        icon: Iconsax.document_1,
        title: "No stock taking history found",
        subtitle:
            "Stock taking history will be recorded when stocks are added, updated, or deleted",
      ),
    );
  }

  Widget _buildHistoryList(List<StockHistory> histories) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: histories.length,
      itemBuilder: (context, index) {
        final history = histories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getActionTypeColor(history.actionType).withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getActionTypeIcon(history.actionType),
                color: _getActionTypeColor(history.actionType),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    history.stock?.stockName ?? "Unknown Stock",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                _buildActionBadge(history.actionType),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                _buildInfoRow(
                  Iconsax.category,
                  "Stock Type: ${history.stock?.idStockType.stockTypeName ?? 'Unknown'}",
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Iconsax.chart_1,
                  "Amount: ${history.amount > 0 ? '+' : ''}${history.amount} ${history.stock?.idStockType.stockUnit ?? ''}",
                  actionType: history.actionType,
                ),
                const SizedBox(height: 4),
                _buildInfoRow(
                  Iconsax.calendar,
                  "Date: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(history.timestamp))}",
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionBadge(String actionType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getActionTypeColor(actionType).withAlpha(51),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        _getActionTypeLabel(actionType),
        style: TextStyle(
          color: _getActionTypeColor(actionType),
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {String? actionType}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: actionType != null
                ? _getActionTypeColor(actionType).withAlpha(51)
                : AppTheme.primary.withAlpha(51),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 12,
            color: actionType != null ? _getActionTypeColor(actionType) : AppTheme.primary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
