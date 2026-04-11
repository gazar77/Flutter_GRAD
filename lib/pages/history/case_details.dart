import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/report_service.dart';
import '../../core/networking/api_constants.dart';
import 'package:share_plus/share_plus.dart';

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
    const primaryColor = Color(0xFF2B4F7A);
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.history),
        ),
        title: const Text(
          "Case Details",
          style: TextStyle(color: Color(0xFF2B3A4A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              /// PATIENT INFO HEADER
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderItem("Patient Name", data['name'] ?? data['patientName'] ?? 'N/A'),
                        _buildHeaderItem("Age", data['age']?.toString() ?? 'N/A', alignRight: true),
                      ],
                    ),
                    const Divider(height: 32, color: Color(0xFFF1F5F9)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderItem("Gender", data['gender'] ?? 'N/A'),
                        _buildHeaderItem("Case ID", data['id']?.toString() ?? 'N/A', alignRight: true),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),

              /// IMAGE SECTION
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                height: 240,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 15, spreadRadius: 0, offset: const Offset(0, 8)),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Image.network(
                    ApiConstants.getFullImageUrl(data['image1'] ?? data['image2']),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFF1F5F9),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported_rounded, size: 48, color: Colors.grey),
                          SizedBox(height: 12),
                          Text("No analysis result image found", style: TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ),
                  ),
                ),
              ).animate().fadeIn(delay: 200.ms).scale(begin: const Offset(0.98, 0.98)),

              /// DIAGNOSIS & DETAILS CARD
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 20, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Diagnosis & Details",
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                        if (data['riskLevel'] != null && data['riskLevel'] != 'N/A')
                          _buildRiskBadge(data['riskLevel'].toString()),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildInfoRow("Detected Artery", data['artery'] ?? 'N/A'),
                    _buildInfoRow("Risk Level", data['riskLevel'] ?? ((((data['stenosis'] ?? data['stenosisPercent'] ?? 0) as num).toDouble() >= 70) ? 'Critical' : 'Normal')),
                    _buildInfoRow("Stenosis level", "${data['stenosis'] ?? data['stenosisPercent'] ?? 0}%"),

                    const SizedBox(height: 20),

                    /// Professional Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          Container(height: 10, color: const Color(0xFFF1F5F9)),
                          AnimatedContainer(
                            duration: 1.seconds,
                            curve: Curves.easeOutCubic,
                            height: 10,
                            width: (MediaQuery.of(context).size.width - 80) * (((data['stenosisPercent'] ?? data['stenosis'] ?? 0) as num).toDouble() / 100),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: (data['stenosisPercent'] ?? data['stenosis'] ?? 0) >= 70 
                                  ? [Colors.red[400]!, Colors.red[700]!]
                                  : [Colors.orange[400]!, Colors.orange[700]!],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.05),

              /// DIAGNOSIS INSIGHTS
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.lightbulb_outline_rounded, color: primaryColor, size: 20),
                        SizedBox(width: 10),
                        Text(
                          "Diagnosis Insights",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['diagnosisDetails'] ?? data['notes'] ?? "No additional diagnosis insights available for this case.",
                      style: TextStyle(fontSize: 15, color: const Color(0xFF475569).withValues(alpha: 0.9), height: 1.6),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 450.ms),

              const SizedBox(height: 24),

              /// DOWNLOAD BUTTON
              if (_isDownloading)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(color: primaryColor),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: primaryColor.withValues(alpha: 0.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      setState(() => _isDownloading = true);
                      final path = await ReportService.generatePdfReport(widget.data);
                      setState(() => _isDownloading = false);
                      if (!mounted) return;
                      if (path != null) {
                        messenger.showSnackBar(SnackBar(
                          content: const Text("Report generated successfully!"),
                          backgroundColor: Colors.green[600],
                          behavior: SnackBarBehavior.floating,
                          action: SnackBarAction(
                            label: "VIEW/SHARE",
                            textColor: Colors.white,
                            onPressed: () async {
                              await SharePlus.shareXFiles([XFile(path)], subject: 'AngioLens Analysis Report');
                            },
                          ),
                        ));
                      } else {
                        messenger.showSnackBar(const SnackBar(
                          content: Text("Failed to generate report"),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ));
                      }
                    },
                    icon: const Icon(Icons.picture_as_pdf_rounded),
                    label: const Text("Download Analysis Report", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 40)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderItem(String label, String value, {bool alignRight = false}) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B), fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isCritical = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
          Text(
            value, 
            style: TextStyle(
              color: isCritical ? Colors.red[700] : const Color(0xFF1E293B), 
              fontWeight: FontWeight.bold, 
              fontSize: 14
            )
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(String level) {
    final isCritical = level == 'Critical';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCritical ? const Color(0xFFFFE4E6) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            level.toUpperCase(),
            style: TextStyle(
              color: isCritical ? const Color(0xFFE11D48) : const Color(0xFFD97706),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            isCritical ? Icons.error_outline_rounded : Icons.warning_amber_rounded,
            size: 14,
            color: isCritical ? const Color(0xFFE11D48) : const Color(0xFFD97706),
          ),
        ],
      ),
    );
  }
}