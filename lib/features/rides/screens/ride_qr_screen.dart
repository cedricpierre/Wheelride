import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/ride_qr_card.dart';

class RideQrScreen extends ConsumerWidget {
  const RideQrScreen({super.key});

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
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/rides/live'),
        title: const Text('QR code du ride'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ride.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scanne ce code pour rejoindre le ride.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.muted),
              ),
              const SizedBox(height: 28),
              RideQrCard(
                payload: invitePayload,
                joinCode: ride.joinCode,
                qrSize: 220,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
