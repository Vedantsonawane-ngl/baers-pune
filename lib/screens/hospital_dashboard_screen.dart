import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/hospital_model.dart';
import '../services/api_service.dart';
import '../services/requests_store.dart';
import 'emergency_map_screen.dart';

class HospitalDashboardScreen extends StatefulWidget {
  final HospitalModel hospital;
  const HospitalDashboardScreen({super.key, required this.hospital});

  @override
  State<HospitalDashboardScreen> createState() =>
      _HospitalDashboardScreenState();
}

class _HospitalDashboardScreenState extends State<HospitalDashboardScreen> {
  int _currentTab = 0;

  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFF7F7F7);

  // ── Live mutable request list ─────────────────────────────────────────
  final List<HospitalBloodRequest> _requests = [
    HospitalBloodRequest(
      id: 'req_001',
      bloodGroup: 'O+',
      reason: 'Emergency Operation',
      neededIn: 'Needed in 2 Hours',
      unitsRequired: 3,
      donorsResponding: 4,
      progressPercent: 0.66,
      urgency: HospitalRequestUrgency.emergency,
    ),
    HospitalBloodRequest(
      id: 'req_002',
      bloodGroup: 'B−',
      reason: 'Accident Victim',
      neededIn: 'Needed in 4 Hours',
      unitsRequired: 2,
      donorsResponding: 1,
      progressPercent: 0.20,
      urgency: HospitalRequestUrgency.high,
    ),
    HospitalBloodRequest(
      id: 'req_003',
      bloodGroup: 'A+',
      reason: 'Scheduled Surgery',
      neededIn: 'Needed Tomorrow',
      unitsRequired: 1,
      donorsResponding: 1,
      progressPercent: 0.50,
      urgency: HospitalRequestUrgency.normal,
    ),
  ];

  // ── Donor responses (simulates donors who accepted requests) ─────────
  final List<DonorResponse> _donorResponses = [
    DonorResponse(
      id: 'dr_001',
      donorName: 'Rahul Sharma',
      bloodGroup: 'O+',
      distance: '1.2 km away',
      phone: '+91 98765 43210',
      requestId: 'req_001',
      requestReason: 'Emergency Operation',
    ),
    DonorResponse(
      id: 'dr_002',
      donorName: 'Kavita Rao',
      bloodGroup: 'O+',
      distance: '2.0 km away',
      phone: '+91 91234 56789',
      requestId: 'req_001',
      requestReason: 'Emergency Operation',
    ),
    DonorResponse(
      id: 'dr_003',
      donorName: 'Aditya Patil',
      bloodGroup: 'O+',
      distance: '3.5 km away',
      phone: '+91 70000 11111',
      requestId: 'req_001',
      requestReason: 'Emergency Operation',
    ),
    DonorResponse(
      id: 'dr_004',
      donorName: 'Meera Desai',
      bloodGroup: 'O+',
      distance: '6.2 km away',
      phone: '+91 88888 22222',
      requestId: 'req_001',
      requestReason: 'Emergency Operation',
    ),
    DonorResponse(
      id: 'dr_005',
      donorName: 'Priya Joshi',
      bloodGroup: 'B−',
      distance: '2.8 km away',
      phone: '+91 99999 33333',
      requestId: 'req_002',
      requestReason: 'Accident Victim',
    ),
  ];

  // ── Nearby blood banks ────────────────────────────────────────────────
  static final List<NearbyBloodBank> _bloodBanks = [
    NearbyBloodBank(
      name: 'Jehangir Blood Bank',
      distance: '1.2 km away',
      availableUnits: {'A+': 4, 'B+': 2, 'O+': 6},
    ),
    NearbyBloodBank(
      name: 'Sassoon General',
      distance: '2.5 km away',
      availableUnits: {'A−': 1, 'O−': 3},
    ),
    NearbyBloodBank(
      name: 'KEM Blood Centre',
      distance: '3.8 km away',
      availableUnits: {'B+': 5, 'AB+': 2, 'O+': 4},
    ),
    NearbyBloodBank(
      name: 'Ruby Hall Reserve',
      distance: '0.5 km away',
      availableUnits: {'A+': 3, 'AB−': 1},
    ),
  ];

  // ── Computed stats ────────────────────────────────────────────────────
  int get _activeSOS => _requests
      .where(
        (r) => !r.isCancelled && r.urgency == HospitalRequestUrgency.emergency,
      )
      .length;

  int get _totalDonors => _donorResponses
      .where((d) => d.status != DonorResponseStatus.denied)
      .length;

  int get _unitsPending => _requests
      .where((r) => !r.isCancelled)
      .fold(0, (s, r) => s + r.unitsRequired);

  // ── Cancel request ────────────────────────────────────────────────────
  void _cancelRequest(HospitalBloodRequest req) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Cancel Request',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Cancel the ${req.bloodGroup} request for "${req.reason}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => req.isCancelled = true);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Request cancelled.'),
                  backgroundColor: Colors.grey[700],
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  // ── View request details sheet ─────────────────────────────────────────
  void _viewDetails(HospitalBloodRequest req) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
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
                _bloodGroupBadge(req.bloodGroup, size: 56),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req.reason,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        req.neededIn,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                _urgencyBadge(req.urgency),
              ],
            ),
            const SizedBox(height: 20),
            _detailTile(
              Icons.water_drop_rounded,
              'Units Required',
              '${req.unitsRequired} units',
              _red,
            ),
            _detailTile(
              Icons.people_rounded,
              'Donors Responding',
              '${req.donorsResponding} donors',
              const Color(0xFF1565C0),
            ),
            _detailTile(
              Icons.trending_up_rounded,
              'Fulfillment',
              '${(req.progressPercent * 100).toInt()}%',
              const Color(0xFF2E7D32),
            ),
            _detailTile(
              Icons.local_hospital_rounded,
              'Hospital',
              widget.hospital.name,
              const Color(0xFF6A1B9A),
            ),
            const SizedBox(height: 8),
            // Progress
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: req.progressPercent,
                backgroundColor: const Color(0xFFEEEEEE),
                color: _red,
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _cancelRequest(req);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Cancel Request',
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

  Widget _detailTile(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
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
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  // ── New Emergency Request bottom sheet ────────────────────────────────
  void _newEmergencyRequest() {
    final reasonCtrl = TextEditingController();
    String? selectedGroup;
    int units = 1;
    HospitalRequestUrgency urgency = HospitalRequestUrgency.emergency;

    const bloodGroups = ['A+', 'A−', 'B+', 'B−', 'AB+', 'AB−', 'O+', 'O−'];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
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
                const Text(
                  'New Emergency Blood Request',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 20),
                // Reason
                _sheetLabel('Reason / Diagnosis'),
                TextField(
                  controller: reasonCtrl,
                  decoration: _sheetDecoration(
                    hint: 'e.g. Emergency Operation',
                  ),
                ),
                const SizedBox(height: 16),
                // Blood group
                _sheetLabel('Blood Group Required'),
                DropdownButtonFormField<String>(
                  initialValue: selectedGroup,
                  decoration: _sheetDecoration(hint: ''),
                  hint: const Text(
                    'Select blood group',
                    style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 15),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF1A1A1A),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  items: bloodGroups
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (v) => setSheetState(() => selectedGroup = v),
                ),
                const SizedBox(height: 16),
                // Units
                _sheetLabel('Units Required'),
                Row(
                  children: [
                    _counterBtn(Icons.remove, () {
                      if (units > 1) setSheetState(() => units--);
                    }),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        '$units',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                    _counterBtn(Icons.add, () => setSheetState(() => units++)),
                  ],
                ),
                const SizedBox(height: 16),
                // Urgency
                _sheetLabel('Urgency Level'),
                Row(
                  children: HospitalRequestUrgency.values.map((u) {
                    final selected = urgency == u;
                    final label = u == HospitalRequestUrgency.emergency
                        ? 'Emergency'
                        : u == HospitalRequestUrgency.high
                        ? 'High'
                        : 'Normal';
                    final color = u == HospitalRequestUrgency.emergency
                        ? _red
                        : u == HospitalRequestUrgency.high
                        ? const Color(0xFFF57C00)
                        : const Color(0xFF757575);
                    return GestureDetector(
                      onTap: () => setSheetState(() => urgency = u),
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: selected
                              ? color.withValues(alpha: 0.12)
                              : const Color(0xFFF2F2F2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected ? color : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: selected ? color : const Color(0xFF888888),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (selectedGroup == null ||
                          reasonCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      final urgencyStr =
                          urgency == HospitalRequestUrgency.emergency
                          ? 'emergency'
                          : urgency == HospitalRequestUrgency.high
                          ? 'high'
                          : 'normal';
                      // Capture messenger before the async gap
                      final messenger = ScaffoldMessenger.of(context);

                      // Close sheet immediately for snappy UX
                      Navigator.pop(ctx);

                      try {
                        final created = await ApiService.createRequest(
                          bloodGroup: selectedGroup!,
                          reason: reasonCtrl.text.trim(),
                          urgency: urgencyStr,
                          unitsRequired: units,
                          hospitalName: widget.hospital.name,
                          hospitalCity: widget.hospital.city,
                        );
                        // Optimistic insert so it appears instantly
                        RequestsStore.instance.addOptimistic(created);
                        // Also add to local list for the hospital view
                        setState(
                          () => _requests.insert(
                            0,
                            HospitalBloodRequest(
                              id: 'req_${created.id}',
                              bloodGroup: created.bloodGroup,
                              reason: created.reason,
                              neededIn: created.neededIn,
                              unitsRequired: created.unitsRequired,
                              donorsResponding: 0,
                              progressPercent: 0,
                              urgency: urgency,
                            ),
                          ),
                        );
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Emergency request for ${created.bloodGroup} sent!',
                                  ),
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
                        }
                      } catch (e) {
                        // Fallback: add locally so the demo still works offline
                        setState(
                          () => _requests.insert(
                            0,
                            HospitalBloodRequest(
                              id: 'req_${DateTime.now().millisecondsSinceEpoch}',
                              bloodGroup: selectedGroup!,
                              reason: reasonCtrl.text.trim(),
                              neededIn: 'Needed ASAP',
                              unitsRequired: units,
                              donorsResponding: 0,
                              progressPercent: 0,
                              urgency: urgency,
                            ),
                          ),
                        );
                        if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Request for $selectedGroup added (offline mode).',
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.orange[700],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              margin: const EdgeInsets.all(16),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      'Send Request',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF1A1A1A)),
      ),
    );
  }

  Widget _sheetLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A1A),
      ),
    ),
  );

  InputDecoration _sheetDecoration({String hint = ''}) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 15),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    filled: true,
    fillColor: const Color(0xFFF7F7F7),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: const BorderSide(color: _red, width: 1.6),
    ),
  );

  // ── Notifications ─────────────────────────────────────────────────────
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
            _notifRow(
              Icons.warning_amber_rounded,
              _red,
              'O+ SOS: 4 donors are now responding.',
              '2 min ago',
            ),
            _notifRow(
              Icons.water_drop,
              const Color(0xFF1565C0),
              'Jehangir Blood Bank has 6 units of O+ available.',
              '15 min ago',
            ),
            _notifRow(
              Icons.person_add_rounded,
              const Color(0xFF2E7D32),
              'New donor registered matching B− requirement.',
              '1 hr ago',
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _notifRow(
    IconData icon,
    Color color,
    String msg,
    String time,
  ) => Padding(
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
                msg,
                style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A1A)),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  // ── Helpers ───────────────────────────────────────────────────────────
  Widget _bloodGroupBadge(String group, {double size = 50}) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xFFFDE8E8),
      borderRadius: BorderRadius.circular(size * 0.28),
    ),
    alignment: Alignment.center,
    child: Text(
      group,
      style: TextStyle(
        fontSize: size * 0.28,
        fontWeight: FontWeight.w800,
        color: _red,
      ),
    ),
  );

  Widget _urgencyBadge(HospitalRequestUrgency urgency) {
    final label = urgency == HospitalRequestUrgency.emergency
        ? 'EMERGENCY'
        : urgency == HospitalRequestUrgency.high
        ? 'HIGH'
        : 'NORMAL';
    final color = urgency == HospitalRequestUrgency.emergency
        ? _red
        : urgency == HospitalRequestUrgency.high
        ? const Color(0xFFF57C00)
        : const Color(0xFF757575);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  // ── Blood shortage predictions ─────────────────────────────────────────
  List<BloodShortagePrediction> _predictions = [];
  bool _predictionsLoading = true;
  String? _predictionsError;

  @override
  void initState() {
    super.initState();
    _fetchPredictions();
    RequestsStore.instance.startPolling();
  }

  Future<void> _fetchPredictions() async {
    try {
      final uri = Uri.parse('http://127.0.0.1:8000/api/predict-shortage/');
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final list = (data['predictions'] as List)
            .map(
              (e) =>
                  BloodShortagePrediction.fromJson(e as Map<String, dynamic>),
            )
            .toList();
        if (mounted) {
          setState(() {
            _predictions = list;
            _predictionsLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _predictionsError = 'Server error ${response.statusCode}';
            _predictionsLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _predictionsError = 'Could not reach prediction server';
          _predictionsLoading = false;
        });
      }
    }
  }

  // ── Main build ────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final activeRequests = _requests.where((r) => !r.isCancelled).toList();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            // Hospital avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFFDE8E8),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFFCDD2), width: 2),
              ),
              alignment: Alignment.center,
              child: Text(
                widget.hospital.logoInitials,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: _red,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.hospital.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'STAFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _red,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${widget.hospital.city}, ${widget.hospital.state}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            onTap: _showNotifications,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFF2F2F2),
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
      body: IndexedStack(
        index: _currentTab,
        children: [
          _DashboardTab(
            activeSOS: _activeSOS,
            totalDonors: _totalDonors,
            bloodBanksCount: _bloodBanks.length,
            unitsPending: _unitsPending,
            activeRequests: activeRequests,
            bloodBanks: _bloodBanks,
            onNewRequest: _newEmergencyRequest,
            onCancel: _cancelRequest,
            onViewDetails: _viewDetails,
            bloodGroupBadge: _bloodGroupBadge,
            urgencyBadge: _urgencyBadge,
            predictions: _predictions,
            predictionsLoading: _predictionsLoading,
            predictionsError: _predictionsError,
            onRefreshPredictions: _fetchPredictions,
          ),
          _RequestsTab(
            requests: _requests,
            onCancel: _cancelRequest,
            onViewDetails: _viewDetails,
            bloodGroupBadge: _bloodGroupBadge,
            urgencyBadge: _urgencyBadge,
            onNewRequest: _newEmergencyRequest,
          ),
          _DonorsTab(
            donorResponses: _donorResponses,
            onAccept: (dr) =>
                setState(() => dr.status = DonorResponseStatus.accepted),
            onDeny: (dr) =>
                setState(() => dr.status = DonorResponseStatus.denied),
          ),
          _HospitalProfileTab(hospital: widget.hospital),
        ],
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
              icon: Icon(Icons.dashboard_rounded),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list_alt_rounded),
              label: 'Requests',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.people_rounded),
              label: 'Donors',
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

