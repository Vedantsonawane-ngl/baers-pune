import 'package:flutter/material.dart';
import '../models/donor_model.dart';
import '../models/blood_request_api_model.dart';
import '../services/api_service.dart';
import '../services/requests_store.dart';
import '../widgets/blood_group_card.dart';
import '../widgets/blood_request_card.dart';
import '../widgets/donation_camp_card.dart';

class DonorDashboardScreen extends StatefulWidget {
  final DonorModel donor;

  const DonorDashboardScreen({super.key, required this.donor});

  @override
  State<DonorDashboardScreen> createState() => _DonorDashboardScreenState();
}

class _DonorDashboardScreenState extends State<DonorDashboardScreen> {
  int _currentTab = 0;

  static const _red = Color(0xFFD32F2F);

  // ── Sample blood requests data ──────────────────────────────────────────
  static final List<BloodRequest> _requests = [
    const BloodRequest(
      bloodGroup: 'B+',
      hospitalName: 'Ruby Hall Clinic',
      distance: '2.4 km away',
      neededBy: 'Today, 6:00 PM',
      urgency: UrgencyLevel.critical,
    ),
    const BloodRequest(
      bloodGroup: 'O+',
      hospitalName: 'Sassoon General Hospital',
      distance: '5.1 km away',
      neededBy: 'Tomorrow, 10:00 AM',
      urgency: UrgencyLevel.high,
    ),
    const BloodRequest(
      bloodGroup: 'A−',
      hospitalName: 'Jehangir Hospital',
      distance: '7.8 km away',
      neededBy: 'Wed, 12:00 PM',
      urgency: UrgencyLevel.normal,
    ),
    const BloodRequest(
      bloodGroup: 'AB+',
      hospitalName: 'KEM Hospital',
      distance: '3.2 km away',
      neededBy: 'Today, 8:00 PM',
      urgency: UrgencyLevel.critical,
    ),
    const BloodRequest(
      bloodGroup: 'B−',
      hospitalName: 'Deenanath Mangeshkar',
      distance: '6.5 km away',
      neededBy: 'Thursday, 9:00 AM',
      urgency: UrgencyLevel.high,
    ),
  ];

  // ── Donation camps data ─────────────────────────────────────────────────
  static final List<DonationCamp> _camps = [
    const DonationCamp(
      name: 'Pune City Blood Drive',
      location: 'Shivaji Nagar',
      openUntil: '8:00 PM',
      iconBgColor: Color(0xFF1565C0),
      icon: Icons.medical_services,
    ),
    const DonationCamp(
      name: 'Saksham Blood Camp',
      location: 'Kothrud',
      openUntil: '7:30 PM',
      iconBgColor: Color(0xFF6A1B9A),
      icon: Icons.local_hospital,
    ),
    const DonationCamp(
      name: 'LifeLink Donor Drive',
      location: 'Baner Road',
      openUntil: '6:00 PM',
      iconBgColor: Color(0xFF00838F),
      icon: Icons.water_drop,
    ),
    const DonationCamp(
      name: 'Rotary Blood Bank',
      location: 'Camp, Pune',
      openUntil: '9:00 PM',
      iconBgColor: Color(0xFFD32F2F),
      icon: Icons.bloodtype,
    ),
    const DonationCamp(
      name: 'Arogya Blood Centre',
      location: 'Hadapsar',
      openUntil: '5:30 PM',
      iconBgColor: Color(0xFF2E7D32),
      icon: Icons.healing,
    ),
  ];

