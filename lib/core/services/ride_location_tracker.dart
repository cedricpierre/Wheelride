import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class RideLocationTracker {
  StreamSubscription<Position>? _subscription;

  Future<bool> ensurePermissions() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  LocationSettings _locationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 6),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'WheelRide',
          notificationText:
              'Partage de ta position en cours pendant le ride.',
          enableWakeLock: true,
        ),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 5,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }

    return const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );
  }

  Future<void> start({
    required void Function(Position position) onPosition,
    void Function(Object error)? onError,
  }) async {
    await stop();

    final hasPermission = await ensurePermissions();
    if (!hasPermission) {
      onError?.call(StateError('Location permission denied'));
      return;
    }

    _subscription = Geolocator.getPositionStream(
      locationSettings: _locationSettings(),
    ).listen(onPosition, onError: onError);
  }

  Future<void> stop() async {
    await _subscription?.cancel();
    _subscription = null;
  }
}
