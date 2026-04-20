import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_state.dart';
import '../../core/routing/app_routes.dart';
import '../../core/networking/api_constants.dart';
import '../../core/networking/dio_factory.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/localization/app_localizations.dart';

class ProcessingPage extends StatefulWidget {
  final File file;
  final int studyId;

  const ProcessingPage({super.key, required this.file, required this.studyId});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  double progress = 0.0;
  bool isError = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _analyzeStudy();
  }

  Future<void> _analyzeStudy() async {
    try {
      final dio = DioFactory.getDio();
      
      // Fake progress stream
      final timer = Stream.periodic(const Duration(milliseconds: 100), (i) => i);
      final subscription = timer.listen((i) {
        if (mounted && progress < 0.9) {
          setState(() => progress += 0.01);
        }
      });

      final response = await dio.post('${ApiConstants.analysis}/${widget.studyId}');
      subscription.cancel();

      if (response.statusCode == 200) {
        setState(() => progress = 1.0);
        if (mounted) {
          context.read<AppState>().triggerDashboardRefresh();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              context.go(AppRoutes.result, extra: {
                'file': widget.file,
                'studyId': widget.studyId,
                'result': response.data,
              });
            }
          });
        }
      } else {
        throw Exception('Analysis failed: ${response.statusMessage}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isError ? 'analysis_failed'.tr(context) : 'analyzing'.tr(context),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: isError ? AppColors.danger : AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ).animate().fadeIn().scale(),
              const SizedBox(height: 16),
              Text(
                isError ? 'error_occurred'.tr(context) : 'processing_desc'.tr(context),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textMuted),
              ),
              const SizedBox(height: 60),
              _buildProgressCircle(),
              const SizedBox(height: 60),
              if (isError) ...[
                Text(errorMessage, style: const TextStyle(color: AppColors.danger), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                AppButton(
                  text: 'go_back'.tr(context),
                  onPressed: () => context.go(AppRoutes.upload),
                  variant: AppButtonVariant.outline,
                ),
              ] else ...[
                const Text('AI is scanning every frame...', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Optimizing diagnosis accuracy', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCircle() {
    final color = isError ? AppColors.danger : AppColors.primary;
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 200,
          height: 200,
          child: CircularProgressIndicator(
            value: isError ? 1.0 : progress,
            strokeWidth: 8,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isError ? Icons.error_outline_rounded : Icons.monitor_heart_rounded, size: 40, color: color),
            const SizedBox(height: 12),
            Text(
              isError ? 'FAILED' : '${(progress * 100).toInt()}%',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }
}