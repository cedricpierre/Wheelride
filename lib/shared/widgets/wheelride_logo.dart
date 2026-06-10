import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class WheelRideLogo extends StatelessWidget {
  const WheelRideLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 30.0 : 84.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                left: -size * .18,
                child: Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                  color: AppTheme.neon,
                  size: size * .75,
                ),
              ),
              Icon(
                Icons.sports_motorsports_rounded,
                color: AppTheme.ink,
                size: size * .52,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.7,
            ),
            children: const [
              TextSpan(text: 'WHEEL'),
              TextSpan(
                text: 'RIDE',
                style: TextStyle(color: AppTheme.neon),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
