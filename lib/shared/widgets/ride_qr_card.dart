import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_theme.dart';

class RideQrCard extends StatelessWidget {
  const RideQrCard({
    required this.payload,
    required this.joinCode,
    super.key,
    this.qrSize = 190,
  });

  final String payload;
  final String joinCode;
  final double qrSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.neon.withValues(alpha: 0.2),
                blurRadius: 24,
              ),
            ],
          ),
          child: SizedBox.square(
            dimension: qrSize,
            child: QrImageView(data: payload),
          ),
        ),
        const SizedBox(height: 14),
        SelectableText(
          joinCode,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }
}
