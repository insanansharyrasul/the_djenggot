import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/models/stock.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class StockStatusOverview extends StatelessWidget {
  final List<Stock> stocks;
  final double totalValue;

  const StockStatusOverview({
    super.key,
    required this.stocks,
    required this.totalValue,
  });

  @override
  Widget build(BuildContext context) {
    final totalProducts = stocks.length;

    // Count products by stock status
    final inStock = stocks.where((s) => s.stockQuantity > (s.stockThreshold ?? 1)).length;
    final lowStock = stocks
        .where((s) => s.stockQuantity <= (s.stockThreshold ?? 1) && s.stockQuantity > 0)
        .length;
    final outOfStock = stocks.where((s) => s.stockQuantity <= 0).length;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Stock icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Iconsax.box,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Stok',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalProducts Product',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Stock level indicator bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                // In stock (green)
                Expanded(
                  flex: inStock,
                  child: Container(
                    height: 12,
                    color: Colors.green,
                  ),
                ),
                // Low stock (yellow)
                Expanded(
                  flex: lowStock,
                  child: Container(
                    height: 12,
                    color: Colors.amber,
                  ),
                ),
                // Out of stock (red)
                Expanded(
                  flex: outOfStock,
                  child: Container(
                    height: 12,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStockLegendItem('In stock:', inStock.toString(), Colors.green),
              _buildStockLegendItem('Low stock:', lowStock.toString(), Colors.amber),
              _buildStockLegendItem('Out of stock:', outOfStock.toString(), Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStockLegendItem(String label, String count, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
