import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class StatValue extends StatelessWidget {
  final String value;
  final String percentage;
  final bool isPositive;
  final bool showPercentage;

  const StatValue({
    super.key,
    required this.value,
    required this.percentage,
    this.isPositive = true,
    this.showPercentage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        if (showPercentage && percentage.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isPositive ? Colors.green.withAlpha(26) : Colors.red.withAlpha(26),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Icon(
                  isPositive ? Iconsax.arrow_up_2 : Iconsax.arrow_down_1,
                  size: 12,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 2),
                Text(
                  percentage,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
