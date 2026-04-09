import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/services/patient_service.dart';
import 'package:fp/pages/history/models/patient_history_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'All';
  late Future<List<PatientHistory>> patientsFuture;

  @override
  void initState() {
    super.initState();
    patientsFuture = _fetchPatients();
  }

  Future<List<PatientHistory>> _fetchPatients() async {
    final rawPatients = await PatientService().getAllPatients();
    return rawPatients.map((p) {
      // Find latest analysis result if any
      int latestStenosis = 0;
      String latestDate = p['createdAt']?.split('T')[0] ?? '';
      
      if (p['studies'] != null && (p['studies'] as List).isNotEmpty) {
        final studies = p['studies'] as List;
        for (var study in studies) {
          if (study['analysisResults'] != null && (study['analysisResults'] as List).isNotEmpty) {
            final results = study['analysisResults'] as List;
            latestStenosis = results.first['stenosisPercentage'].toInt();
            break; 
          }
        }
      }

      return PatientHistory(
        name: p['fullName'] ?? 'Unknown',
        age: p['age'] ?? 0,
        date: latestDate,
        stenosis: latestStenosis,
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
                _filterChip('All'),
                _filterChip('Normal'),
                _filterChip('Moderate'),
                _filterChip('Critical'),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<PatientHistory>>(
                future: patientsFuture,
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

                  final filtered = selectedFilter == 'All'
                      ? snapshot.data!
                      : snapshot.data!.where((p) => p.status == selectedFilter).toList();

                  return ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final patient = filtered[index];
                      return _patientCard(patient);
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

  Widget _filterChip(String label) {
    final isSelected = selectedFilter == label;

    Color getColor() {
      if (label == 'Normal') return Colors.green;
      if (label == 'Moderate') return Colors.orange;
      if (label == 'Critical') return Colors.red;
      return Colors.blue;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? getColor().withValues(alpha: 0.2) : Colors.white,
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

  Widget _patientCard(PatientHistory patient) {
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
            "gender": "Unknown",
            "id": "#${patient.name.hashCode}",
            "image1": "https://via.placeholder.com/150",
            "image2": "https://via.placeholder.com/150",
            "stenosis": patient.stenosis,
            "artery": "LAD",
            "notes": "Diagnosis from backend.",
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
                const Icon(Icons.favorite_border),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
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