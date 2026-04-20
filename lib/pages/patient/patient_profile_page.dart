import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/services/patient_service.dart';
import '../../core/app_state.dart';
import 'package:provider/provider.dart';

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
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              context.push(AppRoutes.editPatient, extra: patient);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
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
                    color: const Color(0x0D000000),
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
                  _InfoTile(icon: Icons.cake, label: 'Age', value: '${patient['age']} years'),
                  _InfoTile(icon: Icons.person_outline, label: 'Gender', value: patient['gender'] ?? 'N/A'),
                  _InfoTile(icon: Icons.phone, label: 'Phone', value: patient['phoneNumber'] ?? 'N/A'),
                  _InfoTile(icon: Icons.medical_services_outlined, label: 'Diseases', value: patient['chronicDiseases'] ?? 'None'),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient['fullName']}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await PatientService().deletePatient(patient['id']);
                if (context.mounted) {
                  context.read<AppState>().triggerDashboardRefresh();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Patient deleted successfully')),
                  );
                  context.go(AppRoutes.patients);
                }
              } catch (e) {
                if (context.mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('Error deleting patient: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
