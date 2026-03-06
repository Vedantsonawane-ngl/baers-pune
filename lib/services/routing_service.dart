import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Fetches a driving route between two coordinates using the free OSRM API.
class RoutingService {
  static const String _baseUrl =
      'http://router.project-osrm.org/route/v1/driving';

  /// Returns a list of [LatLng] points forming the route, or an empty list on failure.
  static Future<List<LatLng>> getRoute(LatLng from, LatLng to) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;
      if (routes == null || routes.isEmpty) return [];

      final coords = (routes[0]['geometry']['coordinates'] as List)
          .cast<List<dynamic>>();

      return coords
          .map(
            (c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}
