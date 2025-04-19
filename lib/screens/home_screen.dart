import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';
import 'package:the_djenggot/widgets/sales_today.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Icon(Iconsax.menu),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  "Warung Djenggot",
                  style: TextStyle(
                    fontFamily: AppTheme.fontName,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    letterSpacing: 0.5,
                    color: Colors.black, 
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Icon(Iconsax.notification4),
              ),
            ],
          ),
        ),
        const Row(
          children: [
            Expanded(child: SalesToday()),
          ],
        )
      ],
    );
  }
}