  // ── Respond to request dialog ───────────────────────────────────────────
  void _onRespond(BloodRequest req) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism,
                color: _red,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Respond to ${req.hospitalName}?',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Blood group ${req.bloodGroup} needed by ${req.neededBy}.\nYour contact will be shared with the hospital.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text('Response sent to ${req.hospitalName}!'),
                            ],
                          ),
                          backgroundColor: _red,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.all(16),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Camp detail sheet ───────────────────────────────────────────────────
  void _onViewCampDetails(DonationCamp camp) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
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
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: camp.iconBgColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(camp.icon, color: camp.iconBgColor, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        camp.name,
                        style: const TextStyle(
                          fontSize: 16,
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
                            camp.location,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _detailRow(
              Icons.access_time_filled,
              'Open until ${camp.openUntil}',
              const Color(0xFF2E7D32),
            ),
            _detailRow(Icons.phone, 'Call: +91 98765 43210', _red),
            _detailRow(
              Icons.info_outline,
              'Walk-ins welcome. No appointment needed.',
              const Color(0xFF555555),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Notification bell ───────────────────────────────────────────────────
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
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
            const SizedBox(height: 16),
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _notifItem(
              Icons.warning_amber_rounded,
              _red,
              'CRITICAL: B+ needed at Ruby Hall Clinic',
              '2 min ago',
            ),
            _notifItem(
              Icons.volunteer_activism,
              const Color(0xFF1565C0),
              'Your last donation was 3 months ago. You are eligible!',
              '1 day ago',
            ),
            _notifItem(
              Icons.location_on,
              const Color(0xFF2E7D32),
              'New blood camp at Shivaji Nagar. Open until 8 PM.',
              '3 hrs ago',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _notifItem(IconData icon, Color color, String text, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Build tabs ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'Red',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFD32F2F),
                ),
              ),
              TextSpan(
                text: 'Link',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ),
        actions: [
          GestureDetector(
            onTap: _showNotifications,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF1A1A1A),
                    size: 22,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: _red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<BloodRequestApiModel>>(
        valueListenable: RequestsStore.instance.requests,
        builder: (context, liveRequests, child) {
          // Convert top 5 live requests for the Home tab; fall back to static if empty
          final homeRequests = liveRequests.isNotEmpty
              ? liveRequests.take(5).map((r) => r.toDonorCard()).toList()
              : _requests;
          return IndexedStack(
            index: _currentTab,
            children: [
              _HomeTab(
                donor: widget.donor,
                requests: homeRequests,
                camps: _camps,
                onRespond: _onRespond,
                onViewCamp: _onViewCampDetails,
              ),
              _LiveRequestsTab(donor: widget.donor),
              _PlaceholderTab(
                icon: Icons.history_rounded,
                label: 'Donation History',
                subtitle: 'Your past donations will be tracked here.',
              ),
              _ProfileTab(donor: widget.donor),
            ],
          );
        },
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _red,
          unselectedItemColor: const Color(0xFF9E9E9E),
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.water_drop_outlined),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ── Home tab content ────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final DonorModel donor;
  final List<BloodRequest> requests;
  final List<DonationCamp> camps;
  final void Function(BloodRequest) onRespond;
  final void Function(DonationCamp) onViewCamp;

  const _HomeTab({
    required this.donor,
    required this.requests,
    required this.camps,
    required this.onRespond,
    required this.onViewCamp,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        // ── Greeting ────────────────────────────────────────────────────
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Hello ${donor.firstName} ',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const TextSpan(text: '👋', style: TextStyle(fontSize: 24)),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // ── Blood group card ─────────────────────────────────────────────
        BloodGroupCard(donor: donor),

        const SizedBox(height: 28),

        // ── Nearby blood requests ────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nearby Blood Requests',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'View all',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        ...requests.map(
          (r) => BloodRequestCard(request: r, onRespond: () => onRespond(r)),
        ),

        const SizedBox(height: 12),

        // ── Active Donation Camps ────────────────────────────────────────
        const Text(
          'Active Donation Camps & Hospitals',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 210,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: camps.length,
            itemBuilder: (_, i) => DonationCampCard(
              camp: camps[i],
              onViewDetails: () => onViewCamp(camps[i]),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ── Quick stats row ──────────────────────────────────────────────
        const Text(
          'Your Impact',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _ImpactTile(
              icon: Icons.favorite_rounded,
              value: '3',
              label: 'Lives Saved',
              iconColor: const Color(0xFFD32F2F),
            ),
            const SizedBox(width: 12),
            _ImpactTile(
              icon: Icons.water_drop_rounded,
              value: '3',
              label: 'Times Donated',
              iconColor: const Color(0xFF1565C0),
            ),
            const SizedBox(width: 12),
            _ImpactTile(
              icon: Icons.star_rounded,
              value: '4.9',
              label: 'Donor Score',
              iconColor: const Color(0xFFF57C00),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Health tips ──────────────────────────────────────────────────
        const Text(
          'Tips Before Donating',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        _TipCard(
          icon: Icons.local_drink_outlined,
          color: const Color(0xFF1565C0),
          title: 'Stay Hydrated',
          subtitle: 'Drink at least 16 oz of water before donating.',
        ),
        _TipCard(
          icon: Icons.restaurant_menu_rounded,
          color: const Color(0xFF2E7D32),
          title: 'Eat Iron-Rich Foods',
          subtitle: 'Spinach, red meat, and beans boost your iron level.',
        ),
        _TipCard(
          icon: Icons.bedtime_rounded,
          color: const Color(0xFF6A1B9A),
          title: 'Get Enough Sleep',
          subtitle: 'Rest at least 8 hours before your donation day.',
        ),

        const SizedBox(height: 20),
      ],
    );
  }
}

class _ImpactTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  const _ImpactTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _TipCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Placeholder tabs ────────────────────────────────────────────────────────
class _PlaceholderTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _PlaceholderTab({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 36, color: const Color(0xFFD32F2F)),
            ),
            const SizedBox(height: 20),
            Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 14, color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile tab ─────────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final DonorModel donor;
  static const _red = Color(0xFFD32F2F);

  const _ProfileTab({required this.donor});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        // Avatar + name
        Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 42,
                backgroundColor: const Color(0xFFFDE8E8),
                child: Text(
                  donor.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: _red,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                donor.fullName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  donor.bloodGroup,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _red,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        // Info cards
        _profileRow(Icons.phone, 'Phone', '+91 ${donor.phone}'),
        _profileRow(Icons.location_city, 'City', donor.city),
        _profileRow(
          Icons.monitor_weight_outlined,
          'Weight',
          '${donor.weight} kg',
        ),
        _profileRow(
          Icons.calendar_today,
          'Last Donation',
          donor.formattedLastDonation,
        ),
        _profileRow(
          Icons.emergency,
          'Emergency Donor',
          donor.isEmergencyDonor ? 'Yes — Available for SOS' : 'No',
          valueColor: donor.isEmergencyDonor
              ? const Color(0xFF2E7D32)
              : const Color(0xFF888888),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _profileRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: _red),
          const SizedBox(width: 14),
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: valueColor ?? const Color(0xFF1A1A1A),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Blood Requests tab ──────────────────────────────────────────────────
// Shows all active requests from the backend with blood-group filter chips.
class _LiveRequestsTab extends StatefulWidget {
  final DonorModel donor;
  const _LiveRequestsTab({required this.donor});

  @override
  State<_LiveRequestsTab> createState() => _LiveRequestsTabState();
}

class _LiveRequestsTabState extends State<_LiveRequestsTab> {
  static const _red = Color(0xFFD32F2F);
  static const _bloodGroups = [
    'All',
    'A+',
    'A\u2212',
    'B+',
    'B\u2212',
    'AB+',
    'AB\u2212',
    'O+',
    'O\u2212',
  ];
  String _selectedGroup = 'All';

  List<BloodRequestApiModel> _filtered(List<BloodRequestApiModel> all) {
    if (_selectedGroup == 'All') return all;
    final sel = _selectedGroup.replaceAll('\u2212', '-');
    return all
        .where((r) => r.bloodGroup.replaceAll('\u2212', '-') == sel)
        .toList();
  }

  Future<void> _respondTo(BloodRequestApiModel req) async {
    Navigator.pop(context);
    try {
      await ApiService.respondToRequest(req.id);
      await RequestsStore.instance.refresh();
    } catch (_) {
      // best-effort
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text('Response sent to ${req.hospitalName}!'),
          ],
        ),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showRespondDialog(BloodRequestApiModel req) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDDDDD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: Color(0xFFFDE8E8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism,
                color: _red,
                size: 30,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Respond to ${req.hospitalName}?',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${req.bloodGroup} needed \u00b7 ${req.unitsRequired} unit(s) \u00b7 ${req.neededIn}.\n'
              'Your contact will be shared with the hospital.',
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF888888),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _respondTo(req),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.w700),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Filter chips ──────────────────────────────────────────────
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _bloodGroups.map((g) {
                final selected = _selectedGroup == g;
                return GestureDetector(
                  onTap: () => setState(() => _selectedGroup = g),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? const Color(0xFFFDE8E8)
                          : const Color(0xFFF2F2F2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected ? _red : Colors.transparent,
                        width: 1.4,
                      ),
                    ),
                    child: Text(
                      g,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: selected ? _red : const Color(0xFF666666),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── Live list ─────────────────────────────────────────────────
        Expanded(
          child: ValueListenableBuilder<List<BloodRequestApiModel>>(
            valueListenable: RequestsStore.instance.requests,
            builder: (context, allRequests, child) {
              final filtered = _filtered(allRequests);

              return ValueListenableBuilder<bool>(
                valueListenable: RequestsStore.instance.loading,
                builder: (context, isLoading, child) {
                  if (isLoading && allRequests.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: _red,
                        strokeWidth: 2,
                      ),
                    );
                  }

                  if (filtered.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFDE8E8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.water_drop_outlined,
                                size: 32,
                                color: _red,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _selectedGroup == 'All'
                                  ? 'No active requests right now'
                                  : 'No $_selectedGroup requests right now',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Pull to refresh or check back soon.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF888888),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: _red,
                    onRefresh: RequestsStore.instance.refresh,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final req = filtered[index];
                        return BloodRequestCard(
                          request: req.toDonorCard(),
                          onRespond: () => _showRespondDialog(req),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
