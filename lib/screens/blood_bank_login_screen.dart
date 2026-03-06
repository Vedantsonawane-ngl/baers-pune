import 'package:flutter/material.dart';
import '../models/blood_bank_model.dart';
import 'blood_bank_dashboard_screen.dart';

class BloodBankLoginScreen extends StatefulWidget {
  const BloodBankLoginScreen({super.key});

  @override
  State<BloodBankLoginScreen> createState() => _BloodBankLoginScreenState();
}

class _BloodBankLoginScreenState extends State<BloodBankLoginScreen> {
  static const _red = Color(0xFFD32F2F);
  static const _borderColor = Color(0xFFE8AAAA);
  static const _hintColor = Color(0xFFBBBBBB);

  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  bool _obscure = true;

  static const _bloodBanks = [
    'Pune City Blood Bank',
    'Sahyadri Blood Center',
    'Ratna Blood Bank',
    'Jeevandhara Blood Bank',
    'Rakt Seva Blood Bank',
  ];

  // Sample inventory per blood bank
  static const _inventories = <String, Map<String, int>>{
    'Pune City Blood Bank': {
      'A+': 120,
      'A−': 8,
      'B+': 45,
      'B−': 22,
      'AB+': 88,
      'AB−': 2,
      'O+': 156,
      'O−': 4,
    },
    'Sahyadri Blood Center': {
      'A+': 95,
      'A−': 12,
      'B+': 60,
      'B−': 18,
      'AB+': 44,
      'AB−': 5,
      'O+': 110,
      'O−': 9,
    },
    'Ratna Blood Bank': {
      'A+': 70,
      'A−': 3,
      'B+': 30,
      'B−': 10,
      'AB+': 25,
      'AB−': 1,
      'O+': 80,
      'O−': 2,
    },
    'Jeevandhara Blood Bank': {
      'A+': 140,
      'A−': 15,
      'B+': 55,
      'B−': 28,
      'AB+': 60,
      'AB−': 7,
      'O+': 175,
      'O−': 11,
    },
    'Rakt Seva Blood Bank': {
      'A+': 50,
      'A−': 6,
      'B+': 20,
      'B−': 8,
      'AB+': 18,
      'AB−': 3,
      'O+': 65,
      'O−': 5,
    },
  };

  String _selected = 'Pune City Blood Bank';

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
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.substring(0, 2).toUpperCase();
  }

  void _proceed() {
    if (_formKey.currentState!.validate()) {
      final bank = BloodBankModel(
        name: _selected,
        city: 'Pune',
        state: 'Maharashtra',
        logoInitials: _initials(_selected),
        inventory: Map<String, int>.from(
          _inventories[_selected] ?? _inventories['Pune City Blood Bank']!,
        ),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => BloodBankDashboardScreen(bank: bank)),
      );
    }
  }

  @override
  void dispose() {
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
          'Blood Bank Staff Login',
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
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8E8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: _red,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'Welcome, Blood Bank Staff',
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
                'Select your blood bank and enter your staff code',
                style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 36),
            // Blood bank selector
            const Text(
              'Blood Bank',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selected,
              decoration: _dec(''),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF1A1A1A),
                size: 22,
              ),
              borderRadius: BorderRadius.circular(16),
              items: _bloodBanks
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: (v) => setState(() => _selected = v ?? _selected),
              validator: (v) => v == null ? 'Please select a blood bank' : null,
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
