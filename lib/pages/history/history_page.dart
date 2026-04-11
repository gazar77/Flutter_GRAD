import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/services/patient_service.dart';
import 'package:fp/core/services/report_service.dart';
import 'package:fp/pages/history/models/patient_history_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  late Future<List<PatientHistory>> _patientsFuture;

  @override
  void initState() {
    super.initState();
    _patientsFuture = _fetchPatients();
  }

  Future<List<PatientHistory>> _fetchPatients() async {
    try {
      final rawPatients = await PatientService().getAllPatients();
      // Use compute to process data in a background isolate to keep UI responsive
      return await compute(_processPatientData, rawPatients);
    } catch (e) {
      debugPrint('Error fetching patients: $e');
      rethrow;
    }
  }

  // Pure function for background processing - must be static or top-level
  static List<PatientHistory> _processPatientData(List<dynamic> rawPatients) {
    return rawPatients.map((p) {
      int latestStenosis = 0;
      String latestDate = (p['createdAt'] as String?)?.split('T')[0] ?? '';
      String? artery;
      String? riskLevel;
      String? notes;
      String? im1;
      String? im2;
      String? studyId;
      
      if (p['studies'] != null && (p['studies'] as List).isNotEmpty) {
        final studies = p['studies'] as List;
        // Find the latest study with an analysis result
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
        notes: notes ?? "Analysis completed successfully.",
        image1: im1,
        image2: im2,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: primaryColor,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: const Text('Patients History'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search Patient name or ID',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _FilterChip(
                  label: 'All',
                  isSelected: _selectedFilter == 'All',
                  onTap: () => setState(() => _selectedFilter = 'All'),
                ),
                _FilterChip(
                  label: 'Normal',
                  isSelected: _selectedFilter == 'Normal',
                  onTap: () => setState(() => _selectedFilter = 'Normal'),
                ),
                _FilterChip(
                  label: 'Moderate',
                  isSelected: _selectedFilter == 'Moderate',
                  onTap: () => setState(() => _selectedFilter = 'Moderate'),
                ),
                _FilterChip(
                  label: 'Critical',
                  isSelected: _selectedFilter == 'Critical',
                  onTap: () => setState(() => _selectedFilter = 'Critical'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<PatientHistory>>(
                future: _patientsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No patients found'));
                  }

                  final filtered = _selectedFilter == 'All'
                      ? snapshot.data!
                      : snapshot.data!.where((p) => p.status == _selectedFilter).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final patient = filtered[index];
                      return _PatientCard(patient: patient);
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
    Color getColor() {
      if (label == 'Normal') return Colors.green;
      if (label == 'Moderate') return Colors.orange;
      if (label == 'Critical') return Colors.red;
      return Colors.blue;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? getColor().withAlpha((0.2 * 255).toInt()) : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: 8, color: getColor()),
            const SizedBox(width: 4),
            Text(label),
          ],
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
    const primaryColor = Color(0xFF2B4F7A);
    Color statusColor;
    if (patient.status == 'Normal') {
      statusColor = Colors.green;
    } else if (patient.status == 'Moderate') {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.red;
    }

    return GestureDetector(
      onTap: () {
        context.push(
          AppRoutes.caseDetails,
          extra: {
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
          },
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black26, blurRadius: 3),
          ],
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('Age: ${patient.age}'),
                  Text('Date: ${patient.date}'),
                  Text(
                    'Stenosis: ${patient.stenosis}%',
                    style: TextStyle(color: statusColor),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: const Icon(Icons.download, color: primaryColor),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    messenger.showSnackBar(
                      const SnackBar(content: Text("Generating report...")),
                    );
                    final path = await ReportService.generatePdfReport({
                      "name": patient.name,
                      "age": patient.age,
                      "gender": patient.gender,
                      "stenosis": patient.stenosis,
                      "date": patient.date,
                    });
                    if (path != null) {
                      messenger.showSnackBar(
                        SnackBar(content: Text("Report saved to: $path")),
                      );
                    }
                  },
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha((0.2 * 255).toInt()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    patient.status,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                    ),
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