import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';
import '../../../shared/widgets/screen_frame.dart';
import '../../../shared/widgets/wheelride_logo.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wheelRideControllerProvider);

    return Scaffold(
      body: ScreenFrame(
        child: ListView(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const WheelRideLogo(compact: true),
                IconButton(
                  tooltip: 'Deconnexion',
                  onPressed: () async {
                    await ref
                        .read(wheelRideControllerProvider.notifier)
                        .signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(AppIcons.logout),
                ),
              ],
            ),
            const SizedBox(height: 26),
            Text(
              'Salut ${state.user?.name ?? 'rider'}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pret a rouler ?',
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(AppIcons.riders, size: 42),
                    const SizedBox(height: 18),
                    const Text(
                      'Cree ou rejoins un ride',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Lance une balade ou entre un code pour rejoindre tes potes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted),
                    ),
                    const SizedBox(height: 22),
                    PrimaryActionButton(
                      label: 'Creer un ride',
                      icon: AppIcons.createRide,
                      onPressed: () => context.push('/rides/create'),
                    ),
                    const SizedBox(height: 12),
                    SecondaryActionButton(
                      label: 'Rejoindre un ride',
                      icon: AppIcons.joinRide,
                      onPressed: () => context.push('/rides/join'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
