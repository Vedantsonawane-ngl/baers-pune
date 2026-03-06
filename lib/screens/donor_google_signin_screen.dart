import 'package:flutter/material.dart';
import 'donor_registration_screen.dart';

class DonorGoogleSignInScreen extends StatefulWidget {
  const DonorGoogleSignInScreen({super.key});

  @override
  State<DonorGoogleSignInScreen> createState() =>
      _DonorGoogleSignInScreenState();
}

// ── Sample accounts shown in the picker ────────────────────────────────────
class _MockAccount {
  final String name;
  final String email;
  final Color avatarColor;
  const _MockAccount(this.name, this.email, this.avatarColor);
}

const _mockAccounts = [
  _MockAccount('Aditya Pundlik', 'adipun.2020@gmail.com', Color(0xFF4285F4)),
];

class _DonorGoogleSignInScreenState extends State<DonorGoogleSignInScreen> {
  static const _red = Color(0xFFD32F2F);
  static const _bg = Color(0xFFF7F7F7);

  bool _loading = false;

  // Shows the Google-style "Choose an account" bottom sheet
  Future<void> _handleGoogleSignIn() async {
    final picked = await showModalBottomSheet<_MockAccount?>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _GoogleAccountPickerSheet(),
    );

    if (picked == null || !mounted) return;

