import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/routing/app_routes.dart';
import '../../core/app_state.dart';

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

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage('https://i.pravatar.cc/300?img=12'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {},
              child: const Text('Change Photo'),
            ),
            const SizedBox(height: 20),
            _inputField('Full Name', nameController),
            const SizedBox(height: 12),
            _inputField('Hospital', hospitalController),
            const SizedBox(height: 12),
            _inputField('Specialty', specialtyController),
            const SizedBox(height: 12),
            _inputField('Email', emailController),
            const SizedBox(height: 12),
            _inputField('Phone', phoneController),
            const SizedBox(height: 12),
            _inputField('Extension', extensionController),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  context.read<AppState>().updateDoctorProfile(
                        name: nameController.text,
                        hospital: hospitalController.text,
                        specialty: specialtyController.text,
                        email: emailController.text,
                        phone: phoneController.text,
                        extension: extensionController.text,
                      );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile updated successfully')),
                  );

                  if (context.mounted) {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.profile);
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}