// ════════════════════════════════════════════════════════════
//  Dashboard Tab
// ════════════════════════════════════════════════════════════
class _DashboardTab extends StatelessWidget {
  final int activeSOS;
  final int totalDonors;
  final int bloodBanksCount;
  final int unitsPending;
  final List<HospitalBloodRequest> activeRequests;
  final List<NearbyBloodBank> bloodBanks;
  final VoidCallback onNewRequest;
  final void Function(HospitalBloodRequest) onCancel;
  final void Function(HospitalBloodRequest) onViewDetails;
  final Widget Function(String, {double size}) bloodGroupBadge;
  final Widget Function(HospitalRequestUrgency) urgencyBadge;
  final List<BloodShortagePrediction> predictions;
  final bool predictionsLoading;
  final String? predictionsError;
  final VoidCallback onRefreshPredictions;

  static const _red = Color(0xFFD32F2F);

  const _DashboardTab({
    required this.activeSOS,
    required this.totalDonors,
    required this.bloodBanksCount,
    required this.unitsPending,
    required this.activeRequests,
    required this.bloodBanks,
    required this.onNewRequest,
    required this.onCancel,
    required this.onViewDetails,
    required this.bloodGroupBadge,
    required this.urgencyBadge,
    required this.predictions,
    required this.predictionsLoading,
    required this.predictionsError,
    required this.onRefreshPredictions,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      children: [
        // ── Stats grid ───────────────────────────────────────────────
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.55,
          children: [
            _StatCard(
              icon: Icons.warning_amber_rounded,
              iconColor: _red,
              value: '$activeSOS',
              label: 'Active SOS',
            ),
            _StatCard(
              icon: Icons.people_rounded,
              iconColor: const Color(0xFF1A1A1A),
              value: '$totalDonors',
              label: 'Donors',
            ),
            _StatCard(
              icon: Icons.local_hospital_rounded,
              iconColor: const Color(0xFF1A1A1A),
              value: '$bloodBanksCount',
              label: 'Blood Banks',
            ),
            _StatCard(
              icon: Icons.water_drop_rounded,
              iconColor: const Color(0xFF1A1A1A),
              value: '$unitsPending',
              label: 'Units Pending',
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── New Emergency Button ─────────────────────────────────────
        GestureDetector(
          onTap: onNewRequest,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE53935), Color(0xFFC62828)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: _red.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text(
                  'New Emergency Blood Request',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // ── Emergency Response Map ─────────────────────────────────────
        GestureDetector(
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const EmergencyMapScreen())),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: _red.withValues(alpha: 0.4),
                width: 1.4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map_rounded, color: _red, size: 20),
                SizedBox(width: 10),
                Text(
                  'Emergency Response Map',
                  style: TextStyle(
                    color: _red,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 28),

        // ── Active Requests ──────────────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Requests',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: const Text(
                'See All',
                style: TextStyle(
                  fontSize: 14,
                  color: _red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        if (activeRequests.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No active requests.',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ),
          )
        else
          ...activeRequests.map(
            (r) => _ActiveRequestCard(
              request: r,
              onCancel: () => onCancel(r),
              onViewDetails: () => onViewDetails(r),
              bloodGroupBadge: bloodGroupBadge,
              urgencyBadge: urgencyBadge,
            ),
          ),

        const SizedBox(height: 12),

        // ── Nearby Blood Banks ───────────────────────────────────────
        const Text(
          'Nearby Blood Banks',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: bloodBanks.length,
            itemBuilder: (_, i) => _BloodBankCard(bank: bloodBanks[i]),
          ),
        ),

        const SizedBox(height: 28),

        // ── Blood Shortage Forecast ──────────────────────────────────
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Blood Shortage Forecast',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            GestureDetector(
              onTap: onRefreshPredictions,
              child: const Icon(Icons.refresh_rounded, size: 20, color: _red),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'ML-powered predictions based on historical Pune data',
          style: TextStyle(fontSize: 12, color: Color(0xFF888888)),
        ),
        const SizedBox(height: 14),

        if (predictionsLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_red),
                strokeWidth: 2.5,
              ),
            ),
          )
        else if (predictionsError != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFFFCDD2), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: _red, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        predictionsError!,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      const Text(
                        'Make sure the Django server is running on port 8000',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ...predictions.map((p) => _ShortageCard(prediction: p)),

        const SizedBox(height: 28),
      ],
    );
  }
}

