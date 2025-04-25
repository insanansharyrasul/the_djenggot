import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/sales_today.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.background,
        centerTitle: true,
        title: const Text(
          "Dashboard",
          style: AppTheme.appBarTitle,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(32),
        children: const [
          Row(
            children: [
              Expanded(child: SalesToday()),
            ],
          )
        ],
      ),
    );
  }
}
