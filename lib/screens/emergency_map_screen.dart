import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/map_entity.dart';
import '../services/location_service.dart';
import '../services/routing_service.dart';

class EmergencyMapScreen extends StatefulWidget {
  /// Optional initial list of entities; defaults to [MapSampleData.entities].
  final List<MapEntity>? entities;

  const EmergencyMapScreen({super.key, this.entities});

  @override
  State<EmergencyMapScreen> createState() => _EmergencyMapScreenState();
}

class _EmergencyMapScreenState extends State<EmergencyMapScreen> {
  // ── Constants ─────────────────────────────────────────────────────────────
  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFF7F7F7);
  static const LatLng _pune = LatLng(18.5204, 73.8567);

  // ── Map controller ────────────────────────────────────────────────────────
  final MapController _mapController = MapController();

  // ── State ─────────────────────────────────────────────────────────────────
  LatLng? _userLocation;
  bool _locationLoading = true;

  List<MapEntity> _entities = [];
  MapEntity? _selectedEntity;

  // Filter toggles
  bool _showDonors = true;
  bool _showHospitals = true;
  bool _showBloodBanks = true;

  // Routing
  MapEntity? _routeFrom;
  MapEntity? _routeTo;
  List<LatLng> _routePoints = [];
  bool _routeLoading = false;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _entities = widget.entities ?? MapSampleData.entities;
    _loadUserLocation();
  }

  Future<void> _loadUserLocation() async {
    final loc = await LocationService.getCurrentLocation();
    if (mounted) {
      setState(() {
        _userLocation = loc;
        _locationLoading = false;
      });
      _mapController.move(loc, 13.5);
    }
  }

  // ── Routing ───────────────────────────────────────────────────────────────
  Future<void> _fetchRoute() async {
    if (_routeFrom == null || _routeTo == null) return;
    setState(() {
      _routeLoading = true;
      _routePoints = [];
    });

    final pts = await RoutingService.getRoute(
      _routeFrom!.position,
      _routeTo!.position,
    );

    if (mounted) {
      setState(() {
        _routePoints = pts;
        _routeLoading = false;
      });
      if (pts.isNotEmpty) {
        _mapController.move(
          LatLng(
            (pts.first.latitude + pts.last.latitude) / 2,
            (pts.first.longitude + pts.last.longitude) / 2,
          ),
          13.0,
        );
      } else {
        _showSnack('Could not calculate route. Check internet connection.');
      }
    }
  }

  void _clearRoute() => setState(() {
    _routeFrom = null;
    _routeTo = null;
    _routePoints = [];
  });

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
    );
  }

  // ── Marker helpers ────────────────────────────────────────────────────────
  Color _entityColor(MapEntityType t) {
    switch (t) {
      case MapEntityType.donor:
        return const Color(0xFF1565C0);
      case MapEntityType.hospital:
        return _red;
      case MapEntityType.bloodBank:
        return const Color(0xFF2E7D32);
    }
  }

  IconData _entityIcon(MapEntityType t) {
    switch (t) {
      case MapEntityType.donor:
        return Icons.person_rounded;
      case MapEntityType.hospital:
        return Icons.local_hospital_rounded;
      case MapEntityType.bloodBank:
        return Icons.water_drop_rounded;
    }
  }

  String _entityLabel(MapEntityType t) {
    switch (t) {
      case MapEntityType.donor:
        return 'Donor';
      case MapEntityType.hospital:
        return 'Hospital';
      case MapEntityType.bloodBank:
        return 'Blood Bank';
    }
  }

  bool _isVisible(MapEntityType t) {
    switch (t) {
      case MapEntityType.donor:
        return _showDonors;
      case MapEntityType.hospital:
        return _showHospitals;
      case MapEntityType.bloodBank:
        return _showBloodBanks;
    }
  }

  // ── Build markers ─────────────────────────────────────────────────────────
  List<Marker> _buildMarkers() {
    final markers = <Marker>[];

    // User location marker
    if (_userLocation != null) {
      markers.add(
        Marker(
          point: _userLocation!,
          width: 48,
          height: 48,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF1565C0), width: 3),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1565C0).withValues(alpha: 0.35),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.my_location_rounded,
              color: Color(0xFF1565C0),
              size: 20,
            ),
          ),
        ),
      );
    }

    // Entity markers
    for (final entity in _entities) {
      if (!_isVisible(entity.type)) continue;

      final color = _entityColor(entity.type);
      final isSelected = _selectedEntity?.id == entity.id;
      final isRouteEnd =
          _routeFrom?.id == entity.id || _routeTo?.id == entity.id;

      markers.add(
        Marker(
          point: entity.position,
          width: isSelected ? 60 : 44,
          height: isSelected ? 60 : 44,
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedEntity = _selectedEntity?.id == entity.id
                  ? null
                  : entity;
            }),
            onLongPress: () => _showRouteDialog(entity),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isRouteEnd ? Colors.white : color.withValues(alpha: 0),
                  width: isRouteEnd ? 3 : 0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: isSelected ? 0.55 : 0.3),
                    blurRadius: isSelected ? 18 : 10,
                    spreadRadius: isSelected ? 3 : 1,
                  ),
                ],
              ),
              child: Icon(
                _entityIcon(entity.type),
                color: Colors.white,
                size: isSelected ? 26 : 20,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
  }

  // ── Route dialog ──────────────────────────────────────────────────────────
  void _showRouteDialog(MapEntity entity) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              entity.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _entityLabel(entity.type),
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            const Text(
              'Set as route point:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF444444),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _routeFrom = entity);
                      Navigator.pop(context);
                      if (_routeFrom != null && _routeTo != null) _fetchRoute();
                    },
                    icon: const Icon(Icons.trip_origin_rounded, size: 16),
                    label: const Text('From here'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _red,
                      side: const BorderSide(color: _red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() => _routeTo = entity);
                      Navigator.pop(context);
                      if (_routeFrom != null && _routeTo != null) _fetchRoute();
                    },
                    icon: const Icon(
                      Icons.location_on_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'To here',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Legend chip ───────────────────────────────────────────────────────────
  Widget _filterChip({
    required String label,
    required bool value,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: value ? color.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value ? color : const Color(0xFFDDDDDD),
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: value ? color : const Color(0xFFAAAAAA),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: value ? color : const Color(0xFFAAAAAA),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info popup ────────────────────────────────────────────────────────────
  Widget _buildInfoCard(MapEntity entity) {
    final color = _entityColor(entity.type);
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: Card(
        elevation: 8,
        shadowColor: Colors.black26,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(_entityIcon(entity.type), color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entity.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (entity.bloodGroup != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDE8E8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              entity.bloodGroup!,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _red,
                              ),
                            ),
                          ),
                          if (entity.subtitle != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              entity.subtitle!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF888888),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ] else if (entity.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        entity.subtitle!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      _entityLabel(entity.type),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () => _showRouteDialog(entity),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.directions_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Route',
                    style: TextStyle(
                      fontSize: 10,
                      color: _red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Route status bar ──────────────────────────────────────────────────────
  Widget _buildRouteBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.trip_origin_rounded,
                        size: 14,
                        color: _red,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _routeFrom?.name ??
                              'Tap & hold a marker → "From here"',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: _red,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _routeTo?.name ?? 'Tap & hold a marker → "To here"',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_routeLoading)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: _red),
              )
            else if (_routeFrom != null || _routeTo != null)
              GestureDetector(
                onTap: _clearRoute,
                child: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFF888888),
                  size: 22,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Emergency Response Map',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location_rounded, color: _red),
            tooltip: 'Go to my location',
            onPressed: () {
              if (_userLocation != null) {
                _mapController.move(_userLocation!, 14.0);
              }
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // ── Filter chips ────────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                _filterChip(
                  label: 'Donors',
                  value: _showDonors,
                  color: const Color(0xFF1565C0),
                  icon: Icons.person_rounded,
                  onTap: () => setState(() => _showDonors = !_showDonors),
                ),
                _filterChip(
                  label: 'Hospitals',
                  value: _showHospitals,
                  color: _red,
                  icon: Icons.local_hospital_rounded,
                  onTap: () => setState(() => _showHospitals = !_showHospitals),
                ),
                _filterChip(
                  label: 'Blood Banks',
                  value: _showBloodBanks,
                  color: const Color(0xFF2E7D32),
                  icon: Icons.water_drop_rounded,
                  onTap: () =>
                      setState(() => _showBloodBanks = !_showBloodBanks),
                ),
              ],
            ),
          ),

          // ── Map ──────────────────────────────────────────────────────
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _pune,
                    initialZoom: 13.0,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                    onTap: (pos, point) =>
                        setState(() => _selectedEntity = null),
                  ),
                  children: [
                    // OSM tiles
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.red_link',
                    ),

                    // Route polyline
                    if (_routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _routePoints,
                            strokeWidth: 5.0,
                            color: _red.withValues(alpha: 0.85),
                          ),
                        ],
                      ),

                    // Markers
                    MarkerLayer(markers: _buildMarkers()),
                  ],
                ),

                // Route bar (always visible when routing is active/available)
                _buildRouteBar(),

                // Location loading indicator
                if (_locationLoading)
                  Positioned(
                    bottom: 80,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _red,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Detecting location…',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF444444),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Selected entity info card
                if (_selectedEntity != null) _buildInfoCard(_selectedEntity!),
              ],
            ),
          ),
        ],
      ),

      // ── FAB: zoom to Pune ──────────────────────────────────────────
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: Colors.white,
        elevation: 4,
        onPressed: () => _mapController.move(_pune, 13.0),
        tooltip: 'Reset to Pune',
        child: const Icon(Icons.location_city_rounded, color: _red, size: 20),
      ),
    );
  }
}
