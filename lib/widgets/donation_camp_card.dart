import 'package:flutter/material.dart';

class DonationCamp {
  final String name;
  final String location;
  final String openUntil;
  final Color iconBgColor;
  final IconData icon;

  const DonationCamp({
    required this.name,
    required this.location,
    required this.openUntil,
    required this.iconBgColor,
    required this.icon,
  });
}

class DonationCampCard extends StatelessWidget {
  final DonationCamp camp;
  final VoidCallback onViewDetails;

  const DonationCampCard({
    super.key,
    required this.camp,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 14),
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
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: camp.iconBgColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(camp.icon, color: camp.iconBgColor, size: 22),
            ),
            const SizedBox(height: 10),
            // Name
            Text(
              camp.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Location
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 12,
                  color: Color(0xFFAAAAAA),
                ),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    camp.location,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Open until
            Row(
              children: [
                const Icon(
                  Icons.access_time_filled,
                  size: 13,
                  color: Color(0xFF2E7D32),
                ),
                const SizedBox(width: 4),
                Text(
                  'Open until ${camp.openUntil}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // View Details button
            GestureDetector(
              onTap: onViewDetails,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
