import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/screens/home_screen/home_screen.dart';
import 'package:the_djenggot/screens/setting_screen.dart';
import 'package:the_djenggot/screens/menu/menu_list_screen.dart';
import 'package:the_djenggot/screens/stock/stock_list_screen.dart';
import 'package:the_djenggot/screens/transaction/transaction_list_screen.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/bottom_navigation_bar_item.dart';

class PageManagerScreen extends StatefulWidget {
  const PageManagerScreen({super.key});

  @override
  State<PageManagerScreen> createState() => _PageManagerScreenState();
}

class _PageManagerScreenState extends State<PageManagerScreen> {
  final PageController pageController = PageController();
  int pageIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(pageController: pageController),
      const StockScreen(),
      const MenuScreen(),
      const TransactionListScreen(),
      const SettingScreen()
    ];

    return Scaffold(
      body: PageView(
        controller: pageController,
        onPageChanged: (index) {
          setState(() {
            pageIndex = index;
          });
        },
        children: pages,
      ),
      bottomNavigationBar: buildMyNavBar(context),
    );
  }

  Container buildMyNavBar(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.1),
            blurRadius: 25,
            offset: Offset(0, 2),
          ),
        ],
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
            context,
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
            context,
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
            context,
          ),
          bottomNavItem(
            () {
              pageController.jumpToPage(3);
              setState(() => pageIndex = 3);
            },
            Iconsax.receipt,
            3,
            pageIndex,
            "Transaksi",
            context,
          ),
          bottomNavItem(
            () {
              pageController.jumpToPage(4);
              setState(() => pageIndex = 4);
            },
            Iconsax.setting,
            4,
            pageIndex,
            "Setting",
            context,
          ),
        ],
      ),
    );
  }
}
