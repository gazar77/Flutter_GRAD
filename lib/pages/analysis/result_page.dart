import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/networking/api_constants.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';

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

/// Fallback widget shown when no analyzed image is available from backend
class _VideoFallback extends StatelessWidget {
  final File file;
  const _VideoFallback({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0x0F2B4F7A),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.play_circle_fill, size: 52, color: Color(0xFF2B4F7A)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              file.path.split('/').last,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF2B4F7A),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${(file.lengthSync() / (1024 * 1024)).toStringAsFixed(2)} MB',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final File file;
  final Map<String, dynamic> result;

  const ResultPage({super.key, required this.file, required this.result});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    // Map backend response
    final stenosis = (result['stenosisPercentage'] ?? 0.0).toDouble();
    final artery = result['arteryName'] ?? 'Unknown Artery';
    final riskLevel = result['riskLevel'] ?? 'Normal';
    // Build full image URL from imagePath returned by backend
    final imagePath = result['imagePath'] as String?;
    final imageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? '${ApiConstants.baseUrl.replaceFirst('/api/', '/')}$imagePath'
        : null;

    Color riskColor;
    if (riskLevel.toUpperCase().contains('CRITICAL') || riskLevel.toUpperCase().contains('HIGH')) {
      riskColor = Colors.red;
    } else if (riskLevel.toUpperCase().contains('MODERATE') || riskLevel.toUpperCase().contains('MEDIUM')) {
      riskColor = Colors.orange;
    } else {
      riskColor = Colors.green;
    }

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

              /// Analyzed image from backend
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 5),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (context, error, stack) =>
                              _VideoFallback(file: file),
                        )
                      : _VideoFallback(file: file),
                ),
              ),

              const SizedBox(height: 16),

              /// Diagnosis Details
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
                            color: riskColor.withAlpha((0.1 * 255).toInt()),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            riskLevel.toUpperCase(),
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(Icons.warning, color: riskColor, size: 16),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Text('Detected Artery : $artery'),
                    const SizedBox(height: 6),
                    Text('Risk Level : $riskLevel'),

                    const SizedBox(height: 12),

                    Text('Stenosis Level : ${stenosis.toStringAsFixed(1)}%'),
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
                          widthFactor: (stenosis / 100).clamp(0.0, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: riskColor,
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
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Downloading report...')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MainButton(
                      text: 'Analyze Another Video',
                      color: Colors.grey.shade300,
                      textColor: Colors.black,
                      onTap: () {
                        context.go(AppRoutes.upload);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MainButton(
                      text: 'Back to Home',
                      color: Colors.green,
                      onTap: () {
                        context.read<AppState>().triggerDashboardRefresh();
                        context.go(AppRoutes.home);
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