import 'package:flutter/cupertino.dart';
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
import '../../../shared/widgets/adaptive_sheets.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/glass_panel.dart';

class LiveRideScreen extends ConsumerStatefulWidget {
  const LiveRideScreen({super.key});

  @override
  ConsumerState<LiveRideScreen> createState() => _LiveRideScreenState();
}

class _LiveRideScreenState extends ConsumerState<LiveRideScreen> {
  final _mapController = MapController();
  bool _chatVisible = false;

  static const _controlSize = 56.0;
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
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                children: [
                  Flexible(
                    child: GlassPanel(
                      borderRadius: 22,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text(
                        ride.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GlassPanel(
                    borderRadius: 22,
                    child: CupertinoButton(
                      padding: const EdgeInsets.all(10),
                      minimumSize: Size.zero,
                      onPressed: () => _showRideMenu(context, ref),
                      child: const Icon(
                        CupertinoIcons.ellipsis,
                        size: 22,
                        color: Colors.white,
                      ),
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
          if (!_chatVisible)
            Positioned(
              right: _edgeInset,
              bottom: _edgeInset + bottomInset,
              child: GlassPanel(
                borderRadius: 14,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MapControlButton(
                      size: _controlSize,
                      icon: CupertinoIcons.plus,
                      onPressed: _zoomIn,
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    _MapControlButton(
                      size: _controlSize,
                      icon: CupertinoIcons.minus,
                      onPressed: _zoomOut,
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    _MapControlButton(
                      size: _controlSize,
                      icon: CupertinoIcons.location_fill,
                      onPressed: _recenterOnMe,
                    ),
                  ],
                ),
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
                return ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: AppTheme.sheet.withValues(alpha: 0.96),
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          width: 36,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: _ChatPanel(
                            scrollController: scrollController,
                          ),
                        ),
                      ],
                    ),
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

  Future<void> _showRideMenu(BuildContext context, WidgetRef ref) async {
    await showAppActionSheet(
      context,
      actions: [
        AppSheetAction(
          label: 'Liste des participants',
          onPressed: () => context.push('/rides/participants'),
        ),
        AppSheetAction(
          label: 'Voir QR code',
          onPressed: () => context.push('/rides/qr'),
        ),
        AppSheetAction(
          label: 'Quitter le ride',
          destructive: true,
          onPressed: () async {
            final confirmed = await showAppConfirmDialog(
              context,
              title: 'Quitter le ride ?',
              message: 'Tu ne verras plus la carte ni le chat de ce ride.',
              confirmLabel: 'Quitter',
              destructive: true,
            );
            if (!confirmed || !context.mounted) return;
            await ref.read(wheelRideControllerProvider.notifier).leaveRide();
            if (context.mounted) context.go('/home');
          },
        ),
      ],
    );
  }
}

class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.size,
    required this.icon,
    required this.onPressed,
  });

  final double size;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ChatToggleButton extends StatelessWidget {
  const _ChatToggleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      minimumSize: Size.zero,
      onPressed: onPressed,
      child: GlassPanel(
        borderRadius: 28,
        tint: AppTheme.neon,
        opacity: 0.92,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CupertinoIcons.chat_bubble_text_fill,
              size: 22,
              color: Colors.black87,
            ),
            SizedBox(width: 8),
            Text(
              'Chat',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
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
                ? CupertinoIcons.location_north_fill
                : CupertinoIcons.circle_fill,
            color: color,
            size: isCurrentUser ? 18 : 10,
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
                          color: isMe ? AppTheme.neon : const Color(0xFF2A3140),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isMe ? 18 : 4),
                            bottomRight: Radius.circular(isMe ? 4 : 18),
                          ),
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
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: GlassPanel(
                  borderRadius: 22,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CupertinoTextField(
                    key: const Key('chat-message'),
                    controller: _message,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    placeholder: 'Message',
                    placeholderStyle: TextStyle(
                      color: AppTheme.muted.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: null,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () async {
                  await ref
                      .read(wheelRideControllerProvider.notifier)
                      .sendMessage(_message.text);
                  _message.clear();
                },
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppTheme.neon,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    CupertinoIcons.arrow_up,
                    color: Colors.black87,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
