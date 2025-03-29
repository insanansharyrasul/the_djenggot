import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Stock"),
            ElevatedButton(onPressed: () => context.pop(), child: Text("Back"))
          ],
        ),
      ),
    );
  }
}
