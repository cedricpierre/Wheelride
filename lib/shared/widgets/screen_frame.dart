import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/wheelride_controller.dart';

class ScreenFrame extends ConsumerWidget {
  const ScreenFrame({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wheelRideControllerProvider);

    return SafeArea(
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            if (state.isDemo)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Mode demo: ajoute SUPABASE_URL et SUPABASE_PUBLISHABLE_KEY pour connecter le backend.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              ),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
