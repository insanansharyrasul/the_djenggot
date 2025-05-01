import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/bloc/stock/stock_bloc.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/dialogs/app_dialog.dart';
import 'package:the_djenggot/widgets/icon_picker.dart';

class StockDetailScreen extends StatefulWidget {
  final Stock stock;

  const StockDetailScreen({super.key, required this.stock});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    context.read<StockBloc>().add(LoadStock());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          "Detail Stok",
          style: AppTheme.appBarTitle,
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Iconsax.edit,
              color: AppTheme.nearlyBlue,
            ),
            onPressed: () {
              context.push('/add-edit-stock', extra: widget.stock);
            },
          ),
          IconButton(
            icon: const Icon(
              Iconsax.trash,
              color: Colors.red,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AppDialog(
                    type: "confirm",
                    title: "Anda akan menghapus stok ini!",
                    message: "Apakah anda yakin?",
                    okTitle: "Hapus",
                    cancelTitle: "Batal",
                    onOkPress: () {
                      Navigator.pop(context);
                      BlocProvider.of<StockBloc>(context).add(
                        DeleteStock(widget.stock.idStock),
                      );
                      context.pop(); // Return to stock list
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
        },
        child: BlocBuilder<StockBloc, StockState>(
          builder: (context, state) {
            if (state is StockLoaded) {
              // Get the latest stock data
              final stock = state.stocks.firstWhere(
                (stock) => stock.idStock == widget.stock.idStock,
                orElse: () => widget.stock,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stock header
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(23),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withAlpha(23),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                getIconFromString(stock.idStockType.stockTypeIcon),
                                color: AppTheme.primary,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              stock.stockName,
                              style: const TextStyle(
                                fontFamily: AppTheme.fontName,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withAlpha(26),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                stock.idStockType.stockTypeName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Stock details
                      const Text(
                        "Informasi Detail",
                        style: TextStyle(
                          fontFamily: AppTheme.fontName,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withAlpha(23),
                              spreadRadius: 1,
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildInfoRow("Kuantitas",
                                "${stock.stockQuantity}${stock.idStockType.stockUnit.isNotEmpty ? ' ${stock.idStockType.stockUnit}' : ''}",
                                icon: Iconsax.chart_1,
                                isLowStock: stock.stockThreshold != null &&
                                    stock.stockQuantity <= stock.stockThreshold!),
                            if (stock.stockThreshold != null)
                              _buildInfoRow(
                                "Batas Minimum",
                                "${stock.stockThreshold}${stock.idStockType.stockUnit.isNotEmpty ? ' ${widget.stock.idStockType.stockUnit}' : ''}",
                                icon: Iconsax.warning_2,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value,
      {IconData icon = Iconsax.info_circle, bool isLowStock = false, bool multiLine = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isLowStock ? Colors.red.withAlpha(23) : Colors.grey.withAlpha(23),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isLowStock ? Colors.red : Colors.grey.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isLowStock ? FontWeight.bold : FontWeight.w500,
                    color: isLowStock ? Colors.red : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
