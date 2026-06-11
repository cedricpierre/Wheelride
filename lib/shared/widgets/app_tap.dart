import 'package:flutter/material.dart';

/// Zone tactile sans ripple — boutons overlay carte et chat.
class AppTap extends StatelessWidget {
  const AppTap({
    required this.onTap,
    required this.child,
    super.key,
    this.padding,
  });

  final VoidCallback? onTap;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: padding != null ? Padding(padding: padding!, child: child) : child,
    );
  }
}
