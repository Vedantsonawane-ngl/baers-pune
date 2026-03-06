import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Provides the device's current GPS location.
/// Falls back to Pune city centre if permission is denied or unavailable.
class LocationService {
  static const LatLng _puneDefault = LatLng(18.5204, 73.8567);

  /// Returns the current position or the Pune default.
  static Future<LatLng> getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return _puneDefault;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return _puneDefault;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 8),
        ),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      return _puneDefault;
    }
  }
}
