import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/routing/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _goToNextScreen();
  }

  void _goToNextScreen() {
    Timer(const Duration(milliseconds: 3500), () {
      if (mounted) {
        context.go(AppRoutes.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              Color(0xFF355C8D),
              Color(0xFF1B324F),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: const _GridPainter(),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x332196F3),
                          blurRadius: 100,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/images/angiolens_logo.png',
                      fit: BoxFit.contain,
                    ),
                  )
                  .animate()
                  .scale(duration: 800.ms, curve: Curves.easeOutBack)
                  .fadeIn(duration: 600.ms)
                  .shimmer(delay: 1.seconds, duration: 2.seconds, color: Colors.white24)
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .moveY(begin: -5, end: 5, duration: 2.seconds, curve: Curves.easeInOut),

                  const SizedBox(height: 40),

                  Text(
                    'AngioLens',
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 800.ms)
                  .slideY(begin: 0.2, end: 0, curve: Curves.easeOut),

                  const SizedBox(height: 12),

                  Text(
                    'AI-POWERED CARDIAC ANALYSIS',
                    style: const TextStyle(
                      fontFamily: 'sans-serif',
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 4,
                    ),
                  )
                  .animate()
                  .fadeIn(delay: 1000.ms, duration: 1000.ms)
                  .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
                ],
              ),
            ),
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 40,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.white10,
                        color: Colors.white54,
                        minHeight: 2,
                      ),
                    )
                    .animate()
                    .fadeIn(delay: 1500.ms)
                    .scaleX(begin: 0, end: 1, duration: 1500.ms),
                    const SizedBox(height: 12),
                    Text(
                      'SYSTEM INITIALIZING',
                      style: const TextStyle(
                        fontFamily: 'sans-serif',
                        color: Colors.white38,
                        fontSize: 10,
                        letterSpacing: 1.5,
                      ),
                    ).animate().fadeIn(delay: 2000.ms),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x80FFFFFF)
      ..strokeWidth = 0.5;

    const spacing = 40.0;
    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}