import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/services/patient_service.dart';
import 'package:fp/core/networking/api_error_handler.dart';
import 'package:fp/core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage> {
  late Future<List<dynamic>> _patientsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _patientsFuture = PatientService().getAllPatients();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('manage_patients'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => context.push(AppRoutes.addPatient),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'search_hint'.tr(context),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
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

                final filtered = snapshot.data!.where((p) {
                  final name = (p['fullName'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery);
                }).toList();

                return ListView.builder(
                  itemCount: filtered.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final patient = filtered[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(Icons.person_rounded, color: theme.colorScheme.primary),
                        ),
                        title: Text(
                          patient['fullName'] ?? 'Unknown',
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${'age'.tr(context)}: ${patient['age']} | ${patient['gender']}',
                          style: theme.textTheme.bodySmall,
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit_rounded, color: theme.colorScheme.primary, size: 20),
                              onPressed: () async {
                                await context.push(AppRoutes.editPatient, extra: patient);
                                if (mounted) {
                                  setState(() {
                                    _patientsFuture = PatientService().getAllPatients();
                                  });
                                }
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete_outline_rounded, color: AppColors.danger, size: 20),
                              onPressed: () => _showDeleteDialog(patient),
                            ),
                          ],
                        ),
                        onTap: () {
                          context.push(AppRoutes.patientProfile, extra: patient);
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(dynamic patient) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Patient'),
        content: Text('Are you sure you want to delete ${patient['fullName']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await PatientService().deletePatient(patient['id']);
                if (mounted) {
                  messenger.showSnackBar(
                    SnackBar(content: Text('delete_patient_success'.tr(context, listen: false))),
                  );
                  setState(() {
                    _patientsFuture = PatientService().getAllPatients();
                  });
                }
              } catch (e) {
                if (mounted) {
                  final message = ApiErrorHandler.getMessage(e, context);
                  messenger.showSnackBar(
                    SnackBar(content: Text(message)),
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
