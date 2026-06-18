import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_config.dart';
import '../../../core/theme/app_icons.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/models/wheelride_models.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/app_sheets.dart';
import '../../../shared/widgets/overlay_icon_button.dart';
import '../../../shared/widgets/sheet_handle.dart';
import '../../../shared/widgets/surface_panel.dart';
import '../widgets/live_ride_chat_panel.dart';
import '../widgets/rider_marker.dart';

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

    final myLocation = state.locations
        .where((location) => location.userId == userId)
        .firstOrNull;
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
              const Icon(AppIcons.route, size: 56),
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
                      child: RiderMarker(
                        participant: state.participants.byUserId(location.userId),
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
                    child: SurfacePanel(
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
                  SurfacePanel(
                    borderRadius: 22,
                    child: OverlayIconButton(
                      icon: AppIcons.moreMenu,
                      onPressed: () => _showRideMenu(context, ref),
                      padding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!_chatVisible) ...[
            Positioned(
              left: _edgeInset,
              bottom: _edgeInset + bottomInset,
              child: _ChatToggleButton(onPressed: _openChat),
            ),
            Positioned(
              right: _edgeInset,
              bottom: _edgeInset + bottomInset,
              child: SurfacePanel(
                borderRadius: AppTheme.radius,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    OverlayIconButton(
                      icon: AppIcons.zoomIn,
                      onPressed: _zoomIn,
                      size: _controlSize,
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    OverlayIconButton(
                      icon: AppIcons.zoomOut,
                      onPressed: _zoomOut,
                      size: _controlSize,
                    ),
                    Divider(
                      height: 0.5,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                    OverlayIconButton(
                      icon: AppIcons.myLocation,
                      onPressed: _recenterOnMe,
                      size: _controlSize,
                    ),
                  ],
                ),
              ),
            ),
          ],
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
                    top: Radius.circular(AppTheme.radiusLg),
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
                        const SheetHandle(),
                        Expanded(
                          child: LiveRideChatPanel(
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

class _ChatToggleButton extends StatelessWidget {
  const _ChatToggleButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: SurfacePanel(
        borderRadius: 28,
        tint: AppTheme.neon,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(AppIcons.chat, size: 22, color: Colors.black87),
            SizedBox(width: 8),
            Text(
              'Chat',
              style: TextStyle(
                fontSize: 16,
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