// ── Stat card ──────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 24),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Active request card ────────────────────────────────────────────────────
class _ActiveRequestCard extends StatelessWidget {
  final HospitalBloodRequest request;
  final VoidCallback onCancel;
  final VoidCallback onViewDetails;
  final Widget Function(String, {double size}) bloodGroupBadge;
  final Widget Function(HospitalRequestUrgency) urgencyBadge;

  static const _red = Color(0xFFD32F2F);

  const _ActiveRequestCard({
    required this.request,
    required this.onCancel,
    required this.onViewDetails,
    required this.bloodGroupBadge,
    required this.urgencyBadge,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (request.progressPercent * 100).toInt();
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
            // Top row
            Row(
              children: [
                bloodGroupBadge(request.bloodGroup),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.reason,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        request.neededIn,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${request.unitsRequired} Units',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _red,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Status + percent
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Status: ${request.donorsResponding} Donor${request.donorsResponding == 1 ? '' : 's'} Responding',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
                Text(
                  '$pct%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: request.progressPercent,
                backgroundColor: const Color(0xFFEEEEEE),
                color: _red,
                minHeight: 7,
              ),
            ),
            const SizedBox(height: 14),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onCancel,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFDDDDDD)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onViewDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDE8E8),
                      foregroundColor: _red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    child: const Text(
                      'View Details',
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
        ),
      ),
    );
  }
}

