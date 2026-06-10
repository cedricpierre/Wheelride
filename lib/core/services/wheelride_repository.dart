import 'dart:async';
import 'dart:math';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../shared/models/wheelride_models.dart';

abstract class WheelRideRepository {
  bool get isDemo;

  Future<AppUser?> currentUser();
  Future<AppUser> signIn(String email, String password);
  Future<AppUser> signUp(String name, String email, String password);
  Future<void> resetPassword(String email);
  Future<void> signOut();
  Future<Ride> createRide({
    required String ownerId,
    required String name,
    String? description,
  });
  Future<Ride> joinRide({required String userId, required String joinCode});
  Future<void> updateLocation(RideLocation location);
  Future<void> sendMessage(RideMessage message);
  Stream<List<RideLocation>> watchLocations(String rideId);
  Stream<List<RideParticipant>> watchParticipants(String rideId);
  Stream<RideMessage> watchNewMessages(String rideId);
}

class DemoWheelRideRepository implements WheelRideRepository {
  final _uuid = const Uuid();
  final _rides = <String, Ride>{};
  final _participants = <String, List<RideParticipant>>{};
  final _locations = <String, List<RideLocation>>{};
  final _locationController =
      StreamController<_RideSnapshot<RideLocation>>.broadcast();
  final _participantController =
      StreamController<_RideSnapshot<RideParticipant>>.broadcast();
  final _messageController = StreamController<RideMessage>.broadcast();

  AppUser? _user;

  @override
  bool get isDemo => true;

  @override
  Future<AppUser?> currentUser() async => _user;

  @override
  Future<AppUser> signIn(String email, String password) async {
    _user = AppUser(
      id: 'demo-user',
      name: email.split('@').first.isEmpty ? 'Vous' : email.split('@').first,
      email: email,
    );
    return _user!;
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    _user = AppUser(id: 'demo-user', name: name, email: email);
    return _user!;
  }

  @override
  Future<void> resetPassword(String email) async {}

  @override
  Future<void> signOut() async {
    _user = null;
  }

  @override
  Future<Ride> createRide({
    required String ownerId,
    required String name,
    String? description,
  }) async {
    final ride = Ride(
      id: _uuid.v4(),
      name: name,
      description: description,
      ownerId: ownerId,
      joinCode: _joinCode(),
      status: 'active',
      createdAt: DateTime.now(),
    );

    _rides[ride.id] = ride;
    _participants[ride.id] = [
      RideParticipant(
        rideId: ride.id,
        userId: ownerId,
        name: _user?.name ?? 'Vous',
        isOnline: true,
        isOwner: true,
      ),
      RideParticipant(
        rideId: ride.id,
        userId: 'demo-tom',
        name: 'Tom',
        isOnline: true,
        isOwner: false,
      ),
      RideParticipant(
        rideId: ride.id,
        userId: 'demo-julie',
        name: 'Julie',
        isOnline: true,
        isOwner: false,
      ),
    ];
    _locations[ride.id] = _demoLocations(ride.id, ownerId);
    _emitParticipants(ride.id);
    _emitLocations(ride.id);
    return ride;
  }

  @override
  Future<Ride> joinRide({
    required String userId,
    required String joinCode,
  }) async {
    final ride = _rides.values.firstWhere(
      (ride) => ride.joinCode == joinCode.toUpperCase(),
      orElse: () => Ride(
        id: _uuid.v4(),
        name: 'Balade du dimanche',
        description: 'Ride demo rejoint par code',
        ownerId: 'demo-tom',
        joinCode: joinCode.toUpperCase(),
        status: 'active',
        createdAt: DateTime.now(),
      ),
    );

    _rides[ride.id] = ride;
    _participants[ride.id] = [
      RideParticipant(
        rideId: ride.id,
        userId: 'demo-tom',
        name: 'Tom',
        isOnline: true,
        isOwner: true,
      ),
      RideParticipant(
        rideId: ride.id,
        userId: userId,
        name: _user?.name ?? 'Vous',
        isOnline: true,
        isOwner: false,
      ),
      RideParticipant(
        rideId: ride.id,
        userId: 'demo-max',
        name: 'Max',
        isOnline: true,
        isOwner: false,
      ),
    ];
    _locations[ride.id] = _demoLocations(ride.id, userId);
    _emitParticipants(ride.id);
    _emitLocations(ride.id);
    return ride;
  }

