import 'package:flutter/material.dart';

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Container(
          width: 36,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.24),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