// ── Blood bank card ────────────────────────────────────────────────────────
class _BloodBankCard extends StatelessWidget {
  final NearbyBloodBank bank;
  static const _red = Color(0xFFD32F2F);

  const _BloodBankCard({required this.bank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  bank.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.directions_rounded, color: _red, size: 18),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Color(0xFFAAAAAA)),
              const SizedBox(width: 2),
              Text(
                bank.distance,
                style: const TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
              ),
            ],
          ),
          const Spacer(),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: bank.availableUnits.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${e.key} (${e.value})',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Requests Tab
// ════════════════════════════════════════════════════════════
class _RequestsTab extends StatelessWidget {
  final List<HospitalBloodRequest> requests;
  final void Function(HospitalBloodRequest) onCancel;
  final void Function(HospitalBloodRequest) onViewDetails;
  final Widget Function(String, {double size}) bloodGroupBadge;
  final Widget Function(HospitalRequestUrgency) urgencyBadge;
  final VoidCallback onNewRequest;

  static const _red = Color(0xFFD32F2F);

  const _RequestsTab({
    required this.requests,
    required this.onCancel,
    required this.onViewDetails,
    required this.bloodGroupBadge,
    required this.urgencyBadge,
    required this.onNewRequest,
  });

  @override
  Widget build(BuildContext context) {
    final active = requests.where((r) => !r.isCancelled).toList();
    final cancelled = requests.where((r) => r.isCancelled).toList();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'All Requests',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        const SizedBox(height: 14),
        if (active.isEmpty && cancelled.isEmpty)
          Center(
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Icon(
                  Icons.inbox_rounded,
                  size: 60,
                  color: Color(0xFFDDDDDD),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No requests yet.',
                  style: TextStyle(color: Color(0xFF888888)),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: onNewRequest,
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'Create Request',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ...active.map(
          (r) => _ActiveRequestCard(
            request: r,
            onCancel: () => onCancel(r),
            onViewDetails: () => onViewDetails(r),
            bloodGroupBadge: bloodGroupBadge,
            urgencyBadge: urgencyBadge,
          ),
        ),
        if (cancelled.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Cancelled',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF888888),
            ),
          ),
          const SizedBox(height: 10),
          ...cancelled.map(
            (r) => _CancelledRequestTile(
              request: r,
              bloodGroupBadge: bloodGroupBadge,
            ),
          ),
        ],
      ],
    );
  }
}