  @override
  Future<void> updateLocation(RideLocation location) async {
    final rideLocations = [...?_locations[location.rideId]];
    final index = rideLocations.indexWhere(
      (item) => item.userId == location.userId,
    );
    if (index == -1) {
      rideLocations.add(location);
    } else {
      rideLocations[index] = location;
    }
    _locations[location.rideId] = rideLocations;
    _emitLocations(location.rideId);
  }

  @override
  Future<void> sendMessage(RideMessage message) async {
    _messageController.add(message);
  }

  @override
  Stream<List<RideLocation>> watchLocations(String rideId) async* {
    yield _locations[rideId] ?? const [];
    yield* _locationController.stream
        .where((snapshot) => snapshot.rideId == rideId)
        .map((snapshot) => snapshot.items);
  }

  @override
  Stream<List<RideParticipant>> watchParticipants(String rideId) async* {
    yield _participants[rideId] ?? const [];
    yield* _participantController.stream
        .where((snapshot) => snapshot.rideId == rideId)
        .map((snapshot) => snapshot.items);
  }

  @override
  Stream<RideMessage> watchNewMessages(String rideId) {
    return _messageController.stream.where(
      (message) => message.rideId == rideId,
    );
  }

  String _joinCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    return List.generate(
      6,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }

  List<RideLocation> _demoLocations(String rideId, String userId) {
    final now = DateTime.now();
    return [
      RideLocation(
        rideId: rideId,
        userId: userId,
        latitude: 44.1741,
        longitude: 5.2782,
        speed: 52,
        heading: 35,
        updatedAt: now,
      ),
      RideLocation(
        rideId: rideId,
        userId: 'demo-tom',
        latitude: 44.182,
        longitude: 5.291,
        speed: 47,
        heading: 25,
        updatedAt: now,
      ),
      RideLocation(
        rideId: rideId,
        userId: 'demo-julie',
        latitude: 44.164,
        longitude: 5.301,
        speed: 49,
        heading: 18,
        updatedAt: now,
      ),
    ];
  }

  void _emitLocations(String rideId) {
    _locationController.add(
      _RideSnapshot(rideId, _locations[rideId] ?? const []),
    );
  }

  void _emitParticipants(String rideId) {
    _participantController.add(
      _RideSnapshot(rideId, _participants[rideId] ?? const []),
    );
  }
}

class SupabaseWheelRideRepository implements WheelRideRepository {
  SupabaseWheelRideRepository(this._client);

  final SupabaseClient _client;
  final _uuid = const Uuid();

  @override
  bool get isDemo => false;

  @override
  Future<AppUser?> currentUser() async {
    final authUser = _client.auth.currentUser;
    if (authUser == null) return null;

    final row = await _client
        .from('users')
        .select()
        .eq('id', authUser.id)
        .maybeSingle();

    if (row != null) return AppUser.fromMap(row);

    final name = (authUser.userMetadata?['name'] ?? 'Rider') as String;
    final profile = AppUser(
      id: authUser.id,
      name: name,
      email: authUser.email ?? '',
    );
    await _client.from('users').upsert(profile.toMap());
    return profile;
  }

