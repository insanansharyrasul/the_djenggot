import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:the_djenggot/screens/stock_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const StockScreen(),
            ));
          },
          child: const Text("Go to Stock"))
    ],);
  }
}