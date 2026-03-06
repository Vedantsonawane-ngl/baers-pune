import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/blood_bank_model.dart';

class SosRequestDetailsScreen extends StatelessWidget {
  final BloodBankSosRequest req;
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  static const _red = Color(0xFFD32F2F);

  const SosRequestDetailsScreen({
    super.key,
    required this.req,
    required this.onAccept,
    required this.onDecline,
  });

  Color _urgencyColor(SosUrgency u) => u == SosUrgency.critical
      ? _red
      : u == SosUrgency.high
      ? const Color(0xFFF57C00)
      : const Color(0xFF1565C0);

  String _urgencyLabel(SosUrgency u) => u == SosUrgency.critical
      ? 'CRITICAL'
      : u == SosUrgency.high
      ? 'HIGH'
      : 'NORMAL';

  @override
  Widget build(BuildContext context) {
    final urgencyColor = _urgencyColor(req.urgency);
    final point = LatLng(req.lat, req.lng);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Request Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: urgencyColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: urgencyColor.withValues(alpha: 0.35),
                width: 1,
              ),
            ),
            child: Text(
              _urgencyLabel(req.urgency),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: urgencyColor,
              ),
            ),
          ),
        ],
      ),

      // ── Bottom buttons ────────────────────────────────────────────────────
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Accept Request
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  onAccept();
                  Navigator.of(context).pop();
                },
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Accept Request',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Decline
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton(
                onPressed: () {
                  onDecline();
                  Navigator.of(context).pop();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Decline',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF444444),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      body: Stack(
        children: [
          // ── Map ───────────────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 265,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: point,
                  initialZoom: 14.5,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                  ),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.red_link',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: point,
                        width: 52,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            color: _red,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: _red.withValues(alpha: 0.45),
                                blurRadius: 14,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Details card (overlaps map by 26px) ───────────────────────────
          Positioned(
            top: 239, // 265 - 26
            left: 0,
            right: 0,
            bottom: 0,
            child: SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hospital name
                    Text(
                      req.hospitalName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 15,
                          color: Color(0xFF888888),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          req.location,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    const Divider(
                      color: Color(0xFFF0F0F0),
                      thickness: 1,
                      height: 1,
                    ),
                    const SizedBox(height: 22),

                    // ── Info grid ─────────────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            label: 'BLOOD GROUP',
                            icon: const Icon(
                              Icons.water_drop_rounded,
                              size: 17,
                              color: _red,
                            ),
                            value: req.bloodGroup,
                            valueColor: _red,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _InfoBox(
                            label: 'UNITS REQUIRED',
                            icon: const Icon(
                              Icons.water_drop_outlined,
                              size: 17,
                              color: Color(0xFF1A1A1A),
                            ),
                            value: '${req.unitsNeeded} Units',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _InfoBox(
                            label: 'DISTANCE',
                            icon: const Icon(
                              Icons.route_rounded,
                              size: 17,
                              color: Color(0xFF1A1A1A),
                            ),
                            value: req.distance,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: _InfoBox(
                            label: 'TIME LEFT',
                            icon: const Icon(
                              Icons.timer_rounded,
                              size: 17,
                              color: _red,
                            ),
                            value: req.neededIn,
                            valueColor: _red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── Message quote ─────────────────────────────────────
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        '"${req.message}"',
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF444444),
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info box ──────────────────────────────────────────────────────────────
class _InfoBox extends StatelessWidget {
  final String label;
  final Widget icon;
  final String value;
  final Color valueColor;

  const _InfoBox({
    required this.label,
    required this.icon,
    required this.value,
    this.valueColor = const Color(0xFF1A1A1A),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
              letterSpacing: 0.6,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              icon,
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: valueColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
