import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/routing/app_routes.dart';
import '../../core/app_state.dart';
import '../../core/networking/api_constants.dart';
import '../../core/networking/dio_factory.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_shimmer.dart';
import '../../core/localization/app_localizations.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int totalPatients = 0;
  int totalReports = 0;
  bool isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    try {
      final dio = DioFactory.getDio();
      final response = await dio.get(ApiConstants.dashboard);
      if (response.statusCode == 200 && mounted) {
        final data = response.data;
        context.read<AppState>().updateDoctorProfile(
          name: data['doctorName'],
          specialty: data['title'],
          hospital: data['hospital'],
          phone: data['mobile'],
          extension: data['extension'],
        );
        setState(() {
          totalPatients = data['totalPatients'] ?? 0;
          totalReports = data['totalReports'] ?? 0;
          isLoadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoadingStats = false);
    }
  }

  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null && mounted) {
      context.read<AppState>().setProfileImage(File(image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('profile'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildProfileCard(appState),
            const SizedBox(height: 24),
            _buildStatsSection(),
            const SizedBox(height: 24),
            _buildInfoCard(appState),
            const SizedBox(height: 32),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(AppState appState) {
    return AppCard(
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.primary, width: 2)),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.secondary.withValues(alpha: 0.1),
                    backgroundImage: appState.profileImageFile != null
                        ? FileImage(appState.profileImageFile!)
                        : const NetworkImage('https://i.pravatar.cc/300?img=12') as ImageProvider,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: const Icon(Icons.camera_alt_rounded, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(appState.doctorName, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(appState.doctorSpecialty, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
          Text(appState.doctorHospital, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    ).animate().fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _buildStatItem('patients'.tr(context), totalPatients.toString(), Icons.people_rounded)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('reports'.tr(context), totalReports.toString(), Icons.analytics_rounded)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return AppCard(
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(height: 8),
          isLoadingStats ? const AppShimmer(width: 40, height: 24) : Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20)),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildInfoCard(AppState appState) {
    return AppCard(
      child: Column(
        children: [
          _buildDetailRow('email'.tr(context), appState.doctorEmail, Icons.email_outlined),
          const Divider(height: 32),
          _buildDetailRow('phone'.tr(context), appState.doctorPhone, Icons.phone_outlined),
          const Divider(height: 32),
          _buildDetailRow('extension'.tr(context), appState.doctorExtension, Icons.call_split_rounded),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        AppButton(
          text: 'edit_profile'.tr(context),
          icon: Icons.edit_rounded,
          onPressed: () => context.push(AppRoutes.editProfile),
        ),
        const SizedBox(height: 12),
        AppButton(
          text: 'settings'.tr(context),
          icon: Icons.settings_rounded,
          variant: AppButtonVariant.outline,
          onPressed: () => context.push(AppRoutes.settings),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }
}