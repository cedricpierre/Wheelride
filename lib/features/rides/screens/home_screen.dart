import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) context.go('/rides/live');
          if (index == 2) context.go('/rides/participants');
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_2_outlined),
            label: 'Rides',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
      ),
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
                  icon: const Icon(Icons.logout_rounded),
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
            const Text('Mes rides', style: TextStyle(color: AppTheme.muted)),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.groups_2_outlined, size: 42),
                    const SizedBox(height: 18),
                    Text(
                      state.activeRide?.name ?? 'Aucun ride actif',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      state.activeRide == null
                          ? 'Cree un ride ou rejoins-en un'
                          : '${state.participants.length} participants connectes',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.muted),
                    ),
                    const SizedBox(height: 22),
                    PrimaryActionButton(
                      label: 'Creer un ride',
                      icon: Icons.add_road_rounded,
                      onPressed: () => context.go('/rides/create'),
                    ),
                    const SizedBox(height: 12),
                    SecondaryActionButton(
                      label: 'Rejoindre un ride',
                      icon: Icons.qr_code_scanner_rounded,
                      onPressed: () => context.go('/rides/join'),
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
