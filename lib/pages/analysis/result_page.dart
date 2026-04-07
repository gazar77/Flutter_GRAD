import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class _MainButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _MainButton({
    required this.text,
    required this.color,
    this.textColor = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final File file; // 🔥 نخزن الصورة هنا

  const ResultPage({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    final stenosis = 45;
    final artery = 'Left Anterior Descending (LAD)';
    final severity = 'Mild-Moderate';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Analysis Result',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),

              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 10),

              /// 🔥 الصورة اللي المستخدم رفعها
              Container(
                width: double.infinity,
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5),
                  ],
                ),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file( // 🔥 بدل asset
                        file,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    /// Detection Box (مؤقت)
                    Positioned(
                      right: 40,
                      top: 60,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.orange,
                            width: 3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// باقي الكود زي ما هو 👇
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Diagnosis & Details',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'MEDIUM RISK',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.warning,
                            color: Colors.orange, size: 16),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text('Detected Artery : $artery'),
                    const SizedBox(height: 6),
                    Text('Severity Grade : $severity'),

                    const SizedBox(height: 12),

                    Text('Stenosis Level : $stenosis%'),
                    const SizedBox(height: 6),

                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: stenosis / 100,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              Row(
                children: [
                  Expanded(
                    child: _MainButton(
                      text: 'Download Result',
                      color: primaryColor,
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MainButton(
                      text: 'Analyze Another Video',
                      color: Colors.grey.shade300,
                      textColor: Colors.black,
                      onTap: () {
                        context.go('/upload');
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}