import 'package:flutter/material.dart';
import '../widgets/role_card.dart';
import 'blood_bank_login_screen.dart';
import 'donor_google_signin_screen.dart';
import 'hospital_login_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 64),

              // ── App Logo ──────────────────────────────────────────────
              RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Red',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD32F2F),
                        letterSpacing: 0.5,
                      ),
                    ),
                    TextSpan(
                      text: 'Link',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A1A),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 48),

              // ── Welcome heading ───────────────────────────────────────
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 10),

              // ── Subtitle ──────────────────────────────────────────────
              const Text(
                'Please select your role to continue',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF888888),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // ── Role Cards ────────────────────────────────────────────
              RoleCard(
                icon: Icons.volunteer_activism,
                title: 'I am a Donor',
                subtitle: 'Help save lives in Pune',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const DonorGoogleSignInScreen(),
                    ),
                  );
                },
              ),

              RoleCard(
                icon: Icons.local_hospital,
                title: 'Hospital Staff',
                subtitle: 'Request emergency blood units',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HospitalLoginScreen(),
                    ),
                  );
                },
              ),

              RoleCard(
                icon: Icons.water_drop,
                title: 'Blood Bank Staff',
                subtitle: 'Manage inventory & SOS calls',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BloodBankLoginScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

              // ── Footer ────────────────────────────────────────────────
              const Padding(
                padding: EdgeInsets.only(bottom: 24),
                child: Text(
                  "Connecting Pune's blood supply network",
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
