import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/routing/app_routes.dart';
import '../../core/networking/token_manager.dart';
import '../../core/services/biometric_service.dart';
import '../../core/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_card.dart';
import '../../core/localization/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool newAnalysisNotification = true;
  bool systemAlertsNotification = false;
  bool biometricsEnabled = false;
  bool isBiometricAvailable = false;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final available = await _biometricService.isBiometricAvailable();
    final enabled = await _biometricService.isBiometricsEnabled();
    if (mounted) {
      setState(() {
        isBiometricAvailable = available;
        biometricsEnabled = enabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        title: Text('settings'.tr(context)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () { if (context.canPop()) { context.pop(); } else { context.go('/home'); } },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSection(
              context,
              'security'.tr(context),
              [
                _buildSwitchTile(
                  context,
                  'biometric_setting'.tr(context),
                  Icons.fingerprint_rounded,
                  biometricsEnabled,
                  isBiometricAvailable,
                  (v) async {
                    await _biometricService.setBiometricsEnabled(v);
                    setState(() => biometricsEnabled = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'notifications'.tr(context),
              [
                _buildSwitchTile(
                  context,
                  'new_analysis'.tr(context),
                  Icons.analytics_rounded,
                  newAnalysisNotification,
                  true,
                  (v) => setState(() => newAnalysisNotification = v),
                ),
                const Divider(),
                _buildSwitchTile(
                  context,
                  'system_alerts'.tr(context),
                  Icons.notifications_active_rounded,
                  systemAlertsNotification,
                  true,
                  (v) => setState(() => systemAlertsNotification = v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'preferences'.tr(context),
              [
                _buildLanguageTile(context, appState),
                const Divider(),
                _buildSwitchTile(
                  context,
                  'dark_mode'.tr(context),
                  Icons.dark_mode_rounded,
                  appState.isDarkMode,
                  true,
                  (v) => appState.toggleDarkMode(v),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildSection(
              context,
              'support'.tr(context),
              [
                _buildLinkTile(context, 'help_center'.tr(context), Icons.help_outline_rounded, () {}),
                const Divider(),
                _buildLinkTile(context, 'about_app'.tr(context), Icons.info_outline_rounded, () {}),
              ],
            ),
            const SizedBox(height: 48),
            _buildLogoutButton(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    IconData icon,
    bool value,
    bool enabled,
    ValueChanged<bool> onChanged,
  ) {
    return ListTile(
      leading: Icon(icon, color: enabled ? AppColors.primary : AppColors.textMuted),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Switch.adaptive(
        value: value,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }

  Widget _buildLanguageTile(BuildContext context, AppState appState) {
    return ListTile(
      leading: const Icon(Icons.language_rounded, color: AppColors.primary),
      title: Text('language'.tr(context), style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            appState.locale == 'en' ? 'English' : 'العربية',
            style: const TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
        ],
      ),
      onTap: () => _showLanguageDialog(context, appState),
    );
  }

  Widget _buildLinkTile(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textMuted),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('language'.tr(context)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: appState.locale == 'en' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                appState.setLocale('en');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              trailing: appState.locale == 'ar' ? const Icon(Icons.check, color: AppColors.primary) : null,
              onTap: () {
                appState.setLocale('ar');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: () async {
          final router = GoRouter.of(context);
          final appState = context.read<AppState>();
          await TokenManager.clearToken();
          await appState.logout();
          router.go(AppRoutes.login);
        },
        icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
        label: Text(
          'logout'.tr(context),
          style: const TextStyle(color: AppColors.danger, fontWeight: FontWeight.bold),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.danger),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }
}
