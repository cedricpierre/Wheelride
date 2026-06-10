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

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
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
    ],
  );
});
