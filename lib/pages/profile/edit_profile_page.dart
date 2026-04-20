import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/app_state.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/localization/app_localizations.dart';
import 'services/doctor_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController hospitalController;
  late TextEditingController specialtyController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController extensionController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final appState = Provider.of<AppState>(context, listen: false);
    nameController = TextEditingController(text: appState.doctorName);
    hospitalController = TextEditingController(text: appState.doctorHospital);
    specialtyController = TextEditingController(text: appState.doctorSpecialty);
    emailController = TextEditingController(text: appState.doctorEmail);
    phoneController = TextEditingController(text: appState.doctorPhone);
    extensionController = TextEditingController(text: appState.doctorExtension);
  }

  @override
  void dispose() {
    nameController.dispose();
    hospitalController.dispose();
    specialtyController.dispose();
    emailController.dispose();
    phoneController.dispose();
    extensionController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);
    final success = await DoctorService().updateProfile(
      name: nameController.text,
      hospital: hospitalController.text,
      title: specialtyController.text,
      mobile: phoneController.text,
      extension: extensionController.text,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.read<AppState>().updateDoctorProfile(
        name: nameController.text,
        hospital: hospitalController.text,
        specialty: specialtyController.text,
        email: emailController.text,
        phone: phoneController.text,
        extension: extensionController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('profile_updated'.tr(context, listen: false))));
      if (context.canPop()) { context.pop(); } else { context.go('/home'); }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('edit_profile'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            AppCard(
              child: Column(
                children: [
                  AppTextField(label: 'name'.tr(context), controller: nameController, prefixIcon: Icons.person_outline_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'specialty'.tr(context), controller: specialtyController, prefixIcon: Icons.work_outline_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'hospital'.tr(context), controller: hospitalController, prefixIcon: Icons.business_rounded),
                  const SizedBox(height: 16),
                  AppTextField(label: 'email'.tr(context), controller: emailController, prefixIcon: Icons.email_outlined, readOnly: true),
                  const SizedBox(height: 16),
                  AppTextField(label: 'phone'.tr(context), controller: phoneController, prefixIcon: Icons.phone_outlined),
                  const SizedBox(height: 16),
                  AppTextField(label: 'extension'.tr(context), controller: extensionController, prefixIcon: Icons.call_split_rounded),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'save_changes'.tr(context),
              isLoading: _isSaving,
              onPressed: _saveProfile,
            ),
          ],
        ),
      ),
    );
  }
}
