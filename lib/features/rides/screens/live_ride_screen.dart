import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/wheelride_models.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';

class LiveRideScreen extends ConsumerStatefulWidget {
  const LiveRideScreen({super.key});

  @override
  ConsumerState<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends ConsumerState<LiveRideScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelRideControllerProvider);
    final ride = state.activeRide;

    if (ride == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.route_outlined, size: 56),
              const SizedBox(height: 16),
              const Text('Aucun ride actif.'),
              const SizedBox(height: 16),
              PrimaryActionButton(
                label: 'Creer un ride',
                onPressed: () => context.go('/rides/create'),
              ),
            ],
          ),
        ),
      );
    }

    final center = state.locations.isEmpty
        ? const LatLng(44.1741, 5.2782)
        : state.locations.first.point;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 13),
            children: [
              TileLayer(
                urlTemplate: AppConfig.tileUrlTemplate,
                userAgentPackageName: 'com.wheelride.wheelride',
              ),
              MarkerLayer(
                markers: [
                  for (final location in state.locations)
                    Marker(
                      point: location.point,
                      width: 86,
                      height: 72,
                      child: _RiderMarker(
                        location: location,
                        participant: _participantFor(
                          state.participants,
                          location.userId,
                        ),
                        isCurrentUser: location.userId == state.user?.id,
                      ),
                    ),
                ],
              ),
            ],
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppTheme.ink,
                    child: IconButton(
                      onPressed: () => context.go('/home'),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.ink.withValues(alpha: .86),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              ride.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const Text(
                              'En direct',
                              style: TextStyle(
                                color: AppTheme.neon,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  CircleAvatar(
                    backgroundColor: AppTheme.ink,
                    child: IconButton(
                      onPressed: () => context.go('/rides/participants'),
                      icon: const Icon(Icons.groups_2_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: .34,
            minChildSize: .18,
            maxChildSize: .62,
            builder: (context, scrollController) {
              return DecoratedBox(
                decoration: const BoxDecoration(
                  color: AppTheme.panel,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(
                          value: 0,
                          label: Text('Chat'),
                          icon: Icon(Icons.chat_bubble_outline),
                        ),
                        ButtonSegment(
                          value: 1,
                          label: Text('Participants'),
                          icon: Icon(Icons.groups_2_outlined),
                        ),
                      ],
                      selected: {_tab},
                      onSelectionChanged: (value) {
                        setState(() => _tab = value.first);
                      },
                    ),
                    Expanded(
                      child: _tab == 0
                          ? _ChatPanel(scrollController: scrollController)
                          : _ParticipantPanel(
                              scrollController: scrollController,
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  RideParticipant? _participantFor(
    List<RideParticipant> participants,
    String userId,
  ) {
    for (final participant in participants) {
      if (participant.userId == userId) return participant;
    }
    return null;
  }
}

class _RiderMarker extends StatelessWidget {
  const _RiderMarker({
    required this.location,
    required this.isCurrentUser,
    this.participant,
  });

  final RideLocation location;
  final RideParticipant? participant;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final color = isCurrentUser ? Colors.lightBlueAccent : AppTheme.neon;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.ink,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 3),
          ),
          padding: const EdgeInsets.all(7),
          child: Icon(
            isCurrentUser
                ? Icons.navigation_rounded
                : Icons.sports_motorsports_rounded,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppTheme.ink.withValues(alpha: .82),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            participant?.name ?? 'Rider',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _ChatPanel extends ConsumerStatefulWidget {
  const _ChatPanel({required this.scrollController});

  final ScrollController scrollController;

  @override
  ConsumerState<_ChatPanel> createState() => _ChatPanelState();
}

class _ChatPanelState extends ConsumerState<_ChatPanel> {
  final _message = TextEditingController();

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelRideControllerProvider);

    return Column(
      children: [
        Expanded(
          child: state.messages.isEmpty
              ? ListView(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(20),
                  children: const [
                    Text(
                      'Aucun historique. Les nouveaux messages apparaissent ici en direct.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.muted),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: widget.scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: state.messages.length,
                  itemBuilder: (context, index) {
                    final message = state.messages[index];
                    final isMe = message.userId == state.user?.id;
                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        constraints: const BoxConstraints(maxWidth: 280),
                        decoration: BoxDecoration(
                          color: isMe ? AppTheme.neon : const Color(0xFF202633),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe ? 'Vous' : message.userName,
                              style: TextStyle(
                                color: isMe ? Colors.black87 : AppTheme.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              message.message,
                              style: TextStyle(
                                color: isMe ? Colors.black : Colors.white,
                              ),
                            ),
                            Text(
                              DateFormat.Hm().format(message.createdAt),
                              style: TextStyle(
                                color: isMe ? Colors.black54 : AppTheme.muted,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('chat-message'),
                  controller: _message,
                  decoration: const InputDecoration(
                    hintText: 'Ecrire un message...',
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton.small(
                onPressed: () async {
                  await ref
                      .read(wheelRideControllerProvider.notifier)
                      .sendMessage(_message.text);
                  _message.clear();
                },
                child: const Icon(Icons.send_rounded),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ParticipantPanel extends ConsumerWidget {
  const _ParticipantPanel({required this.scrollController});

  final ScrollController scrollController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(wheelRideControllerProvider);

    return ListView.separated(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final participant = state.participants[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(participant.name.substring(0, 1).toUpperCase()),
          ),
          title: Text(participant.name),
          subtitle: const Text('En ligne'),
          trailing: participant.isOwner
              ? const Icon(
                  Icons.workspace_premium_rounded,
                  color: AppTheme.neon,
                )
              : null,
        );
      },
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemCount: state.participants.length,
    );
  }
}
