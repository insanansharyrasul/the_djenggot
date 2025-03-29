import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:the_djenggot/utils/theme/app_theme.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {},
            child: Icon(Iconsax.menu),),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "Warung Djenggot",
              style: TextStyle(
                fontFamily: DjenggotAppTheme.fontName,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                letterSpacing: 0.5,
                color: Colors.black, // Replace with your theme color
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Icon(Iconsax.notification4),),
        ],
      ),
    );
  }
}