  @override
  Future<AppUser> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    final user = response.user;
    if (user == null) throw StateError('Unable to sign in.');
    return (await currentUser()) ??
        AppUser(id: user.id, name: email.split('@').first, email: email);
  }

  @override
  Future<AppUser> signUp(String name, String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    final user = response.user;
    if (user == null) {
      throw StateError('Check your email to confirm the account.');
    }

    final profile = AppUser(id: user.id, name: name, email: email);
    await _client.from('users').upsert(profile.toMap());
    return profile;
  }

  @override
  Future<void> resetPassword(String email) {
    return _client.auth.resetPasswordForEmail(email);
  }

  @override
  Future<void> signOut() {
    return _client.auth.signOut();
  }

  @override
  Future<Ride> createRide({
    required String ownerId,
    required String name,
    String? description,
  }) async {
    final payload = {
      'id': _uuid.v4(),
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'join_code': _joinCode(),
      'status': 'active',
    };
    final row = await _client.from('rides').insert(payload).select().single();
    await _client.from('ride_participants').insert({
      'ride_id': row['id'],
      'user_id': ownerId,
    });
    return Ride.fromMap(row);
  }

  @override
  Future<Ride> joinRide({
    required String userId,
    required String joinCode,
  }) async {
    final row = await _client
        .from('rides')
        .select()
        .eq('join_code', joinCode.toUpperCase())
        .eq('status', 'active')
        .single();

    await _client.from('ride_participants').upsert({
      'ride_id': row['id'],
      'user_id': userId,
    });
    return Ride.fromMap(row);
  }

  @override
  Future<void> updateLocation(RideLocation location) async {
    await _client.from('ride_locations').upsert(location.toMap());
  }

  @override
  Future<void> sendMessage(RideMessage message) async {
    await _client.from('ride_messages').insert({
      'id': message.id,
      'ride_id': message.rideId,
      'user_id': message.userId,
      'message': message.message,
    });
  }

  @override
  Stream<List<RideLocation>> watchLocations(String rideId) {
    return _client
        .from('ride_locations')
        .stream(primaryKey: ['ride_id', 'user_id'])
        .eq('ride_id', rideId)
        .map((rows) => rows.map(RideLocation.fromMap).toList());
  }

  @override
  Stream<List<RideParticipant>> watchParticipants(String rideId) {
    return _client
        .from('ride_participants')
        .stream(primaryKey: ['ride_id', 'user_id'])
        .eq('ride_id', rideId)
        .asyncMap((rows) async {
          final ride = await _client
              .from('rides')
              .select()
              .eq('id', rideId)
              .single();
          final userIds = rows.map((row) => row['user_id'] as String).toList();
          if (userIds.isEmpty) return <RideParticipant>[];

          final profiles = await _client
              .from('users')
              .select()
              .inFilter('id', userIds);
          final profileById = {
            for (final profile in profiles) profile['id'] as String: profile,
          };

          return rows.map((row) {
            final userId = row['user_id'] as String;
            final profile = profileById[userId] ?? const <String, dynamic>{};
            return RideParticipant(
              rideId: rideId,
              userId: userId,
              name: (profile['name'] ?? 'Rider') as String,
              avatarUrl: profile['avatar_url'] as String?,
              isOnline: true,
              isOwner: ride['owner_id'] == userId,
            );
          }).toList();
        });
  }

  @override
  Stream<RideMessage> watchNewMessages(String rideId) {
    late final RealtimeChannel channel;
    final controller = StreamController<RideMessage>();

    channel = _client
        .channel('ride_messages:$rideId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'ride_messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'ride_id',
            value: rideId,
          ),
          callback: (payload) {
            controller.add(RideMessage.fromMap(payload.newRecord));
          },
        )
        .subscribe();

    controller.onCancel = () {
      unawaited(_client.removeChannel(channel));
    };

    return controller.stream;
  }

  String _joinCode() {
    const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random.secure();
    return List.generate(
      6,
      (_) => alphabet[random.nextInt(alphabet.length)],
    ).join();
  }
}

class _RideSnapshot<T> {
  const _RideSnapshot(this.rideId, this.items);

  final String rideId;
  final List<T> items;
}
