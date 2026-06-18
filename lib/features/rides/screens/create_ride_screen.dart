import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/screen_frame.dart';
import '../../../shared/widgets/status_message.dart';

class CreateRideScreen extends ConsumerStatefulWidget {
  const CreateRideScreen({super.key});

  @override
  ConsumerState<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends ConsumerState<CreateRideScreen> {
  final _name = TextEditingController(text: 'Balade du dimanche');
  final _description = TextEditingController(text: 'Petite balade entre potes');

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelRideControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Creer un ride'),
      ),
      body: ScreenFrame(
        child: ListView(
          children: [
            const Text('Nom du ride'),
            const SizedBox(height: 8),
            TextField(
              key: const Key('ride-name'),
              controller: _name,
              decoration: const InputDecoration(hintText: 'Balade du dimanche'),
            ),
            const SizedBox(height: 18),
            const Text('Description (optionnel)'),
            const SizedBox(height: 8),
            TextField(
              key: const Key('ride-description'),
              controller: _description,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Point de rendez-vous, ambiance, infos utiles...',
              ),
            ),
            const SizedBox(height: 28),
            PrimaryActionButton(
              label: state.isLoading ? 'Creation...' : 'Creer le ride',
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final ride = await ref
                          .read(wheelRideControllerProvider.notifier)
                          .createRide(_name.text, _description.text);
                      if (ride != null && context.mounted) {
                        context.push('/rides/invite');
                      }
                    },
            ),
            StatusMessage(error: state.error),
          ],
        ),
      ),
    );
  }
}
