import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_config.dart';
import '../../core/services/ride_location_tracker.dart';
import '../../core/services/wheelride_repository.dart';
import '../models/wheelride_models.dart';

final wheelRideRepositoryProvider = Provider<WheelRideRepository>((ref) {
  if (AppConfig.hasSupabaseConfig) {
    return SupabaseWheelRideRepository(Supabase.instance.client);
  }

  return DemoWheelRideRepository();
});

final wheelRideControllerProvider =
    NotifierProvider<WheelRideController, WheelRideState>(
      WheelRideController.new,
    );

class WheelRideState {
  const WheelRideState({
    required this.isDemo,
    required this.isLoading,
    this.user,
    this.activeRide,
    this.error,
    this.notice,
    this.locations = const [],
    this.participants = const [],
    this.messages = const [],
  });

  final bool isDemo;
  final bool isLoading;
  final AppUser? user;
  final Ride? activeRide;
  final String? error;
  final String? notice;
  final List<RideLocation> locations;
  final List<RideParticipant> participants;
  final List<RideMessage> messages;

  bool get isSignedIn => user != null;

  WheelRideState copyWith({
    bool? isLoading,
    AppUser? user,
    Ride? activeRide,
    String? error,
    String? notice,
    List<RideLocation>? locations,
    List<RideParticipant>? participants,
    List<RideMessage>? messages,
    bool clearError = false,
    bool clearNotice = false,
    bool clearActiveRide = false,
  }) {
    return WheelRideState(
      isDemo: isDemo,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      activeRide: clearActiveRide ? null : (activeRide ?? this.activeRide),
      error: clearError ? null : error ?? this.error,
      notice: clearNotice ? null : notice ?? this.notice,
      locations: locations ?? this.locations,
      participants: participants ?? this.participants,
      messages: messages ?? this.messages,
    );
  }

  factory WheelRideState.initial(bool isDemo) {
    return WheelRideState(isDemo: isDemo, isLoading: false);
  }
}

class WheelRideController extends Notifier<WheelRideState> {
  final _uuid = const Uuid();
  StreamSubscription<List<RideLocation>>? _locationsSub;
  StreamSubscription<List<RideParticipant>>? _participantsSub;
  StreamSubscription<RideMessage>? _messagesSub;
  Timer? _locationTimer;
  final _locationTracker = RideLocationTracker();
  DateTime? _lastPublishedAt;
  bool _bootstrapped = false;

  late WheelRideRepository _repository;

  @override
  WheelRideState build() {
    _repository = ref.watch(wheelRideRepositoryProvider);
    ref.onDispose(_disposeRideSubscriptions);

    if (!_bootstrapped) {
      _bootstrapped = true;
      Future.microtask(_bootstrap);
    }

    return WheelRideState.initial(_repository.isDemo);
  }

  Future<void> _bootstrap() async {
    final user = await _repository.currentUser();
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> signIn(String email, String password) async {
    await _run(() async {
      final user = await _repository.signIn(email.trim(), password);
      state = state.copyWith(user: user, notice: 'Bienvenue sur WheelRide.');
    });
  }

  Future<void> signUp(String name, String email, String password) async {
    await _run(() async {
      final user = await _repository.signUp(
        name.trim(),
        email.trim(),
        password,
      );
      state = state.copyWith(user: user, notice: 'Compte cree.');
    });
  }

  Future<void> resetPassword(String email) async {
    await _run(() async {
      await _repository.resetPassword(email.trim());
      state = state.copyWith(notice: 'Email de reinitialisation envoye.');
    });
  }

  Future<void> signOut() async {
    await _repository.signOut();
    _disposeRideSubscriptions();
    state = WheelRideState.initial(_repository.isDemo);
  }

  Future<Ride?> createRide(String name, String? description) async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(error: 'Connecte-toi pour creer un ride.');
      return null;
    }

