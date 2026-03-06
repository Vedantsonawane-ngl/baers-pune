import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/donor_model.dart';
import '../widgets/labeled_field.dart';
import 'donor_dashboard_screen.dart';

class DonorRegistrationScreen extends StatefulWidget {
  final String prefillName;
  final String prefillEmail;
  final String? googlePhotoUrl;

  const DonorRegistrationScreen({
    super.key,
    this.prefillName = '',
    this.prefillEmail = '',
    this.googlePhotoUrl,
  });

  @override
  State<DonorRegistrationScreen> createState() =>
      _DonorRegistrationScreenState();
}

class _DonorRegistrationScreenState extends State<DonorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController(text: 'Pune');
  final _weightController = TextEditingController();

  String? _selectedBloodGroup;
  DateTime? _lastDonationDate;
  bool _isEmergencyDonor = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.prefillName);
  }

  static const _bloodGroups = [
    'A+',
    'A−',
    'B+',
    'B−',
    'AB+',
    'AB−',
    'O+',
    'O−',
  ];

  static const _red = Color(0xFFD32F2F);
  static const _borderColor = Color(0xFFE8AAAA);
  static const _hintColor = Color(0xFFBBBBBB);
  static const _labelColor = Color(0xFF1A1A1A);

  InputDecoration _inputDecoration({
    String? hint,
    Widget? suffix,
    Widget? prefix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: _hintColor, fontSize: 15),
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: _borderColor, width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: _red, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: _red, width: 1.4),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(color: _red, width: 1.6),
      ),
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDonationDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(
          context,
        ).copyWith(colorScheme: const ColorScheme.light(primary: _red)),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _lastDonationDate = picked);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final donor = DonorModel(
        fullName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        bloodGroup: _selectedBloodGroup!,
        city: _cityController.text.trim(),
        weight: double.parse(_weightController.text.trim()),
        lastDonationDate: _lastDonationDate,
        isEmergencyDonor: _isEmergencyDonor,
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => DonorDashboardScreen(donor: donor)),
      );
    }
  }

  List<Widget> _buildGoogleAccountBanner() {
    return [
      Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4285F4).withValues(alpha: 0.08),
              const Color(0xFF34A853).withValues(alpha: 0.06),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF4285F4).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFFFDE8E8),
              backgroundImage: widget.googlePhotoUrl != null
                  ? NetworkImage(widget.googlePhotoUrl!)
                  : null,
              child: widget.googlePhotoUrl == null
                  ? Text(
                      widget.prefillName.isNotEmpty
                          ? widget.prefillName[0].toUpperCase()
                          : 'G',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _red,
                        fontSize: 17,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Signed in with Google',
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4285F4),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.prefillName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  Text(
                    widget.prefillEmail,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.verified_rounded,
              color: Color(0xFF4285F4),
              size: 20,
            ),
          ],
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _labelColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Donor Registration',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _labelColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          children: [
            // ── Google account banner (shown when signed in via Google) ─
            if (widget.prefillEmail.isNotEmpty) ..._buildGoogleAccountBanner(),

            // ── Full Name ──────────────────────────────────────────────
            LabeledField(
              label: 'Full Name',
              child: TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: _inputDecoration(hint: 'Enter your full name'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              ),
            ),

            // ── Phone Number ───────────────────────────────────────────
            LabeledField(
              label: 'Phone Number',
              child: TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration(hint: '').copyWith(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 18, right: 6),
                    child: Align(
                      widthFactor: 1,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '+91',
                        style: TextStyle(
                          fontSize: 15,
                          color: _labelColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  hintText: null,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone is required';
                  if (v.length < 10) return 'Enter a valid 10-digit number';
                  return null;
                },
              ),
            ),

            // ── Blood Group ────────────────────────────────────────────
            LabeledField(
              label: 'Blood Group',
              child: DropdownButtonFormField<String>(
                initialValue: _selectedBloodGroup,
                decoration: _inputDecoration(),
                hint: const Text(
                  'Select blood group',
                  style: TextStyle(color: _hintColor, fontSize: 15),
                ),
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: _labelColor,
                  size: 22,
                ),
                borderRadius: BorderRadius.circular(16),
                items: _bloodGroups
                    .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedBloodGroup = v),
                validator: (v) =>
                    v == null ? 'Please select a blood group' : null,
              ),
            ),

            // ── City ───────────────────────────────────────────────────
            LabeledField(
              label: 'City',
              child: TextFormField(
                controller: _cityController,
                decoration: _inputDecoration(),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'City is required' : null,
              ),
            ),

            // ── Weight + Last Donation (side by side) ──────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Weight
                Expanded(
                  child: LabeledField(
                    label: 'Weight (kg)',
                    child: TextFormField(
                      controller: _weightController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d{0,3}(\.\d{0,1})?'),
                        ),
                      ],
                      decoration: _inputDecoration(hint: 'e.g. 65'),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Required';
                        }
                        final w = double.tryParse(v);
                        if (w == null || w < 45) {
                          return 'Min 45 kg';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Last Donation
                Expanded(
                  child: LabeledField(
                    label: 'Last Donation',
                    child: GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: _borderColor, width: 1.4),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _lastDonationDate != null
                                    ? _formatDate(_lastDonationDate!)
                                    : 'mm/dd/yyyy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _lastDonationDate != null
                                      ? _labelColor
                                      : _hintColor,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 18,
                              color: _labelColor,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ── Emergency Donor Toggle ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Emergency Donor',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _labelColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'I am willing to donate blood in\nemergency situations.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isEmergencyDonor,
                    onChanged: (v) => setState(() => _isEmergencyDonor = v),
                    activeThumbColor: Colors.white,
                    activeTrackColor: _red,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFCCCCCC),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ── Register Button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submit,
                icon: const SizedBox.shrink(),
                label: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Register as Donor',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
