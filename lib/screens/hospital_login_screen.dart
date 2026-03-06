import 'package:flutter/material.dart';
import '../models/hospital_model.dart';
import 'hospital_dashboard_screen.dart';

class HospitalLoginScreen extends StatefulWidget {
  const HospitalLoginScreen({super.key});

  @override
  State<HospitalLoginScreen> createState() => _HospitalLoginScreenState();
}

class _HospitalLoginScreenState extends State<HospitalLoginScreen> {
  static const _red = Color(0xFFD32F2F);
  static const _borderColor = Color(0xFFE8AAAA);
  static const _hintColor = Color(0xFFBBBBBB);

  final _formKey = GlobalKey<FormState>();
  final _hospitalCtrl = TextEditingController(text: 'Ruby Hall Clinic');
  final _codeCtrl = TextEditingController();
  bool _obscure = true;

  // Preset hospitals for the demo dropdown
  static const _hospitals = [
    'Ruby Hall Clinic',
    'Sassoon General Hospital',
    'KEM Hospital',
    'Jehangir Hospital',
    'Deenanath Mangeshkar Hospital',
  ];

  String _selectedHospital = 'Ruby Hall Clinic';

  InputDecoration _dec(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _hintColor, fontSize: 15),
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  void _proceed() {
    if (_formKey.currentState!.validate()) {
      final hospital = HospitalModel(
        name: _selectedHospital,
        city: 'Pune',
        state: 'Maharashtra',
        logoInitials: _initials(_selectedHospital),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HospitalDashboardScreen(hospital: hospital),
        ),
      );
    }
  }

  @override
  void dispose() {
    _hospitalCtrl.dispose();
    _codeCtrl.dispose();
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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A1A)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Hospital Staff Login',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1A1A1A),
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          children: [
            const SizedBox(height: 16),
            // Icon header
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.local_hospital_rounded,
                  color: _red,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Welcome, Hospital Staff',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
            const SizedBox(height: 6),
            const Center(
              child: Text(
                'Select your hospital and enter your staff code',
                style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 36),
            // Hospital selector
            const Text(
              'Hospital',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedHospital,
              decoration: _dec(''),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF1A1A1A),
                size: 22,
              ),
              borderRadius: BorderRadius.circular(16),
              items: _hospitals
                  .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _selectedHospital = v ?? _selectedHospital),
              validator: (v) => v == null ? 'Please select a hospital' : null,
            ),
            const SizedBox(height: 20),
            // Staff code
            const Text(
              'Staff Code',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _codeCtrl,
              obscureText: _obscure,
              decoration: _dec('Enter your staff access code').copyWith(
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFFAAAAAA),
                    size: 20,
                  ),
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Code is required';
                if (v.length < 4) return 'Code must be at least 4 characters';
                return null;
              },
            ),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _proceed,
                icon: const Icon(
                  Icons.login_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                label: const Text(
                  'Continue to Dashboard',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
