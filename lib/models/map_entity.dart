import 'package:latlong2/latlong.dart';

enum MapEntityType { donor, hospital, bloodBank }

class MapEntity {
  final String id;
  final String name;
  final MapEntityType type;
  final LatLng position;
  final String? bloodGroup; // donors only
  final String? subtitle; // e.g. distance, phone

  const MapEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.position,
    this.bloodGroup,
    this.subtitle,
  });
}

/// Sample Pune-area data used when no live data is passed.
class MapSampleData {
  static const List<MapEntity> entities = [
    // ── Hospitals ────────────────────────────────────────────────
    MapEntity(
      id: 'h1',
      name: 'Ruby Hall Clinic',
      type: MapEntityType.hospital,
      position: LatLng(18.5314, 73.8446),
      subtitle: 'Shivajinagar, Pune',
    ),
    MapEntity(
      id: 'h2',
      name: 'KEM Hospital',
      type: MapEntityType.hospital,
      position: LatLng(18.5308, 73.8631),
      subtitle: 'Rasta Peth, Pune',
    ),
    MapEntity(
      id: 'h3',
      name: 'Sassoon General Hospital',
      type: MapEntityType.hospital,
      position: LatLng(18.5167, 73.8567),
      subtitle: 'Camp, Pune',
    ),
    MapEntity(
      id: 'h4',
      name: 'Jehangir Hospital',
      type: MapEntityType.hospital,
      position: LatLng(18.5244, 73.8794),
      subtitle: 'Shivajinagar, Pune',
    ),

    // ── Blood Banks ──────────────────────────────────────────────
    MapEntity(
      id: 'bb1',
      name: 'Jeevan Blood Bank',
      type: MapEntityType.bloodBank,
      position: LatLng(18.5196, 73.8553),
      subtitle: 'Deccan, Pune',
    ),
    MapEntity(
      id: 'bb2',
      name: 'Sahyadri Blood Centre',
      type: MapEntityType.bloodBank,
      position: LatLng(18.5041, 73.8117),
      subtitle: 'Kothrud, Pune',
    ),
    MapEntity(
      id: 'bb3',
      name: 'Deenanath Blood Bank',
      type: MapEntityType.bloodBank,
      position: LatLng(18.5062, 73.8337),
      subtitle: 'Erandwane, Pune',
    ),

    // ── Donors ────────────────────────────────────────────────────
    MapEntity(
      id: 'd1',
      name: 'Rahul Sharma',
      type: MapEntityType.donor,
      position: LatLng(18.5280, 73.8490),
      bloodGroup: 'O+',
      subtitle: '1.2 km away',
    ),
    MapEntity(
      id: 'd2',
      name: 'Kavita Rao',
      type: MapEntityType.donor,
      position: LatLng(18.5220, 73.8710),
      bloodGroup: 'A+',
      subtitle: '2.3 km away',
    ),
    MapEntity(
      id: 'd3',
      name: 'Aditya Patil',
      type: MapEntityType.donor,
      position: LatLng(18.5150, 73.8620),
      bloodGroup: 'B+',
      subtitle: '3.5 km away',
    ),
    MapEntity(
      id: 'd4',
      name: 'Priya Joshi',
      type: MapEntityType.donor,
      position: LatLng(18.5340, 73.8720),
      bloodGroup: 'AB-',
      subtitle: '4.1 km away',
    ),
    MapEntity(
      id: 'd5',
      name: 'Meera Desai',
      type: MapEntityType.donor,
      position: LatLng(18.5098, 73.8410),
      bloodGroup: 'O-',
      subtitle: '5.0 km away',
    ),
  ];
}