class _CancelledRequestTile extends StatelessWidget {
  final HospitalBloodRequest request;
  final Widget Function(String, {double size}) bloodGroupBadge;

  const _CancelledRequestTile({
    required this.request,
    required this.bloodGroupBadge,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            bloodGroupBadge(request.bloodGroup, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.reason,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  Text(
                    request.neededIn,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
            ),
            const Text(
              'Cancelled',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF888888),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Donors Tab  –  live donor responses with Accept / Deny
// ════════════════════════════════════════════════════════════
class _DonorsTab extends StatelessWidget {
  final List<DonorResponse> donorResponses;
  final void Function(DonorResponse) onAccept;
  final void Function(DonorResponse) onDeny;

  static const _red = Color(0xFFD32F2F);
  static const _green = Color(0xFF2E7D32);

  const _DonorsTab({
    required this.donorResponses,
    required this.onAccept,
    required this.onDeny,
  });

  // Group responses by request
  Map<String, List<DonorResponse>> get _grouped {
    final map = <String, List<DonorResponse>>{};
    for (final dr in donorResponses) {
      map.putIfAbsent(dr.requestReason, () => []).add(dr);
    }
    return map;
  }

  int get _pendingCount => donorResponses
      .where((d) => d.status == DonorResponseStatus.pending)
      .length;

  int get _acceptedCount => donorResponses
      .where((d) => d.status == DonorResponseStatus.accepted)
      .length;

  Color _statusColor(DonorResponseStatus s) => s == DonorResponseStatus.accepted
      ? _green
      : s == DonorResponseStatus.denied
      ? const Color(0xFF9E9E9E)
      : const Color(0xFFF57C00);

  String _statusLabel(DonorResponseStatus s) =>
      s == DonorResponseStatus.accepted
      ? 'Accepted'
      : s == DonorResponseStatus.denied
      ? 'Denied'
      : 'Pending';

  IconData _statusIcon(DonorResponseStatus s) =>
      s == DonorResponseStatus.accepted
      ? Icons.check_circle_rounded
      : s == DonorResponseStatus.denied
      ? Icons.cancel_rounded
      : Icons.hourglass_top_rounded;

  @override
  Widget build(BuildContext context) {
    final grouped = _grouped;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        // ── Summary row ────────────────────────────────────────────
        Row(
          children: [
            _SummaryChip(
              label: '${donorResponses.length} Responded',
              icon: Icons.people_rounded,
              color: const Color(0xFF1565C0),
            ),
            const SizedBox(width: 10),
            _SummaryChip(
              label: '$_pendingCount Pending',
              icon: Icons.hourglass_top_rounded,
              color: const Color(0xFFF57C00),
            ),
            const SizedBox(width: 10),
            _SummaryChip(
              label: '$_acceptedCount Accepted',
              icon: Icons.check_circle_rounded,
              color: _green,
            ),
          ],
        ),

        const SizedBox(height: 24),

        if (donorResponses.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 60),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF2F2F2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.volunteer_activism_rounded,
                      size: 36,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No donor responses yet.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF888888)),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Donors who accept your requests will appear here.',
                    style: TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        else
          // Render each request group
          ...grouped.entries.map((entry) {
            final requestName = entry.key;
            final responses = entry.value;
            final pending = responses
                .where((r) => r.status == DonorResponseStatus.pending)
                .toList();
            final decided = responses
                .where((r) => r.status != DonorResponseStatus.pending)
                .toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Section header ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            requestName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          Text(
                            '${responses[0].bloodGroup} • ${responses.length} donor${responses.length == 1 ? '' : 's'} responded',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFAAAAAA),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                        responses[0].bloodGroup,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _red,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Pending donors (show accept/deny) ───────────────
                if (pending.isNotEmpty) ...[
                  _groupLabel('Awaiting Decision', const Color(0xFFF57C00)),
                  const SizedBox(height: 8),
                  ...pending.map(
                    (dr) => _DonorResponseCard(
                      donor: dr,
                      onAccept: () => onAccept(dr),
                      onDeny: () => onDeny(dr),
                      statusColor: _statusColor(dr.status),
                      statusLabel: _statusLabel(dr.status),
                      statusIcon: _statusIcon(dr.status),
                      showActions: true,
                    ),
                  ),
                ],

                // ── Decided donors ──────────────────────────────────
                if (decided.isNotEmpty) ...[
                  if (pending.isNotEmpty) const SizedBox(height: 4),
                  _groupLabel('Decided', const Color(0xFF888888)),
                  const SizedBox(height: 8),
                  ...decided.map(
                    (dr) => _DonorResponseCard(
                      donor: dr,
                      onAccept: () => onAccept(dr),
                      onDeny: () => onDeny(dr),
                      statusColor: _statusColor(dr.status),
                      statusLabel: _statusLabel(dr.status),
                      statusIcon: _statusIcon(dr.status),
                      showActions: false,
                    ),
                  ),
                ],

                const SizedBox(height: 20),
                Divider(color: Colors.grey[200], thickness: 1),
                const SizedBox(height: 16),
              ],
            );
          }),
      ],
    );
  }

  Widget _groupLabel(String label, Color color) => Row(
    children: [
      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    ],
  );
}

