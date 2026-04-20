import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
              onPressed: () async {
                setState(() => _isLoading = true);
                await Future.delayed(const Duration(seconds: 1)); // Simulate API
                if (!context.mounted) return;
                setState(() => _isLoading = false);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('password_changed'.tr(context, listen: false))));
                if (context.canPop()) { context.pop(); } else { context.go('/home'); }
              },
            ),
          ],
        ),
      ),
    );
  }
}
