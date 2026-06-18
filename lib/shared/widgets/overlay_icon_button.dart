import 'package:flutter/material.dart';

class OverlayIconButton extends StatelessWidget {
  const OverlayIconButton({
    required this.icon,
    required this.onPressed,
    super.key,
    this.size = 44,
    this.iconSize = 22,
    this.padding = EdgeInsets.zero,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: padding,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}
