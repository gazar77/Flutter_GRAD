import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/app_state.dart';
import '../../core/models/analysis_result_api_model.dart';
import '../../core/networking/api_constants.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/report_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_card.dart';
import '../../core/localization/app_localizations.dart';

class ResultPage extends StatefulWidget {
  final File file;
  final Map<String, dynamic> result;

  const ResultPage({super.key, required this.file, required this.result});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _pdfLoading = false;

  Future<void> _downloadClinicalReport() async {
    setState(() => _pdfLoading = true);
    final model = AnalysisResultApiModel.fromJson(widget.result);
    final pdfData = model.toPdfReportPayload();
    final path = await ReportService.generatePdfReport(pdfData);
    if (!mounted) return;
    setState(() => _pdfLoading = false);

    if (path != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report saved — tap Share to export'),
          action: SnackBarAction(
            label: 'SHARE',
            onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(path)])),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not generate PDF')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final result = widget.result;

    final stenosis = (result['stenosisPercentage'] ?? 0.0).toDouble();
    final artery = result['arteryName'] ?? 'Unknown Artery';
    final riskLevel = result['riskLevel'] ?? 'Normal';
    final diagnosisDetails = result['diagnosisDetails'] ?? 'No detailed analysis provided.';

    final imagePath = result['imagePath'] as String?;
    final imageUrl = (imagePath != null && imagePath.isNotEmpty)
        ? ApiConstants.getFullImageUrl(imagePath)
        : null;

    Color riskColor;
    if (riskLevel.toString().toUpperCase().contains('CRITICAL') ||
        riskLevel.toString().toUpperCase().contains('HIGH')) {
      riskColor = AppColors.danger;
    } else if (riskLevel.toString().toUpperCase().contains('MODERATE') ||
        riskLevel.toString().toUpperCase().contains('MEDIUM')) {
      riskColor = AppColors.warning;
    } else {
      riskColor = AppColors.success;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('analysisTitle'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageContainer(imageUrl, widget.file),
              const SizedBox(height: 32),
              _buildDiagnosisCard(theme, artery, riskLevel.toString(), riskColor, stenosis),
              const SizedBox(height: 24),
              _buildClinicalNotesCard(theme, diagnosisDetails.toString()),
              const SizedBox(height: 40),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageContainer(String? imageUrl, File file) {
    return Stack(
      children: [
        AppCard(
          padding: EdgeInsets.zero,
          borderRadius: 20,
          color: Colors.black,
          showBorder: false,
          child: AspectRatio(
            aspectRatio: 1 / 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: InteractiveViewer(
                maxScale: 4.0,
                minScale: 1.0,
                child: imageUrl != null && imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return const Center(child: CircularProgressIndicator());
                        },
                        errorBuilder: (context, error, stack) => _VideoFallback(file: file),
                      )
                    : _VideoFallback(file: file),
              ),
            ),
          ),
        ),
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.zoom_in_rounded, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text('Pinch to Zoom', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildDiagnosisCard(ThemeData theme, String artery, String riskLevel, Color riskColor, double stenosis) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Diagnosis Summary', style: theme.textTheme.titleLarge),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: riskColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: riskColor),
                    const SizedBox(width: 6),
                    Text(
                      riskLevel.toUpperCase(),
                      style: TextStyle(color: riskColor, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Artery Segment', artery, Icons.hub_rounded),
          const Divider(height: 32),
          _buildDetailRow('Risk Classification', riskLevel, Icons.assessment_rounded),
          const SizedBox(height: 32),
          Text(
            'Stenosis Severity: ${stenosis.toStringAsFixed(1)}%',
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: (stenosis / 100).clamp(0.0, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [riskColor.withValues(alpha: 0.6), riskColor]),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ).animate().shimmer(duration: const Duration(seconds: 2)),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1);
  }

  Widget _buildClinicalNotesCard(ThemeData theme, String notes) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.notes_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Clinical Evaluation', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            notes,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: 'Download Clinical Report',
          icon: Icons.file_download_rounded,
          isLoading: _pdfLoading,
          onPressed: _downloadClinicalReport,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: AppButton(
                text: 'New Analysis',
                variant: AppButtonVariant.secondary,
                onPressed: () => context.go(AppRoutes.upload),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppButton(
                text: 'Home',
                variant: AppButtonVariant.secondary,
                onPressed: () {
                  context.read<AppState>().triggerDashboardRefresh();
                  context.go(AppRoutes.home);
                },
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(delay: 400.ms);
  }
}

class _VideoFallback extends StatelessWidget {
  final File file;
  const _VideoFallback({required this.file});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary.withValues(alpha: 0.05),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_rounded, size: 48, color: AppColors.primary),
          const SizedBox(height: 12),
          Text(
            file.path.split(Platform.pathSeparator).last,
            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
          const Text(
            'Analyzed video frame not available',
            style: TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
