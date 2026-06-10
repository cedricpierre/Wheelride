import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/providers/wheelride_controller.dart';
import '../../../shared/widgets/action_buttons.dart';
import '../../../shared/widgets/screen_frame.dart';
import '../../../shared/widgets/wheelride_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController(text: 'rider@wheelride.app');
  final _password = TextEditingController(text: 'wheelride');

  @override
  void dispose() {
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
      body: ScreenFrame(
        child: ListView(
          children: [
            const SizedBox(height: 24),
            const WheelRideLogo(compact: true),
            const SizedBox(height: 40),
            Text(
              'Bienvenue !',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            const Text(
              'Connecte-toi pour commencer',
              style: TextStyle(color: AppTheme.muted),
            ),
            const SizedBox(height: 28),
            TextField(
              key: const Key('login-email'),
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              key: const Key('login-password'),
              controller: _password,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 22),
            PrimaryActionButton(
              label: state.isLoading ? 'Connexion...' : 'Se connecter',
              onPressed: state.isLoading
                  ? null
                  : () => ref
                        .read(wheelRideControllerProvider.notifier)
                        .signIn(_email.text, _password.text),
            ),
            const SizedBox(height: 12),
            SecondaryActionButton(
              label: 'Creer un compte',
              onPressed: () => context.go('/signup'),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => ref
                  .read(wheelRideControllerProvider.notifier)
                  .resetPassword(_email.text),
              child: const Text('Mot de passe oublie ?'),
            ),
            _StatusMessage(error: state.error, notice: state.notice),
          ],
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  const _StatusMessage({this.error, this.notice});

  final String? error;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    final text = error ?? notice;
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: error == null ? AppTheme.neon : Colors.redAccent,
        ),
      ),
    );
  }
}
