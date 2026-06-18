import 'package:latlong2/latlong.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      name: (map['name'] ?? 'Rider') as String,
      email: (map['email'] ?? '') as String,
      avatarUrl: map['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'avatar_url': avatarUrl,
  };
}

class Ride {
  const Ride({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.joinCode,
    required this.status,
    required this.createdAt,
    this.description,
  });

  final String id;
  final String name;
  final String? description;
  final String ownerId;
  final String joinCode;
  final String status;
  final DateTime createdAt;

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String?,
      ownerId: map['owner_id'] as String,
      joinCode: map['join_code'] as String,
      status: (map['status'] ?? 'active') as String,
      createdAt: DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
    );
  }
}

class RideParticipant {
  const RideParticipant({
    required this.rideId,
    required this.userId,
    required this.name,
    required this.isOnline,
    required this.isOwner,
    this.avatarUrl,
  });

  final String rideId;
  final String userId;
  final String name;
  final bool isOnline;
  final bool isOwner;
  final String? avatarUrl;
}

class RideLocation {
  const RideLocation({
    required this.rideId,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.updatedAt,
    this.speed,
    this.heading,
  });

  final String rideId;
  final String userId;
  final double latitude;
  final double longitude;
  final double? speed;
  final double? heading;
  final DateTime updatedAt;

  LatLng get point => LatLng(latitude, longitude);

  factory RideLocation.fromMap(Map<String, dynamic> map) {
    return RideLocation(
      rideId: map['ride_id'] as String,
      userId: map['user_id'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      speed: (map['speed'] as num?)?.toDouble(),
      heading: (map['heading'] as num?)?.toDouble(),
      updatedAt: DateTime.tryParse('${map['updated_at']}') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'ride_id': rideId,
    'user_id': userId,
    'latitude': latitude,
    'longitude': longitude,
    'speed': speed,
    'heading': heading,
    'updated_at': updatedAt.toIso8601String(),
  };
}

class RideMessage {
  const RideMessage({
    required this.id,
    required this.rideId,
    required this.userId,
    required this.userName,
    required this.message,
    required this.createdAt,
  });

  final String id;
  final String rideId;
  final String userId;
  final String userName;
  final String message;
  final DateTime createdAt;

  factory RideMessage.fromMap(
    Map<String, dynamic> map, {
    String userName = 'Rider',
  }) {
    return RideMessage(
      id: map['id'] as String,
      rideId: map['ride_id'] as String,
      userId: map['user_id'] as String,
      userName: userName,
      message: map['message'] as String,
      createdAt: DateTime.tryParse('${map['created_at']}') ?? DateTime.now(),
    );
  }
}

extension RideParticipantListX on List<RideParticipant> {
  RideParticipant? byUserId(String userId) {
    for (final participant in this) {
      if (participant.userId == userId) return participant;
    }
    return null;
  }
}
