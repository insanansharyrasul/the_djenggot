import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class SalesToday extends StatelessWidget {
  const SalesToday({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.all(Radius.circular(16.0)),
        border: Border.all(
          color: AppTheme.grey.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pemasukan',
                    style: TextStyle(
                      fontFamily: AppTheme.fontName,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      letterSpacing: 0.5,
                      color: AppTheme.lightText,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Icon(Iconsax.more),
                ),
              ],
            ),
            const Text(
              "100.000.000",
              style: TextStyle(
                fontFamily: AppTheme.fontName,
                fontWeight: FontWeight.w300,
                fontSize: 54,
                letterSpacing: 0.5,
                color: AppTheme.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
