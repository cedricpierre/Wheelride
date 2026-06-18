import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/ride_qr_card.dart';
import '../../../shared/widgets/screen_frame.dart';

class InviteScreen extends ConsumerWidget {
  const InviteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ride = ref.watch(wheelRideControllerProvider).activeRide;

    if (ride == null) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
        body: const Center(child: Text('Aucun ride actif.')),
      );
    }

    final invitePayload = 'wheelride://join/${ride.joinCode}';

    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: ScreenFrame(
        child: ListView(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppTheme.neon, size: 72),
            const SizedBox(height: 18),
            Text(
              'Ride cree !',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'Partage ce QR Code pour inviter tes amis a rejoindre le ride.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 22),
            Center(
              child: RideQrCard(
                payload: invitePayload,
                joinCode: ride.joinCode,
              ),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: 'Partager le QR Code',
              icon: AppIcons.share,
              onPressed: () {
                SharePlus.instance.share(
                  ShareParams(
                    text: 'Rejoins ${ride.name} sur WheelRide: $invitePayload',
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            SecondaryActionButton(
              label: 'Commencer le ride',
              icon: AppIcons.startRide,
              onPressed: () async {
                await ref
                    .read(wheelRideControllerProvider.notifier)
                    .startRide();
                if (context.mounted) context.go('/rides/live');
              },
            ),
          ],
        ),
      ),
    );
  }
}
