import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/routing/app_routes.dart';
import '../../core/services/patient_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';
import 'models/patient_history_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  late Future<List<PatientHistory>> _patientsFuture;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _patientsFuture = _fetchPatients();
  }

  Future<List<PatientHistory>> _fetchPatients() async {
    try {
      final rawPatients = await PatientService().getAllPatients();
      return await compute(_processPatientData, rawPatients);
    } catch (e) {
      debugPrint('Error fetching patients: $e');
      rethrow;
    }
  }

  static List<PatientHistory> _processPatientData(List<dynamic> rawPatients) {
    return rawPatients.map((p) {
      int latestStenosis = 0;
      String latestDate = (p['createdAt'] as String?)?.split('T')[0] ?? '';
      String? artery;
      String? riskLevel;
      String? im1;
      String? im2;
      String? studyId;
      
      if (p['studies'] != null && (p['studies'] as List).isNotEmpty) {
        final studies = p['studies'] as List;
        for (var study in studies) {
          if (study['analysisResults'] != null && (study['analysisResults'] as List).isNotEmpty) {
            final results = study['analysisResults'] as List;
            final res = results.first;
            latestStenosis = (res['stenosisPercentage'] as num).toInt();
            riskLevel = res['riskLevel']?.toString();
            artery = res['arteryName']?.toString();
            im1 = res['imagePath']?.toString();
            im2 = study['filePath']?.toString();
            studyId = study['id']?.toString();
            break; 
          }
        }
      }

      return PatientHistory(
        id: studyId,
        name: p['fullName'] ?? 'Unknown',
        age: p['age'] ?? 0,
        gender: p['gender'] ?? 'Unknown',
        date: latestDate,
        stenosis: latestStenosis,
        artery: artery,
        riskLevel: riskLevel,
        notes: "Analysis completed successfully.",
        image1: im1,
        image2: im2,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('history'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildSearchField(),
                const SizedBox(height: 20),
                _buildFilterSection(),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PatientHistory>>(
              future: _patientsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState();
                }
                if (snapshot.hasError) {
                   return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('no_patients_found'.tr(context)));
                }

                final filtered = snapshot.data!.where((p) {
                  final matchesFilter = _selectedFilter == 'All' || p.status == _selectedFilter;
                  final matchesSearch = p.name.toLowerCase().contains(_searchController.text.toLowerCase());
                  return matchesFilter && matchesSearch;
                }).toList();

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return _PatientCard(patient: filtered[index]).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.1);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'search_hint'.tr(context),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    final filters = ['All', 'Normal', 'Moderate', 'Critical'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) => _FilterChip(
          label: f,
          isSelected: _selectedFilter == f,
          onTap: () => setState(() => _selectedFilter = f),
        )).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: 5,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: AppShimmer(width: double.infinity, height: 100, borderRadius: 16),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor(label);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: color.withValues(alpha: 0.2),
        labelStyle: TextStyle(
          color: isSelected ? color : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: isSelected ? color : AppColors.secondary.withValues(alpha: 0.1)),
        ),
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientHistory patient;
  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(patient.status);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AppCard(
        padding: const EdgeInsets.all(16),
        onTap: () => context.push(AppRoutes.caseDetails, extra: {
          "name": patient.name,
          "age": patient.age,
          "gender": patient.gender,
          "id": patient.id ?? "#${patient.name.hashCode}",
          "image1": patient.image1,
          "image2": patient.image2,
          "stenosis": patient.stenosis,
          "artery": patient.artery ?? "N/A",
          "notes": patient.notes,
          "riskLevel": patient.riskLevel,
        }),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.person_rounded, color: statusColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${patient.date} • ${patient.age} yrs', style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${patient.stenosis}%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: statusColor)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    patient.status.toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Color _getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'CRITICAL': return AppColors.danger;
    case 'MODERATE': return AppColors.warning;
    case 'NORMAL': return AppColors.success;
    default: return AppColors.primary;
  }
}