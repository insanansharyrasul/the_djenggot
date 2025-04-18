import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/screens/setting_screen.dart';
import 'package:the_djenggot/screens/home_screen.dart';
import 'package:the_djenggot/screens/menu/menu_screen.dart';
import 'package:the_djenggot/screens/stock/stock_screen.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/bottom_navigation_bar_item.dart';
import 'package:the_djenggot/widgets/empty_state.dart';
import 'package:the_djenggot/widgets/floating_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final PageController pageController = PageController();
  int pageIndex = 0;

  final pages = <Widget>[
    const HomeScreen(),
    const StockScreen(),
    const MenuScreen(),
    const EmptyState(title: "Fitur Belum ada", subtitle: "Mohon tunggu ya :D"),
    const SettingScreen()
  ];

  late final List<Widget> floatingButtonList;

  @override
  void initState() {
    super.initState();
    floatingButtonList = [
      floatingButton(icon: Icons.point_of_sale, onPressed: () {}),
      floatingButton(
        icon: Iconsax.add,
        onPressed: () {
          context.push('/add-edit-stock');
        },
      ),
      floatingButton(
        icon: Iconsax.add,
        onPressed: () {
          context.push('/add-edit-menu');
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: PageView(
          controller: pageController,
          onPageChanged: (index) {
            setState(() {
              pageIndex = index;
            });
          },
          children: pages,
        ),
      ),
      bottomNavigationBar: buildMyNavBar(context),
      floatingActionButton: (pageIndex >= 0 && pageIndex < floatingButtonList.length)
          ? floatingButtonList[pageIndex]
          : null,
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.background,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          bottomNavItem(
            () {
              pageController.jumpToPage(0);
              setState(() => pageIndex = 0);
            },
            Iconsax.home,
            0,
            pageIndex,
            "Beranda",
          ),
          bottomNavItem(
            () {
              pageController.jumpToPage(1);
              setState(() => pageIndex = 1);
            },
            Iconsax.box,
            1,
            pageIndex,
            "Stok",
          ),
          bottomNavItem(
            () {
              pageController.jumpToPage(2);
              setState(() => pageIndex = 2);
            },
            Iconsax.menu_board,
            2,
            pageIndex,
            "Menu",
          ),
          bottomNavItem(
            () {
              pageController.jumpToPage(3);
              setState(() => pageIndex = 3);
            },
            Iconsax.receipt,
            3,
            pageIndex,
            "Laporan",
          ),
          bottomNavItem(
            () {
              pageController.jumpToPage(4);
              setState(() => pageIndex = 4);
            },
            Iconsax.setting,
            4,
            pageIndex,
            "Settings",
          ),
          // bottomNavItem(
          //   () {
          //     pageController.jumpToPage(3);
          //     setState(() => pageIndex = 3);
          //   },
          //   Iconsax.bluetooth_circle,
          //   3,
          //   pageIndex,
          //   "Test",
          // )
        ],
      ),
    );
  }
}
