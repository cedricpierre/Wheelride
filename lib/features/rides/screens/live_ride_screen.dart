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
import '../../../shared/widgets/app_back_button.dart';

class LiveRideScreen extends ConsumerStatefulWidget {
  const LiveRideScreen({super.key});

  @override
  ConsumerState<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends ConsumerState<LiveRideScreen> {
  final _mapController = MapController();
  bool _chatVisible = false;

  static const _controlSize = 56.0;
  static const _controlSpacing = 10.0;
  static const _edgeInset = 14.0;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _openChat() => setState(() => _chatVisible = true);

  void _closeChat() => setState(() => _chatVisible = false);

  void _zoomIn() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom + 1).clamp(3.0, 18.0));
  }

  void _zoomOut() {
    final camera = _mapController.camera;
    _mapController.move(camera.center, (camera.zoom - 1).clamp(3.0, 18.0));
  }

  void _recenterOnMe() {
    final state = ref.read(wheelRideControllerProvider);
    final userId = state.user?.id;
    if (userId == null) return;

    RideLocation? myLocation;
    for (final location in state.locations) {
      if (location.userId == userId) {
        myLocation = location;
        break;
      }
    }
    if (myLocation == null) return;

    final zoom = _mapController.camera.zoom;
    _mapController.move(myLocation.point, zoom < 14 ? 14 : zoom);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelRideControllerProvider);
    final ride = state.activeRide;

    if (ride == null) {
      return Scaffold(
        appBar: AppBar(leading: const AppBackButton()),
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
                onPressed: () => context.push('/rides/create'),
              ),
            ],
          ),
        ),
      );
    }

    final center = state.locations.isEmpty
        ? const LatLng(44.1741, 5.2782)
        : state.locations.first.point;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 13,
              onTap: (_, __) {
                if (_chatVisible) _closeChat();
              },
            ),
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.ink,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      ride.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Spacer(),
                  CircleAvatar(
                    backgroundColor: AppTheme.ink,
                    child: PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert_rounded),
                      color: AppTheme.panel,
                      onSelected: (value) async {
                        switch (value) {
                          case 'participants':
                            context.push('/rides/participants');
                          case 'leave':
                            final confirmed = await _confirmLeave(context);
                            if (!confirmed || !context.mounted) return;
                            await ref
                                .read(wheelRideControllerProvider.notifier)
                                .leaveRide();
                            if (context.mounted) context.go('/home');
                          case 'qr':
                            context.push('/rides/qr');
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'participants',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.groups_2_outlined),
                            title: Text('Liste des participants'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'leave',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.logout_rounded),
                            title: Text('Quitter'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'qr',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.qr_code_2_rounded),
                            title: Text('Voir QR code'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_chatVisible)
            Positioned(
              left: _edgeInset,
              bottom: _edgeInset + bottomInset,
              child: _ChatToggleButton(onPressed: _openChat),
            ),
          Positioned(
            right: _edgeInset,
            bottom: _edgeInset + bottomInset,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapControlButton(
                  size: _controlSize,
                  icon: Icons.add_rounded,
                  tooltip: 'Zoomer',
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: _controlSpacing),
                _MapControlButton(
                  size: _controlSize,
                  icon: Icons.remove_rounded,
                  tooltip: 'Dezoomer',
                  onPressed: _zoomOut,
                ),
                const SizedBox(height: _controlSpacing),
                _MapControlButton(
                  size: _controlSize,
                  icon: Icons.my_location_rounded,
                  tooltip: 'Me recentrer',
                  onPressed: _recenterOnMe,
                ),
              ],
            ),
          ),
          if (_chatVisible)
            DraggableScrollableSheet(
              initialChildSize: 0.34,
              minChildSize: 0.18,
              maxChildSize: 0.85,
              snap: true,
              snapSizes: const [0.34, 0.55, 0.85],
              builder: (context, scrollController) {
                return DecoratedBox(
                  decoration: const BoxDecoration(
                    color: AppTheme.panel,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 16,
                        offset: Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 56,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white38,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _ChatPanel(scrollController: scrollController),
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

  Future<bool> _confirmLeave(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Quitter le ride ?'),
            content: const Text(
              'Tu ne verras plus la carte ni le chat de ce ride.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Quitter'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.size,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final double size;
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.ink,
      elevation: 6,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: size,
            height: size,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

class _ChatToggleButton extends StatelessWidget {
  const _ChatToggleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.neon,
      elevation: 6,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 56,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.chat_bubble_rounded, size: 28, color: Colors.black87),
                const SizedBox(width: 8),
                Text(
                  'Chat',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: 'Ecrire un message...',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 52,
                height: 52,
                child: FloatingActionButton(
                  onPressed: () async {
                    await ref
                        .read(wheelRideControllerProvider.notifier)
                        .sendMessage(_message.text);
                    _message.clear();
                  },
                  child: const Icon(Icons.send_rounded, size: 26),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
