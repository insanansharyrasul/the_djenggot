import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stat_card.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stats/total_sold_stat.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stats/monthly_income_stat.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stats/total_stock_stat.dart';
import 'package:the_djenggot/screens/home_screen/widgets/stats/low_stock_stat.dart';

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                  title: "Total Menu Terjual",
                  content: TotalSoldStat(),
                  icon: Iconsax.shopping_bag,
                  color: AppTheme.primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                  title: "Pemasukan Bulanan",
                  content: MonthlyIncomeStat(),
                  icon: Iconsax.money,
                  color: AppTheme.primary),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatCard(
                  title: "Kuantitas Stok",
                  content: TotalStockStat(),
                  icon: Iconsax.chart_1,
                  color: AppTheme.primary),
            ),
            SizedBox(width: 12),
            Expanded(
              child: StatCard(
                  title: "Stok Hampir Habis",
                  content: LowStockStat(),
                  icon: Iconsax.warning_2,
                  color: AppTheme.primary),
            ),
          ],
        ),
      ],
    );
  }
}
