import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_icons.dart';

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.fallbackLocation = '/home'});

  final String fallbackLocation;

  void _onPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(fallbackLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _onPressed(context),
      icon: const Icon(AppIcons.back),
    );
  }
}
