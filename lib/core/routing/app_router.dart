import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/rides/screens/create_ride_screen.dart';
import '../../features/rides/screens/home_screen.dart';
import '../../features/rides/screens/invite_screen.dart';
import '../../features/rides/screens/join_ride_screen.dart';
import '../../features/rides/screens/live_ride_screen.dart';
import '../../features/rides/screens/participants_screen.dart';
import '../../features/rides/screens/ride_qr_screen.dart';
import '../../shared/providers/wheelride_controller.dart';

final _routerRefreshProvider = Provider<ValueNotifier<int>>((ref) {
  final notifier = ValueNotifier(0);
  ref.listen(wheelRideControllerProvider, (_, __) {
    notifier.value++;
  });
  ref.onDispose(notifier.dispose);
  return notifier;
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(_routerRefreshProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final rideState = ref.read(wheelRideControllerProvider);
      final location = state.matchedLocation;

      if (rideState.isSignedIn && rideState.activeRide != null) {
        if (location == '/home') return '/rides/live';
      }

      if (location == '/rides/live' && rideState.activeRide == null) {
        return '/home';
      }

      if (location == '/rides/participants' && rideState.activeRide == null) {
        return '/home';
      }

      if (location == '/rides/qr' && rideState.activeRide == null) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '/rides/create',
        builder: (context, state) => const CreateRideScreen(),
      ),
      GoRoute(
        path: '/rides/invite',
        builder: (context, state) => const InviteScreen(),
      ),
      GoRoute(
        path: '/rides/join',
        builder: (context, state) => const JoinRideScreen(),
      ),
      GoRoute(
        path: '/rides/live',
        builder: (context, state) => const LiveRideScreen(),
      ),
      GoRoute(
        path: '/rides/participants',
        builder: (context, state) => const ParticipantsScreen(),
      ),
      GoRoute(
        path: '/rides/qr',
        builder: (context, state) => const RideQrScreen(),
      ),
    ],
  );
});