// ── Summary chip ───────────────────────────────────────────────────────────
class _SummaryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
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
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Single donor response card ─────────────────────────────────────────────
class _DonorResponseCard extends StatelessWidget {
  final DonorResponse donor;
  final VoidCallback onAccept;
  final VoidCallback onDeny;
  final Color statusColor;
  final String statusLabel;
  final IconData statusIcon;
  final bool showActions;

  static const _red = Color(0xFFD32F2F);
  static const _green = Color(0xFF2E7D32);

  const _DonorResponseCard({
    required this.donor,
    required this.onAccept,
    required this.onDeny,
    required this.statusColor,
    required this.statusLabel,
    required this.statusIcon,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context) {
    final isDenied = donor.status == DonorResponseStatus.denied;

    return Opacity(
      opacity: isDenied ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top row: avatar | name + info | status badge ──────
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFFFDE8E8),
                    child: Text(
                      donor.donorName[0].toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _red,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + distance + phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          donor.donorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 12,
                              color: Color(0xFFAAAAAA),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              donor.distance,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFAAAAAA),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.phone,
                              size: 12,
                              color: Color(0xFFAAAAAA),
                            ),
                            const SizedBox(width: 2),
                            Text(
                              donor.phone,
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
                  // Blood group
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      donor.bloodGroup,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: _red,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ── Status pill ───────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, size: 13, color: statusColor),
                        const SizedBox(width: 4),
                        Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ── Action buttons (only for pending) ─────────────────
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Deny
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDeny,
                        icon: const Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: Color(0xFF9E9E9E),
                        ),
                        label: const Text(
                          'Deny',
                          style: TextStyle(
                            color: Color(0xFF666666),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFDDDDDD)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Accept
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onAccept,
                        icon: const Icon(
                          Icons.check_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        label: const Text(
                          'Accept',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════
//  Profile Tab
// ════════════════════════════════════════════════════════════
class _HospitalProfileTab extends StatelessWidget {
  final HospitalModel hospital;
  static const _red = Color(0xFFD32F2F);

  const _HospitalProfileTab({required this.hospital});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFCDD2), width: 3),
                ),
                alignment: Alignment.center,
                child: Text(
                  hospital.logoInitials,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _red,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                hospital.name,
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
                child: const Text(
                  'HOSPITAL STAFF',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: _red,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 28),
        _profileRow(Icons.location_city_rounded, 'City', hospital.city),
        _profileRow(Icons.map_rounded, 'State', hospital.state),
        _profileRow(Icons.phone_rounded, 'Contact', '+91 20 2612 3000'),
        _profileRow(Icons.email_rounded, 'Email', 'staff@rubyhall.com'),
        _profileRow(
          Icons.verified_rounded,
          'Status',
          'Verified Hospital',
          valueColor: const Color(0xFF2E7D32),
        ),
        const SizedBox(height: 20),
        OutlinedButton.icon(
          onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
          icon: const Icon(Icons.logout_rounded, color: _red, size: 18),
          label: const Text(
            'Sign Out',
            style: TextStyle(color: _red, fontWeight: FontWeight.w600),
          ),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFFFCDD2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
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

// ── Blood Shortage Prediction Card ────────────────────────────────────────
class _ShortageCard extends StatelessWidget {
  final BloodShortagePrediction prediction;

  static const _red = Color(0xFFD32F2F);

  const _ShortageCard({required this.prediction});

  Color get _riskColor {
    switch (prediction.shortageRisk) {
      case 'HIGH':
        return _red;
      case 'MEDIUM':
        return const Color(0xFFF57C00);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get _riskIcon {
    switch (prediction.shortageRisk) {
      case 'HIGH':
        return Icons.warning_amber_rounded;
      case 'MEDIUM':
        return Icons.info_outline_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor;
    final fillPct =
        (prediction.predictedDemand /
                (prediction.predictedAvailable == 0
                    ? 1
                    : prediction.predictedAvailable))
            .clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withValues(alpha: 0.2), width: 1),
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
              // Blood group badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  prediction.bloodGroup,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: _red,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Demand: ${prediction.predictedDemand.toStringAsFixed(1)} units',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Available: ${prediction.predictedAvailable.toStringAsFixed(1)} units',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF888888),
                      ),
                    ),
                  ],
                ),
              ),
              // Risk badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: riskColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_riskIcon, size: 13, color: riskColor),
                    const SizedBox(width: 4),
                    Text(
                      prediction.shortageRisk,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: riskColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Demand vs available bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fillPct,
              minHeight: 6,
              backgroundColor: const Color(0xFFF0F0F0),
              valueColor: AlwaysStoppedAnimation<Color>(riskColor),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Shortage probability: ${prediction.shortageProbability.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
              ),
              Text(
                '${(fillPct * 100).toStringAsFixed(0)}% demand/supply ratio',
                style: const TextStyle(fontSize: 11, color: Color(0xFF888888)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
