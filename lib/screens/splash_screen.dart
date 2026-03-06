import 'package:flutter/material.dart';
import 'role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _lineAnim;

  @override
  void initState() {
    super.initState();

    // Total duration: 900 ms fade-in, then 300 ms line reveal
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Text fades in over the first 75 % of the timeline (0 → 900 ms)
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
    );

    // Red line grows from 0 → 1 over the last 25 % (900 ms → 1200 ms)
    _lineAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
    );

    // Navigate as soon as animation finishes — no extra delay
    _controller.forward().whenComplete(_navigate);
  }

  void _navigate() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const RoleSelectionScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── App name ──────────────────────────────────────────────
            FadeTransition(
              opacity: _fadeAnim,
              child: RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'Red',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                    TextSpan(
                      text: 'Link',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Red underline ─────────────────────────────────────────
            AnimatedBuilder(
              animation: _lineAnim,
              builder: (context, child) => SizedBox(
                // Matches visual width of "RedLink" at 48 sp / w800
                width: 200 * _lineAnim.value,
                height: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: const Color(0xFFD32F2F),
                    borderRadius: BorderRadius.circular(2),
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
