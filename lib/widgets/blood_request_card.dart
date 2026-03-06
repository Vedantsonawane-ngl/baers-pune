import 'package:flutter/material.dart';

enum UrgencyLevel { critical, high, normal }

class BloodRequest {
  final String bloodGroup;
  final String hospitalName;
  final String distance;
  final String neededBy;
  final UrgencyLevel urgency;

  const BloodRequest({
    required this.bloodGroup,
    required this.hospitalName,
    required this.distance,
    required this.neededBy,
    required this.urgency,
  });
}

class BloodRequestCard extends StatelessWidget {
  final BloodRequest request;
  final VoidCallback onRespond;

  const BloodRequestCard({
    super.key,
    required this.request,
    required this.onRespond,
  });

  Color get _urgencyColor {
    switch (request.urgency) {
      case UrgencyLevel.critical:
        return const Color(0xFFD32F2F);
      case UrgencyLevel.high:
        return const Color(0xFFF57C00);
      case UrgencyLevel.normal:
        return const Color(0xFF757575);
    }
  }

  String get _urgencyLabel {
    switch (request.urgency) {
      case UrgencyLevel.critical:
        return 'CRITICAL';
      case UrgencyLevel.high:
        return 'HIGH';
      case UrgencyLevel.normal:
        return 'NORMAL';
    }
  }

  IconData get _urgencyIcon {
    switch (request.urgency) {
      case UrgencyLevel.critical:
        return Icons.warning_amber_rounded;
      case UrgencyLevel.high:
        return Icons.priority_high_rounded;
      case UrgencyLevel.normal:
        return Icons.info_outline_rounded;
    }
  }

  Color get _buttonBg {
    switch (request.urgency) {
      case UrgencyLevel.critical:
        return const Color(0xFFD32F2F);
      case UrgencyLevel.high:
        return const Color(0xFFFDE8E8);
      case UrgencyLevel.normal:
        return const Color(0xFFFDE8E8);
    }
  }

  Color get _buttonText {
    switch (request.urgency) {
      case UrgencyLevel.critical:
        return Colors.white;
      case UrgencyLevel.high:
        return const Color(0xFFD32F2F);
      case UrgencyLevel.normal:
        return const Color(0xFFD32F2F);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: blood group circle, hospital info, urgency badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Blood group circle
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    request.bloodGroup,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Hospital name + distance
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.hospitalName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            size: 13,
                            color: Color(0xFFAAAAAA),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            request.distance,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Urgency badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: _urgencyColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _urgencyColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_urgencyIcon, size: 12, color: _urgencyColor),
                      const SizedBox(width: 4),
                      Text(
                        _urgencyLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _urgencyColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Bottom row: needed by + respond button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Needed by: ${request.neededBy}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF666666),
                  ),
                ),
                GestureDetector(
                  onTap: onRespond,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _buttonBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Respond to Request',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _buttonText,
                      ),
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
}
