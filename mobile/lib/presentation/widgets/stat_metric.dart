import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';

class StatMetric extends StatelessWidget {
  final String value;
  final String unit;
  final String label;

  const StatMetric({
    super.key,
    required this.value,
    required this.unit,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value, style: AppTextStyles.statValue),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(unit, style: AppTextStyles.statLabel),
            ),
          ],
        ),
        Text(label, style: AppTextStyles.statLabel),
      ],
    );
  }
}
