import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';

class ProcessingPage extends StatefulWidget {
  final File file;

  const ProcessingPage({super.key, required this.file});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  double progress = 0.0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startFakeProgress();
  }

  void _startFakeProgress() {
    timer = Timer.periodic(const Duration(milliseconds: 80), (t) {
      if (!mounted) return;

      setState(() {
        progress += 0.01;
      });

      if (progress >= 1.0) {
        timer?.cancel();

        Future.delayed(const Duration(milliseconds: 300), () {
          if (!mounted) return;

          context.go(
            AppRoutes.result,
            extra: widget.file,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),

            const Text(
              'Processing Analysis',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),

            const SizedBox(height: 60),

            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.25),
                          blurRadius: 25,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 180,
                    height: 180,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation(primaryColor),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monitor_heart, color: primaryColor),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      const Text(
                        'ANALYZING',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            const Text(
              'Analyzing angiography video',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'This may take a few seconds',
              style: TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}