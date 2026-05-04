import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/auth_service.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/localization/app_localizations.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    oldPassController.dispose();
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (newPassController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New password must be at least 8 characters')),
      );
      return;
    }
    if (newPassController.text != confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await AuthService().changePassword(
      oldPassword: oldPassController.text,
      newPassword: newPassController.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    if (result.success && context.mounted) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/home');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('change_password'.tr(context)),
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
                  AppTextField(
                    label: 'current_password'.tr(context),
                    controller: oldPassController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'new_password'.tr(context),
                    controller: newPassController,
                    isPassword: true,
                    prefixIcon: Icons.lock_reset_rounded,
                  ),
                  const SizedBox(height: 20),
                  AppTextField(
                    label: 'confirm_password'.tr(context),
                    controller: confirmPassController,
                    isPassword: true,
                    prefixIcon: Icons.check_circle_outline_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              text: 'change_password'.tr(context),
              isLoading: _isLoading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
