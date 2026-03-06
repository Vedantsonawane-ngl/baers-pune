import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/blood_bank_model.dart';
import '../services/routing_service.dart';

/// Full-screen animated ambulance route map.
///
/// Shows a polyline from the blood bank to the hospital, then animates
/// a 🚑 marker along it in ~6 seconds for a compelling demo.
class AmbulanceTrackingScreen extends StatefulWidget {
  final BloodBankSosRequest req; // hospital = destination
  final double bankLat;
  final double bankLng;
  final String bankName;

  const AmbulanceTrackingScreen({
    super.key,
    required this.req,
    required this.bankLat,
    required this.bankLng,
    required this.bankName,
  });

  @override
  State<AmbulanceTrackingScreen> createState() =>
      _AmbulanceTrackingScreenState();
}

class _AmbulanceTrackingScreenState extends State<AmbulanceTrackingScreen> {
  static const _red = Color(0xFFD32F2F);
  static const _green = Color(0xFF2E7D32);
  static const int _totalAnimMs = 6000; // demo duration

  final MapController _mapController = MapController();

  List<LatLng> _routePoints = [];
  LatLng? _ambulancePos;
  int _animIndex = 0;
  Timer? _animTimer;
  bool _loading = true;
  bool _arrived = false;

  late final LatLng _bankPos;
  late final LatLng _hospitalPos;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _bankPos = LatLng(widget.bankLat, widget.bankLng);
    _hospitalPos = LatLng(widget.req.lat, widget.req.lng);
    _fetchRoute();
  }

  @override
  void dispose() {
    _animTimer?.cancel();
    super.dispose();
  }

  // ── Route fetch ───────────────────────────────────────────────────────────
  Future<void> _fetchRoute() async {
    final pts = await RoutingService.getRoute(_bankPos, _hospitalPos);
    if (!mounted) return;

    setState(() {
      _routePoints = pts.isEmpty
          ? _straightLine(_bankPos, _hospitalPos, steps: 60)
          : pts;
      _ambulancePos = _routePoints.first;
      _loading = false;
    });

    // Fit camera to show the full route
    if (_routePoints.length > 1) {
      _fitBounds();
    }

    _startAnimation();
  }

  /// Produces a straight-line fallback path when OSRM is unavailable.
  List<LatLng> _straightLine(LatLng a, LatLng b, {int steps = 60}) {
    return List.generate(steps + 1, (i) {
      final t = i / steps;
      return LatLng(
        a.latitude + (b.latitude - a.latitude) * t,
        a.longitude + (b.longitude - a.longitude) * t,
      );
    });
  }

  void _fitBounds() {
    final lats = _routePoints.map((p) => p.latitude);
    final lngs = _routePoints.map((p) => p.longitude);
    final sw = LatLng(
      lats.reduce((a, b) => a < b ? a : b),
      lngs.reduce((a, b) => a < b ? a : b),
    );
    final ne = LatLng(
      lats.reduce((a, b) => a > b ? a : b),
      lngs.reduce((a, b) => a > b ? a : b),
    );
    final bounds = LatLngBounds(sw, ne);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
    );
  }

  // ── Animation ─────────────────────────────────────────────────────────────
  void _startAnimation() {
    if (_routePoints.isEmpty) return;
    final stepMs = (_totalAnimMs / _routePoints.length).round().clamp(50, 500);

    _animTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_animIndex >= _routePoints.length - 1) {
        timer.cancel();
        setState(() {
          _ambulancePos = _routePoints.last;
          _arrived = true;
        });
        return;
      }
      setState(() {
        _animIndex++;
        _ambulancePos = _routePoints[_animIndex];
      });
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ── Map ────────────────────────────────────────────────────────
          _buildMap(),

          // ── Status bar (top) ───────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(child: _buildStatusBar()),
          ),

          // ── Arrival banner (bottom) ────────────────────────────────────
          if (_arrived)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(child: _buildArrivalBanner()),
            ),

          // ── Close button ───────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 16,
            child: Material(
              color: Colors.white,
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.of(context).pop(),
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.close, size: 22, color: Color(0xFF1A1A1A)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (_loading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: _red, strokeWidth: 2),
            SizedBox(height: 16),
            Text(
              'Calculating route…',
              style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
            ),
          ],
        ),
      );
    }

    final centerLat = (_bankPos.latitude + _hospitalPos.latitude) / 2;
    final centerLng = (_bankPos.longitude + _hospitalPos.longitude) / 2;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(centerLat, centerLng),
        initialZoom: 13.0,
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
        ),
      ),
      children: [
        // OSM tiles
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.redlink.app',
          maxZoom: 18,
        ),

        // Route polyline
        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 5,
                color: _red.withValues(alpha: 0.85),
              ),
            ],
          ),

        // Markers
        MarkerLayer(
          markers: [
            // Blood bank (start) — green pin
            Marker(
              width: 44,
              height: 44,
              point: _bankPos,
              child: _PinMarker(
                icon: Icons.local_pharmacy_rounded,
                color: _green,
                tooltip: widget.bankName,
              ),
            ),

            // Hospital (destination) — red pin
            Marker(
              width: 44,
              height: 44,
              point: _hospitalPos,
              child: _PinMarker(
                icon: Icons.local_hospital_rounded,
                color: _red,
                tooltip: widget.req.hospitalName,
              ),
            ),

            // Ambulance — animated position
            if (_ambulancePos != null)
              Marker(
                width: 48,
                height: 48,
                point: _ambulancePos!,
                child: const _AmbulanceMarker(),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('🚑', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _arrived ? 'Blood Delivered!' : 'Blood Delivery in Progress',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _arrived
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _arrived ? 'ARRIVED' : 'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _arrived ? _green : _red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _InfoChip(
                icon: Icons.water_drop_rounded,
                label: '${widget.req.unitsNeeded} units',
                color: _red,
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.bloodtype_rounded,
                label: widget.req.bloodGroup,
                color: const Color(0xFF1565C0),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.navigation_rounded,
                label: widget.req.distance,
                color: const Color(0xFF2E7D32),
              ),
              const SizedBox(width: 8),
              _InfoChip(
                icon: Icons.access_time_rounded,
                label: _arrived ? 'Arrived' : '~${widget.req.neededIn}',
                color: const Color(0xFFF57C00),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalBanner() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Blood Delivered!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.req.unitsNeeded} units of ${widget.req.bloodGroup} '
                  'delivered to ${widget.req.hospitalName}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text(
              'Close',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Small reusable widgets ────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PinMarker extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;

  const _PinMarker({
    required this.icon,
    required this.color,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          // Pin tip
          Transform.rotate(
            angle: 0.785,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmbulanceMarker extends StatelessWidget {
  const _AmbulanceMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD32F2F).withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: const Color(0xFFD32F2F), width: 2.5),
      ),
      alignment: Alignment.center,
      child: const Text('🚑', style: TextStyle(fontSize: 22)),
    );
  }
}