    Ride? ride;
    await _run(() async {
      ride = await _repository.createRide(
        ownerId: user.id,
        name: name.trim(),
        description: description?.trim().isEmpty == true
            ? null
            : description?.trim(),
      );
      await _attachRide(ride!);
    });
    return ride;
  }

  Future<Ride?> joinRide(String rawCode) async {
    final user = state.user;
    if (user == null) {
      state = state.copyWith(error: 'Connecte-toi pour rejoindre un ride.');
      return null;
    }

    Ride? ride;
    await _run(() async {
      ride = await _repository.joinRide(
        userId: user.id,
        joinCode: _normalizeJoinCode(rawCode),
      );
      await _attachRide(ride!);
      state = state.copyWith(notice: 'Tu as rejoint le ride.');
    });
    return ride;
  }

  Future<void> startRide() async {
    final ride = state.activeRide;
    if (ride == null) return;
    await _attachRide(ride);
  }

  Future<void> leaveRide() async {
    _disposeRideSubscriptions();
    state = state.copyWith(
      clearActiveRide: true,
      locations: const [],
      participants: const [],
      messages: const [],
      notice: 'Tu as quitte le ride.',
    );
  }

  Future<void> sendMessage(String text) async {
    final user = state.user;
    final ride = state.activeRide;
    final messageText = text.trim();
    if (user == null || ride == null || messageText.isEmpty) return;

    final message = RideMessage(
      id: _uuid.v4(),
      rideId: ride.id,
      userId: user.id,
      userName: user.name,
      message: messageText,
      createdAt: DateTime.now(),
    );
    await _repository.sendMessage(message);
  }

  Future<void> _attachRide(Ride ride) async {
    await _locationsSub?.cancel();
    await _participantsSub?.cancel();
    await _messagesSub?.cancel();
    _locationTimer?.cancel();
    await _locationTracker.stop();
    _lastPublishedAt = null;

    state = state.copyWith(
      activeRide: ride,
      locations: const [],
      participants: const [],
      messages: const [],
    );

    _locationsSub = _repository.watchLocations(ride.id).listen((locations) {
      state = state.copyWith(locations: locations);
    });
    _participantsSub = _repository.watchParticipants(ride.id).listen((
      participants,
    ) {
      state = state.copyWith(participants: participants);
    });
    _messagesSub = _repository.watchNewMessages(ride.id).listen((message) {
      state = state.copyWith(messages: [...state.messages, message]);
    });

    if (_repository.isDemo) {
      await _publishDemoLocation();
      _locationTimer = Timer.periodic(
        const Duration(seconds: 6),
        (_) => unawaited(_publishDemoLocation()),
      );
      return;
    }

    await _locationTracker.start(
      onPosition: (position) => unawaited(_publishPosition(position)),
      onError: (_) {
        state = state.copyWith(
          notice: 'Localisation indisponible pour le moment.',
        );
      },
    );
  }

  Future<void> _publishDemoLocation() async {
    final user = state.user;
    final ride = state.activeRide;
    if (user == null || ride == null) return;

    final now = DateTime.now();
    final tick = now.second / 10000;
    await _repository.updateLocation(
      RideLocation(
        rideId: ride.id,
        userId: user.id,
        latitude: 44.1741 + tick,
        longitude: 5.2782 + tick,
        speed: 52,
        heading: 35,
        updatedAt: now,
      ),
    );
  }

  Future<void> _publishPosition(Position position) async {
    final user = state.user;
    final ride = state.activeRide;
    if (user == null || ride == null) return;

    final now = DateTime.now();
    if (_lastPublishedAt != null &&
        now.difference(_lastPublishedAt!) < const Duration(seconds: 5)) {
      return;
    }
    _lastPublishedAt = now;

    try {
      await _repository.updateLocation(
        RideLocation(
          rideId: ride.id,
          userId: user.id,
          latitude: position.latitude,
          longitude: position.longitude,
          speed: position.speed,
          heading: position.heading,
          updatedAt: now,
        ),
      );
    } on Object catch (_) {
      state = state.copyWith(
        notice: 'Localisation indisponible pour le moment.',
      );
    }
  }

  String _normalizeJoinCode(String rawCode) {
    final trimmed = rawCode.trim();
    final uri = Uri.tryParse(trimmed);
    if (uri != null && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last.toUpperCase();
    }
    return trimmed.toUpperCase();
  }

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearNotice: true,
    );
    try {
      await action();
    } on Object catch (error) {
      state = state.copyWith(error: '$error');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  void _disposeRideSubscriptions() {
    unawaited(_locationsSub?.cancel());
    unawaited(_participantsSub?.cancel());
    unawaited(_messagesSub?.cancel());
    _locationTimer?.cancel();
    unawaited(_locationTracker.stop());
    _lastPublishedAt = null;
  }
}
