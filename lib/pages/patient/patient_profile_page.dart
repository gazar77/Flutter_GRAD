import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';

class PatientProfilePage extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientProfilePage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);
    const Color cardColor = Colors.white;

    final studies = (patient['studies'] as List?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text('${patient['fullName']}\'s Profile'),
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.patients);
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 👤 Personal Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                   const CircleAvatar(
                    radius: 40,
                    backgroundColor: Color(0xFFEAF2FB),
                    child: Icon(Icons.person, size: 40, color: primaryColor),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    patient['fullName'] ?? 'Unknown',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Patient ID: #${patient['id']}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(height: 32),
                  _infoTile(Icons.cake, 'Age', '${patient['age']} years'),
                  _infoTile(Icons.person_outline, 'Gender', patient['gender'] ?? 'N/A'),
                  _infoTile(Icons.phone, 'Phone', patient['phoneNumber'] ?? 'N/A'),
                  _infoTile(Icons.medical_services_outlined, 'Diseases', patient['chronicDiseases'] ?? 'None'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// 🔬 Past Scans Section
            const Text(
              'Past Investigations',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            if (studies.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('No past investigations found for this patient.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: studies.length,
                itemBuilder: (context, index) {
                  final study = studies[index];
                  final results = (study['analysisResults'] as List?) ?? [];
                  final latestResult = results.isNotEmpty ? results.first : null;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const Icon(Icons.monitor_heart, color: primaryColor),
                      title: Text('Scan Date: ${study['uploadDate']?.split('T')[0] ?? 'N/A'}'),
                      subtitle: Text(
                        latestResult != null
                            ? 'Stenosis: ${latestResult['stenosisPercentage']}% (${latestResult['riskLevel']})'
                            : 'Processing or No Results',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                      onTap: () {
                        if (latestResult != null) {
                           context.push(
                            AppRoutes.caseDetails,
                            extra: {
                              "name": patient['fullName'],
                              "age": patient['age'],
                              "gender": patient['gender'],
                              "id": "#${patient['id']}",
                              "image1": latestResult['imagePath'] ?? "https://via.placeholder.com/150",
                              "image2": "https://via.placeholder.com/150",
                              "stenosis": latestResult['stenosisPercentage'],
                              "artery": latestResult['arteryName'] ?? "LAD",
                              "notes": "Diagnosis from patient history.",
                            },
                          );
                        }
                      },
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF6F8AA8)),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