    setState(() => _loading = true);
    // Small artificial delay to mimic network auth
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;
    setState(() => _loading = false);

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DonorRegistrationScreen(
          prefillName: picked.name,
          prefillEmail: picked.email,
          googlePhotoUrl: null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1A1A1A),
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),

                // ── RedLink logo ──────────────────────────────────────────
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Red',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: _red,
                          letterSpacing: 0.5,
                        ),
                      ),
                      TextSpan(
                        text: 'Link',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),

                // ── Illustration container ────────────────────────────────
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _red.withValues(alpha: 0.12),
                        blurRadius: 30,
                        spreadRadius: 6,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volunteer_activism_rounded,
                    size: 68,
                    color: _red,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Heading ───────────────────────────────────────────────
                const Text(
                  'Join as a Donor',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A),
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Sign in with Google to create your\ndonor profile and save lives.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Color(0xFF888888),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // ── Benefits tiles ────────────────────────────────────────
                _BenefitTile(
                  icon: Icons.security_rounded,
                  color: const Color(0xFF1565C0),
                  title: 'Secure & Private',
                  subtitle: 'Your data is protected with Google authentication',
                ),
                const SizedBox(height: 12),
                _BenefitTile(
                  icon: Icons.notifications_active_rounded,
                  color: const Color(0xFFF57C00),
                  title: 'Instant Alerts',
                  subtitle:
                      'Get notified when your blood type is needed nearby',
                ),
                const SizedBox(height: 12),
                _BenefitTile(
                  icon: Icons.favorite_rounded,
                  color: _red,
                  title: 'Save Lives',
                  subtitle: 'Every donation can save up to 3 lives',
                ),

                const SizedBox(height: 48),

                // ── Google Sign-In button ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF4285F4),
                            ),
                          ),
                        )
                      : _GoogleSignInButton(onPressed: _handleGoogleSignIn),
                ),

                const SizedBox(height: 16),

                // ── Privacy note ──────────────────────────────────────────
                const Text(
                  'By continuing, you agree to RedLink\'s Terms of Service\nand Privacy Policy.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFAAAAAA),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Google Sign-In button with official Google styling ─────────────────────
class _GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _GoogleSignInButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google "G" logo
            Container(
              width: 24,
              height: 24,
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: CustomPaint(painter: _GoogleLogoPainter()),
            ),
            const SizedBox(width: 12),
            const Text(
              'Continue with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF3C4043),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Benefit tile ────────────────────────────────────────────────────────────
class _BenefitTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _BenefitTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
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

// ── Google-style account picker bottom sheet ────────────────────────────────
class _GoogleAccountPickerSheet extends StatefulWidget {
  const _GoogleAccountPickerSheet();

  @override
  State<_GoogleAccountPickerSheet> createState() =>
      _GoogleAccountPickerSheetState();
}

class _GoogleAccountPickerSheetState extends State<_GoogleAccountPickerSheet> {
  bool _showCustomForm = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFDDDDDD),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ── Google header ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Column(
              children: [
                // Google multicolor "G" text
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'G',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      TextSpan(
                        text: 'o',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA4335),
                        ),
                      ),
                      TextSpan(
                        text: 'o',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFBBC05),
                        ),
                      ),
                      TextSpan(
                        text: 'g',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4285F4),
                        ),
                      ),
                      TextSpan(
                        text: 'l',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF34A853),
                        ),
                      ),
                      TextSpan(
                        text: 'e',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFEA4335),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose an account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF202124),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'to continue to RedLink',
                  style: TextStyle(fontSize: 13, color: Color(0xFF5F6368)),
                ),
              ],
            ),
          ),

          const Divider(height: 24, color: Color(0xFFE8EAED)),

          if (!_showCustomForm) ...[
            // ── Sample accounts ───────────────────────────────────────
            ..._mockAccounts.map(
              (acc) => _AccountTile(
                account: acc,
                onTap: () => Navigator.of(context).pop(acc),
              ),
            ),

            // Divider
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Divider(color: Color(0xFFE8EAED)),
            ),

            // ── "Use a different account" ─────────────────────────────
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFDADCE0), width: 1),
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: Color(0xFF5F6368),
                  size: 22,
                ),
              ),
              title: const Text(
                'Use a different account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
              ),
              onTap: () => setState(() => _showCustomForm = true),
            ),
          ] else ...[
            // ── Custom name / email form ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                children: [
                  _SheetField(
                    controller: _nameCtrl,
                    label: 'Full name',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _SheetField(
                    controller: _emailCtrl,
                    label: 'Email address',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () =>
                            setState(() => _showCustomForm = false),
                        child: const Text(
                          'Back',
                          style: TextStyle(color: Color(0xFF5F6368)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                        onPressed: () {
                          final name = _nameCtrl.text.trim();
                          final email = _emailCtrl.text.trim();
                          if (name.isEmpty || email.isEmpty) return;
                          Navigator.of(context).pop(
                            _MockAccount(name, email, const Color(0xFF4285F4)),
                          );
                        },
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // ── Footer ────────────────────────────────────────────────────
          const Divider(color: Color(0xFFE8EAED), height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _FooterLink('Privacy Policy'),
                const SizedBox(width: 6),
                const Text(
                  '·',
                  style: TextStyle(fontSize: 12, color: Color(0xFF80868B)),
                ),
                const SizedBox(width: 6),
                _FooterLink('Terms of Service'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Account row tile ────────────────────────────────────────────────────────
class _AccountTile extends StatelessWidget {
  final _MockAccount account;
  final VoidCallback onTap;

  const _AccountTile({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: account.avatarColor,
        child: Text(
          account.name[0],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        account.name,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF202124),
        ),
      ),
      subtitle: Text(
        account.email,
        style: const TextStyle(fontSize: 12, color: Color(0xFF5F6368)),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF5F6368),
        size: 20,
      ),
      onTap: onTap,
    );
  }
}

// ── Text field inside the sheet ─────────────────────────────────────────────
class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType keyboardType;

  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14, color: Color(0xFF202124)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
        prefixIcon: Icon(icon, size: 18, color: const Color(0xFF5F6368)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFDADCE0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
        ),
      ),
    );
  }
}

// ── Footer link text ────────────────────────────────────────────────────────
class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 12, color: Color(0xFF1A73E8)),
    );
  }
}

// ── Google "G" logo painter ─────────────────────────────────────────────────
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double r = size.width / 2;

    // Blue arc (top-right)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      -10 * (3.14159 / 180),
      80 * (3.14159 / 180),
      const Color(0xFF4285F4),
    );
    // Red arc (top-left)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      190 * (3.14159 / 180),
      80 * (3.14159 / 180),
      const Color(0xFFEA4335),
    );
    // Yellow arc (bottom-left)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      120 * (3.14159 / 180),
      70 * (3.14159 / 180),
      const Color(0xFFFBBC05),
    );
    // Green arc (bottom)
    _drawArc(
      canvas,
      cx,
      cy,
      r,
      50 * (3.14159 / 180),
      70 * (3.14159 / 180),
      const Color(0xFF34A853),
    );

    // White middle
    final whitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(Offset(cx, cy), r * 0.55, whitePaint);

    // Blue "G" horizontal bar
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = r * 0.25
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy), Offset(cx + r * 0.85, cy), bluePaint);
  }

  void _drawArc(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = r * 0.32
      ..style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r * 0.75),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
