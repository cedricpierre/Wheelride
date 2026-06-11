import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Panneau sombre avec bordure fine — style WheelRide neutre.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    required this.child,
    super.key,
    this.borderRadius = AppTheme.radius,
    this.padding,
    this.tint = AppTheme.panel,
    this.opacity = 0.94,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final Color tint;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final content =
        padding != null ? Padding(padding: padding!, child: child) : child;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: tint.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: content,
    );
  }
}
