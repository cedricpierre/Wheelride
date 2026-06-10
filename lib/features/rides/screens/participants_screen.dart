import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/screen_frame.dart';

class ParticipantsScreen extends ConsumerWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wheelRideControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Participants'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('${state.participants.length} / 20')),
          ),
        ],
      ),
      body: ScreenFrame(
        child: ListView.separated(
          itemCount: state.participants.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final participant = state.participants[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF202633),
                child: Text(participant.name.substring(0, 1).toUpperCase()),
              ),
              title: Text(participant.name),
              subtitle: Text(
                participant.isOnline ? 'En ligne' : 'Hors ligne',
                style: TextStyle(
                  color: participant.isOnline ? AppTheme.neon : AppTheme.muted,
                ),
              ),
              trailing: participant.isOwner
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.workspace_premium_rounded,
                          color: AppTheme.neon,
                          size: 18,
                        ),
                        SizedBox(width: 4),
                        Text('Leader'),
                      ],
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
