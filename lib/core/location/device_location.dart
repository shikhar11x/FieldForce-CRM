import 'package:geolocator/geolocator.dart';

/// Ek GPS reading. [accuracyMeters] jitna chhota, utna behtar.
class DeviceFix {
  const DeviceFix({
    required this.latitude,
    required this.longitude,
    required this.accuracyMeters,
  });

  final double latitude;
  final double longitude;
  final double accuracyMeters;
}

class LocationException implements Exception {
  const LocationException(this.message, {this.canOpenSettings = false});

  final String message;

  /// True ho to user ko app settings kholne ka button dikhta hai.
  final bool canOpenSettings;

  @override
  String toString() => message;
}

/// Permission maangta hai aur ek taaza high-accuracy reading deta hai.
/// Location background me track nahi hoti, sirf jab ye call hota hai.
Future<DeviceFix> getDeviceFix() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const LocationException(
      'Location is turned off. Turn it on in your phone settings and try again.',
    );
  }

  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied) {
    throw const LocationException(
      'Location permission is needed to verify that you are at the customer.',
    );
  }
  if (permission == LocationPermission.deniedForever) {
    throw const LocationException(
      'Location permission is blocked. Allow it in the app settings.',
      canOpenSettings: true,
    );
  }

  try {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 20),
      ),
    );
    return DeviceFix(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracyMeters: position.accuracy,
    );
  } on Exception {
    throw const LocationException(
      'Could not get your location. Move to an open area and try again.',
    );
  }
}

Future<void> openLocationAppSettings() => Geolocator.openAppSettings();