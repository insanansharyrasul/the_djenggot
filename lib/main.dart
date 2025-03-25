import 'package:flutter/material.dart';
import 'package:the_djenggot/routing/app_routing.dart';
import 'package:the_djenggot/utils/theme/app_colors.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      title: 'Warung Makan Pak Djenggot',
      theme: ThemeData(
        primaryColor: AppColors.primaryColor,
      ),
    );
  }
}
