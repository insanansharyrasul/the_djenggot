import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/screens/home_screen.dart';
import 'package:the_djenggot/screens/stock_screen.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/bottom_navigation_bar_item.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int pageIndex = 0;

  final pages = [
    const HomeScreen(),
    const StockScreen(),
    const HomeScreen(),
    const HomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: Stack(children: [pages[pageIndex]]),
        ),
      ),
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: DjenggotAppTheme.background,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          bottomNavItem(
            () => setState(() => pageIndex = 0),
            Iconsax.home,
            0,
            pageIndex,
            "Beranda",
          ),
          bottomNavItem(
            () => setState(() => pageIndex = 1),
            Iconsax.box,
            1,
            pageIndex,
            "Stok",
          ),
          bottomNavItem(
            () => setState(() => pageIndex = 2),
            Iconsax.receipt,
            2,
            pageIndex,
            "Laporan",
          ),
          bottomNavItem(
            () => setState(() => pageIndex = 3),
            Iconsax.setting,
            3,
            pageIndex,
            "Settings",
          ),
        ],
      ),
    );
  }
}
