import 'package:flutter/material.dart';
import '../models/blood_bank_model.dart';
import 'sos_request_details_screen.dart';
import 'ambulance_tracking_screen.dart';

class BloodBankDashboardScreen extends StatefulWidget {
  final BloodBankModel bank;
  const BloodBankDashboardScreen({super.key, required this.bank});

  @override
  State<BloodBankDashboardScreen> createState() =>
      _BloodBankDashboardScreenState();
}

class _BloodBankDashboardScreenState extends State<BloodBankDashboardScreen> {
  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFF7F7F7);

  int _tab = 2; // start on Inventory tab (matches reference)

  // Mutable inventory copy
  late Map<String, int> _inventory;

  // SOS requests
  late List<BloodBankSosRequest> _sosRequests;

  @override
  void initState() {
    super.initState();
    _inventory = Map<String, int>.from(widget.bank.inventory);
    _sosRequests = [
      BloodBankSosRequest(
        id: 'sos_001',
        hospitalName: 'Ruby Hall Clinic',
        location: 'Shivajinagar, Pune',
        bloodGroup: 'O−',
        unitsNeeded: 3,
        neededIn: '30 min',
        distance: '2.4 km',
        message:
            'Critical patient in ICU post-surgery. O-negative urgently required for transfusion.',
        lat: 18.5314,
        lng: 73.8446,
        urgency: SosUrgency.critical,
      ),
      BloodBankSosRequest(
        id: 'sos_002',
        hospitalName: 'Sassoon General Hospital',
        location: 'Camp, Pune',
        bloodGroup: 'A−',
        unitsNeeded: 2,
        neededIn: '1 hr',
        distance: '3.8 km',
        message:
            'Emergency surgery case. Need blood urgently. Please reach out if you can help.',
        lat: 18.5167,
        lng: 73.8567,
        urgency: SosUrgency.high,
      ),
      BloodBankSosRequest(
        id: 'sos_003',
        hospitalName: 'KEM Hospital',
        location: 'Rasta Peth, Pune',
        bloodGroup: 'B+',
        unitsNeeded: 5,
        neededIn: '2 hrs',
        distance: '5.1 km',
        message:
            'Accident victim in emergency ward. B+ blood required for immediate transfusion.',
        lat: 18.5308,
        lng: 73.8631,
        urgency: SosUrgency.normal,
      ),
    ];
  }

  // ── Status helpers ────────────────────────────────────────────────────────
  _StockStatus _statusOf(int units) {
    if (units <= 5) return _StockStatus.critical;
    if (units <= 30) return _StockStatus.low;
    return _StockStatus.good;
  }

  int get _criticalCount => _inventory.values
      .where((v) => _statusOf(v) == _StockStatus.critical)
      .length;

  int get _sosActive =>
      _sosRequests.where((s) => !s.isResponded && !s.isRejected).length;

  // ── Update inventory dialog ───────────────────────────────────────────────
  void _showUpdateDialog(String bloodGroup, int current) {
    final ctrl = TextEditingController(text: current.toString());
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                bloodGroup,
                style: const TextStyle(
                  color: _red,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Update Units',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Available units',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _red, width: 1.6),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF888888)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            onPressed: () {
              final val = int.tryParse(ctrl.text.trim());
              if (val != null && val >= 0) {
                setState(() => _inventory[bloodGroup] = val);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // ── Open SOS request details screen ─────────────────────────────────────
  void _openSosDetails(BloodBankSosRequest req) {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => SosRequestDetailsScreen(
              req: req,
              onAccept: () {
                setState(() {
                  req.isResponded = true;
                  final cur = _inventory[req.bloodGroup] ?? 0;
                  _inventory[req.bloodGroup] = (cur - req.unitsNeeded).clamp(
                    0,
                    9999,
                  );
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Dispatched ${req.unitsNeeded} units of ${req.bloodGroup} to ${req.hospitalName}',
                    ),
                    backgroundColor: const Color(0xFF2E7D32),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              },
              onDecline: () => setState(() => req.isRejected = true),
            ),
          ),
        )
        .then((_) {
          // After the details screen pops, open the ambulance tracker if accepted
          if (req.isResponded && mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AmbulanceTrackingScreen(
                  req: req,
                  bankLat: widget.bank.lat,
                  bankLng: widget.bank.lng,
                  bankName: widget.bank.name,
                ),
              ),
            );
          }
        });
  }

  void _rejectSos(BloodBankSosRequest req) =>
      setState(() => req.isRejected = true);

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
          'RedLink Dashboard',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF1A1A1A),
                ),
                onPressed: () {},
              ),
              if (_sosActive > 0)
                Positioned(
                  top: 10,
                  right: 10,
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
        ],
      ),
      body: IndexedStack(
        index: _tab,
        children: [
          _HomeTab(
            bank: widget.bank,
            inventory: _inventory,
            sosRequests: _sosRequests,
            criticalCount: _criticalCount,
            sosActive: _sosActive,
            onUpdateInventory: () => setState(() => _tab = 2),
            onRespondSos: () => setState(() => _tab = 1),
          ),
          _SosTab(
            sosRequests: _sosRequests,
            onRespond: _openSosDetails,
            onReject: _rejectSos,
          ),
          _InventoryTab(
            bank: widget.bank,
            inventory: _inventory,
            statusOf: _statusOf,
            onUpdate: _showUpdateDialog,
          ),
          _ProfileTab(bank: widget.bank),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  selected: _tab == 0,
                  onTap: () => setState(() => _tab = 0),
                ),
                _NavItem(
                  icon: Icons.emergency_rounded,
                  label: 'SOS',
                  selected: _tab == 1,
                  badge: _sosActive,
                  onTap: () => setState(() => _tab = 1),
                ),
                _NavItem(
                  icon: Icons.inventory_2_rounded,
                  label: 'Inventory',
                  selected: _tab == 2,
                  highlighted: true,
                  onTap: () => setState(() => _tab = 2),
                ),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  selected: _tab == 3,
                  onTap: () => setState(() => _tab = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Home Tab ──────────────────────────────────────────────────────────────
class _HomeTab extends StatelessWidget {
  final BloodBankModel bank;
  final Map<String, int> inventory;
  final List<BloodBankSosRequest> sosRequests;
  final int criticalCount;
  final int sosActive;
  final VoidCallback onUpdateInventory;
  final VoidCallback onRespondSos;

  static const _red = Color(0xFFD32F2F);

  const _HomeTab({
    required this.bank,
    required this.inventory,
    required this.sosRequests,
    required this.criticalCount,
    required this.sosActive,
    required this.onUpdateInventory,
    required this.onRespondSos,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        // ── Quick action buttons ──────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: _QuickActionBtn(
                label: 'Update Invent...',
                icon: Icons.edit_rounded,
                filled: true,
                onTap: onUpdateInventory,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionBtn(
                label: 'Respond to SOS',
                icon: Icons.emergency_rounded,
                filled: false,
                onTap: onRespondSos,
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // ── Inventory overview header ─────────────────────────────────
        Row(
          children: [
            const Expanded(
              child: Text(
                'Inventory Overview',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            Text(
              bank.name,
              style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // ── Blood group grid (2 columns) ──────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.2,
          children: inventory.entries.map((e) {
            final units = e.value;
            final status = units <= 5
                ? _StockStatus.critical
                : units <= 30
                ? _StockStatus.low
                : _StockStatus.good;
            return _InventoryCard(
              bloodGroup: e.key,
              units: units,
              status: status,
              onTap: null,
            );
          }).toList(),
        ),

        const SizedBox(height: 28),

        // ── Stats row ─────────────────────────────────────────────────
        Row(
          children: [
            _StatChip(
              label: 'Critical',
              value: criticalCount.toString(),
              color: _red,
              icon: Icons.error_rounded,
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: 'SOS Active',
              value: sosActive.toString(),
              color: const Color(0xFFF57C00),
              icon: Icons.emergency_rounded,
            ),
            const SizedBox(width: 10),
            _StatChip(
              label: 'Total Groups',
              value: inventory.length.toString(),
              color: const Color(0xFF1565C0),
              icon: Icons.water_drop_rounded,
            ),
          ],
        ),
      ],
    );
  }
}

// ── SOS Tab ───────────────────────────────────────────────────────────────
class _SosTab extends StatelessWidget {
  final List<BloodBankSosRequest> sosRequests;
  final void Function(BloodBankSosRequest) onRespond;
  final void Function(BloodBankSosRequest) onReject;

  const _SosTab({
    required this.sosRequests,
    required this.onRespond,
    required this.onReject,
  });

  static const _red = Color(0xFFD32F2F);

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
    final active = sosRequests
        .where((s) => !s.isResponded && !s.isRejected)
        .toList();
    final dispatched = sosRequests.where((s) => s.isResponded).toList();
    final rejected = sosRequests.where((s) => s.isRejected).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'SOS Requests',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            if (active.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${active.length} Active',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: _red,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (active.isEmpty && dispatched.isEmpty && rejected.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 60),
              child: Text(
                'No SOS requests at this time.',
                style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
              ),
            ),
          )
        else ...[
          if (active.isNotEmpty)
            ...active.map(
              (req) => _SosCard(
                req: req,
                urgencyColor: _urgencyColor(req.urgency),
                urgencyLabel: _urgencyLabel(req.urgency),
                onRespond: () => onRespond(req),
                onReject: () => onReject(req),
              ),
            ),
          if (dispatched.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Dispatched',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 10),
            ...dispatched.map(
              (req) => Opacity(
                opacity: 0.55,
                child: _SosCard(
                  req: req,
                  urgencyColor: const Color(0xFF2E7D32),
                  urgencyLabel: 'DISPATCHED',
                  onRespond: null,
                  onReject: null,
                ),
              ),
            ),
          ],
          if (rejected.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Rejected',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9E9E9E),
              ),
            ),
            const SizedBox(height: 10),
            ...rejected.map(
              (req) => Opacity(
                opacity: 0.45,
                child: _SosCard(
                  req: req,
                  urgencyColor: const Color(0xFF9E9E9E),
                  urgencyLabel: 'REJECTED',
                  onRespond: null,
                  onReject: null,
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }
}

// ── Inventory Tab ─────────────────────────────────────────────────────────
class _InventoryTab extends StatelessWidget {
  final BloodBankModel bank;
  final Map<String, int> inventory;
  final _StockStatus Function(int) statusOf;
  final void Function(String, int) onUpdate;

  static const _red = Color(0xFFD32F2F);

  const _InventoryTab({
    required this.bank,
    required this.inventory,
    required this.statusOf,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    bank.name,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                // Show update dialog for first critical group, or A+
                final first = inventory.entries.first;
                onUpdate(first.key, first.value);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: _red,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text(
                      'Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.2,
          children: inventory.entries.map((e) {
            final status = statusOf(e.value);
            return _InventoryCard(
              bloodGroup: e.key,
              units: e.value,
              status: status,
              onTap: () => onUpdate(e.key, e.value),
            );
          }).toList(),
        ),

        const SizedBox(height: 20),

        // ── Legend ────────────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Stock Level Guide',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const SizedBox(height: 10),
              _LegendRow(
                color: const Color(0xFF2E7D32),
                icon: Icons.check_circle_rounded,
                label: 'Good  (> 30 units)',
              ),
              const SizedBox(height: 6),
              _LegendRow(
                color: const Color(0xFFF57C00),
                icon: Icons.warning_rounded,
                label: 'Low  (6 – 30 units)',
              ),
              const SizedBox(height: 6),
              _LegendRow(
                color: _red,
                icon: Icons.error_rounded,
                label: 'Critical  (≤ 5 units)',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Profile Tab ───────────────────────────────────────────────────────────
class _ProfileTab extends StatelessWidget {
  final BloodBankModel bank;
  static const _red = Color(0xFFD32F2F);

  const _ProfileTab({required this.bank});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
      children: [
        Center(
          child: Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: Color(0xFFFDE8E8),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                bank.logoInitials,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _red,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Center(
          child: Text(
            bank.name,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
        Center(
          child: Text(
            '${bank.city}, ${bank.state}',
            style: const TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
        ),
        const SizedBox(height: 28),
        _InfoTile(
          icon: Icons.water_drop_rounded,
          label: 'Type',
          value: 'Blood Bank',
        ),
        _InfoTile(
          icon: Icons.location_city_rounded,
          label: 'City',
          value: bank.city,
        ),
        _InfoTile(icon: Icons.map_rounded, label: 'State', value: bank.state),
        _InfoTile(
          icon: Icons.verified_rounded,
          label: 'License',
          value: 'BB-MH-${bank.logoInitials}-2024',
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.logout_rounded, size: 18, color: _red),
          label: const Text(
            'Sign Out',
            style: TextStyle(color: _red, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: _red, width: 1.4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ════════════════── Shared small widgets ══════════════════════════════════

enum _StockStatus { good, low, critical }

class _InventoryCard extends StatelessWidget {
  final String bloodGroup;
  final int units;
  final _StockStatus status;
  final VoidCallback? onTap;

  static const _red = Color(0xFFD32F2F);

  const _InventoryCard({
    required this.bloodGroup,
    required this.units,
    required this.status,
    required this.onTap,
  });

  Color get _bgCircle => status == _StockStatus.good
      ? const Color(0xFFE8F5E9)
      : status == _StockStatus.low
      ? const Color(0xFFFFF3E0)
      : const Color(0xFFFDE8E8);

  Color get _iconColor => status == _StockStatus.good
      ? const Color(0xFF2E7D32)
      : status == _StockStatus.low
      ? const Color(0xFFF57C00)
      : _red;

  IconData get _icon => status == _StockStatus.good
      ? Icons.check_circle_rounded
      : status == _StockStatus.low
      ? Icons.warning_rounded
      : Icons.error_rounded;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background circle
            Positioned(
              top: -10,
              right: -10,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: _bgCircle,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Status icon
            Positioned(
              top: 0,
              right: 0,
              child: Icon(_icon, color: _iconColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  bloodGroup,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Available Units',
                  style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
                ),
                Text(
                  units.toString(),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: status == _StockStatus.critical
                        ? _red
                        : const Color(0xFF1A1A1A),
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

class _SosCard extends StatelessWidget {
  final BloodBankSosRequest req;
  final Color urgencyColor;
  final String urgencyLabel;
  final VoidCallback? onRespond;
  final VoidCallback? onReject;

  static const _red = Color(0xFFD32F2F);

  const _SosCard({
    required this.req,
    required this.urgencyColor,
    required this.urgencyLabel,
    required this.onRespond,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: urgencyColor.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  req.bloodGroup,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _red,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  req.hospitalName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: urgencyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: urgencyColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  urgencyLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: urgencyColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.water_drop_outlined, size: 13, color: urgencyColor),
              const SizedBox(width: 4),
              Text(
                '${req.unitsNeeded} units needed',
                style: const TextStyle(fontSize: 12, color: Color(0xFF444444)),
              ),
              const SizedBox(width: 14),
              const Icon(
                Icons.schedule_rounded,
                size: 13,
                color: Color(0xFFAAAAAA),
              ),
              const SizedBox(width: 4),
              Text(
                'Within ${req.neededIn}',
                style: const TextStyle(fontSize: 12, color: Color(0xFF888888)),
              ),
            ],
          ),
          if (onRespond != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                // Reject
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFFDDDDDD),
                        width: 1.4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Respond & Dispatch
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: onRespond,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: urgencyColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text(
                      'Respond & Dispatch',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  static const _red = Color(0xFFD32F2F);

  const _QuickActionBtn({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: filled ? _red : const Color(0xFFFDE8E8),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? Colors.white : _red, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: filled ? Colors.white : _red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Color(0xFF888888)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool highlighted;
  final int badge;
  final VoidCallback onTap;

  static const _red = Color(0xFFD32F2F);

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.highlighted = false,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    if (highlighted) {
      // Centre pill (Inventory)
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: selected ? _red : const Color(0xFFFDE8E8),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: selected ? Colors.white : _red, size: 28),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  icon,
                  color: selected ? _red : const Color(0xFF9E9E9E),
                  size: 24,
                ),
                if (badge > 0)
                  Positioned(
                    top: 0,
                    right: 0,
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
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: selected ? _red : const Color(0xFF9E9E9E),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  static const _red = Color(0xFFD32F2F);

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: _red, size: 18),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendRow extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;

  const _LegendRow({
    required this.color,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF444444)),
        ),
      ],
    );
  }
}
