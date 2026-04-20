import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/services/report_service.dart';
import '../../core/networking/api_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/localization/app_localizations.dart';

class CaseDetailsPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const CaseDetailsPage({super.key, required this.data});

  @override
  State<CaseDetailsPage> createState() => _CaseDetailsPageState();
}

class _CaseDetailsPageState extends State<CaseDetailsPage> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final stenosis = ((data['stenosisPercent'] ?? data['stenosis'] ?? 0) as num).toDouble();
    final riskLevel = data['riskLevel']?.toString() ?? (stenosis >= 70 ? 'Critical' : 'Normal');
    final riskColor = _getRiskColor(riskLevel);

    return Scaffold(
      appBar: AppBar(
        title: Text('case_details'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildPatientHeader(data),
            const SizedBox(height: 24),
            _buildAnalysisImage(data),
            const SizedBox(height: 24),
            _buildDiagnosisCard(data, stenosis, riskLevel, riskColor),
            const SizedBox(height: 24),
            _buildInsightsCard(data),
            const SizedBox(height: 48),
            _buildActionButtons(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(Map<String, dynamic> data) {
    return AppCard(
      child: Column(
        children: [
          _buildInfoRow('patient_name'.tr(context), data['name'] ?? 'N/A', isBold: true),
          const Divider(height: 24),
          Row(
            children: [
              Expanded(child: _buildInfoRow('age'.tr(context), data['age']?.toString() ?? 'N/A')),
              const SizedBox(width: 16),
              Expanded(child: _buildInfoRow('gender'.tr(context), data['gender'] ?? 'N/A')),
            ],
          ),
          const Divider(height: 24),
          _buildInfoRow('case_id'.tr(context), data['id']?.toString() ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildAnalysisImage(Map<String, dynamic> data) {
    final imageUrl = ApiConstants.getFullImageUrl(data['image1'] ?? data['image2']);
    return AppCard(
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            imageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: AppColors.secondary.withValues(alpha: 0.05),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.textMuted),
                  SizedBox(height: 12),
                  Text("Analysis frame not found", style: TextStyle(color: AppColors.textMuted)),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.98, 0.98));
  }

  Widget _buildDiagnosisCard(Map<String, dynamic> data, double stenosis, String riskLevel, Color riskColor) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('diagnosis'.tr(context), style: Theme.of(context).textTheme.titleLarge),
              _buildRiskBadge(riskLevel, riskColor),
            ],
          ),
          const SizedBox(height: 24),
          _buildInfoRow('artery'.tr(context), data['artery'] ?? 'N/A'),
          const Divider(height: 24),
          Text(
            '${'stenosis'.tr(context)}: ${stenosis.toStringAsFixed(1)}%',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildProgressBar(stenosis, riskColor),
        ],
      ),
    );
  }

  Widget _buildInsightsCard(Map<String, dynamic> data) {
    return AppCard(
      color: AppColors.primary.withValues(alpha: 0.05),
      showBorder: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('insights'.tr(context), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['diagnosisDetails'] ?? data['notes'] ?? "No additional insights.",
            style: const TextStyle(height: 1.5, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        AppButton(
          text: 'download_report'.tr(context),
          icon: Icons.picture_as_pdf_rounded,
          isLoading: _isDownloading,
          onPressed: _handleDownload,
        ),
      ],
    );
  }

  Future<void> _handleDownload() async {
    setState(() => _isDownloading = true);
    final path = await ReportService.generatePdfReport(widget.data);
    setState(() => _isDownloading = false);
    
    if (mounted && path != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text("Report saved successfully!"),
        action: SnackBarAction(
          label: "SHARE",
          onPressed: () => SharePlus.instance.share(ShareParams(files: [XFile(path)])),
        ),
      ));
    }
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
        Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: 14)),
      ],
    );
  }

  Widget _buildRiskBadge(String level, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        level.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildProgressBar(double value, Color color) {
    return Stack(
      children: [
        Container(height: 10, decoration: BoxDecoration(color: AppColors.secondary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5))),
        FractionallySizedBox(
          widthFactor: (value / 100).clamp(0.0, 1.0),
          child: Container(
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withValues(alpha: 0.6), color]),
              borderRadius: BorderRadius.circular(5),
            ),
          ).animate().shimmer(),
        ),
      ],
    );
  }

  Color _getRiskColor(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL': return AppColors.danger;
      case 'MODERATE': return AppColors.warning;
      case 'NORMAL': return AppColors.success;
      default: return AppColors.primary;
    }
  }
}