import 'package:flutter/material.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  TextEditingController search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Text(
          "Stok",
          style: TextStyle(
            fontFamily: DjenggotAppTheme.fontName,
            fontWeight: FontWeight.w500,
            fontSize: 18,
            letterSpacing: 0.5,
            color: Colors.black, // Replace with your theme color
          ),
        ),
        const SizedBox(height: 16),

        
      ],
    );
  }
}
