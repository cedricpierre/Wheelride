import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return _NeutralButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: backgroundColor ?? AppTheme.neon,
      foregroundColor: foregroundColor ?? Colors.black87,
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  const SecondaryActionButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return _NeutralButton(
      label: label,
      icon: icon,
      onPressed: onPressed,
      backgroundColor: const Color(0xFF1C2129),
      foregroundColor: Colors.white,
      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
    );
  }
}

class _NeutralButton extends StatelessWidget {
  const _NeutralButton({
    required this.label,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.icon,
    this.borderSide = BorderSide.none,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color backgroundColor;
  final Color foregroundColor;
  final BorderSide borderSide;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: onPressed == null
            ? backgroundColor.withValues(alpha: 0.45)
            : backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radius),
          side: borderSide,
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          child: DefaultTextStyle(
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            child: IconTheme(
              data: IconThemeData(color: foregroundColor, size: 20),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
