import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/pages/history/models/patient_history_model.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String selectedFilter = 'All';

  List<PatientHistory> patients = [
    PatientHistory(name: 'Nora Ahmed', age: 56, date: '12 May 2025', stenosis: 65),
    PatientHistory(name: 'Sara Hassan', age: 63, date: '10 May 2025', stenosis: 60),
    PatientHistory(name: 'Khaled Ahmed', age: 48, date: '8 May 2025', stenosis: 30),
    PatientHistory(name: 'Ahmed Ali', age: 72, date: '7 May 2025', stenosis: 20),
  ];

  List<PatientHistory> get filteredPatients {
    if (selectedFilter == 'All') return patients;
    return patients.where((p) => p.status == selectedFilter).toList();
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

            /// 🔍 Search
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

            /// 🔹 Filters
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

            /// 🔹 List
            Expanded(
              child: ListView.builder(
                itemCount: filteredPatients.length,
                itemBuilder: (context, index) {
                  final patient = filteredPatients[index];
                  return _patientCard(patient);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= FILTER =================
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
          color: isSelected ? getColor().withOpacity(0.2) : Colors.white,
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

  /// ================= CARD =================
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
            "gender": "Female",
            "id": "#${patient.name.hashCode}",
            "image1": "https://via.placeholder.com/150",
            "image2": "https://via.placeholder.com/150",
            "stenosis": patient.stenosis,
            "artery": "LAD",
            "notes": "Significant stenosis detected. Further evaluation recommended.",
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
                  Text('Diagnosis: ${patient.date}'),
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
                    color: statusColor.withOpacity(0.2),
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