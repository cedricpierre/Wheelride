import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';
import '../../../shared/widgets/screen_frame.dart';

class JoinRideScreen extends ConsumerStatefulWidget {
  const JoinRideScreen({super.key});

  @override
  ConsumerState<JoinRideScreen> createState() => _JoinRideScreenState();
}

class _JoinRideScreenState extends ConsumerState<JoinRideScreen> {
  final _code = TextEditingController(text: 'DEMO42');
  bool _joining = false;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelRideControllerProvider);

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: ScreenFrame(
        child: ListView(
          children: [
            Text(
              'Rejoindre un ride',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Scanne le QR Code du ride ou entre son code.',
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 20),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: SizedBox(
                height: 260,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MobileScanner(
                      onDetect: (capture) {
                        final value = capture.barcodes.firstOrNull?.rawValue;
                        if (value != null) _join(context, value);
                      },
                    ),
                    IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppTheme.neon, width: 3),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        margin: const EdgeInsets.all(28),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            TextField(
              key: const Key('join-code'),
              controller: _code,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Code du ride',
                prefixIcon: Icon(Icons.tag_rounded),
              ),
            ),
            const SizedBox(height: 18),
            PrimaryActionButton(
              label: state.isLoading || _joining
                  ? 'Connexion au ride...'
                  : 'Rejoindre le ride',
              icon: Icons.login_rounded,
              onPressed: state.isLoading || _joining
                  ? null
                  : () => _join(context, _code.text),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 16),
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _join(BuildContext context, String code) async {
    if (_joining) return;
    setState(() => _joining = true);
    final ride = await ref
        .read(wheelRideControllerProvider.notifier)
        .joinRide(code);
    if (!mounted) return;
    setState(() => _joining = false);
    if (ride != null && context.mounted) context.go('/rides/live');
  }
}
