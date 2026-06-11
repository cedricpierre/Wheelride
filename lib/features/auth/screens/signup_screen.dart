import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/screen_frame.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _name = TextEditingController(text: 'Alex');
  final _email = TextEditingController(text: 'alex@wheelride.app');
  final _password = TextEditingController(text: 'wheelride');

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wheelRideControllerProvider);

    ref.listen(wheelRideControllerProvider, (previous, next) {
      if (previous?.user == null && next.user != null && mounted) {
        context.go('/home');
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(fallbackLocation: '/login'),
        title: const Text(''),
      ),
      body: ScreenFrame(
        child: ListView(
          children: [
            Text(
              'Creer un compte',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 24),
            TextField(
              key: const Key('signup-name'),
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('signup-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('signup-password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: state.isLoading ? 'Creation...' : 'Creer mon compte',
              onPressed: state.isLoading
                  ? null
                  : () => ref
                        .read(wheelRideControllerProvider.notifier)
                        .signUp(_name.text, _email.text, _password.text),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Deja un compte ? '),
                TextButton(
                  onPressed: () => context.go('/login'),
                  child: const Text(
                    'Se connecter',
                    style: TextStyle(color: AppTheme.neon),
                  ),
                ),
              ],
            ),
            if (state.error != null)
              Text(
                state.error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
          ],
        ),
      ),
    );
  }
}
