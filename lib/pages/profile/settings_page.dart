import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/routing/app_routes.dart';
import '../../core/networking/token_manager.dart';
import '../../core/services/biometric_service.dart';
import '../../core/app_state.dart';

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
    setState(() {
      isBiometricAvailable = available;
      biometricsEnabled = enabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: appState.isDarkMode ? const Color(0xFF1A1A1A) : const Color(0xFFF4F4F4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// GRADIENT HEADER
            Container(
              width: double.infinity,
              height: 140,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF1E3A5F), Color(0xFF3E6A9A)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.home);
                            }
                          },
                        ),
                        const Spacer(),
                      ],
                    ),
                    const Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ACCOUNT SETTINGS
                  _sectionHeader("ACCOUNT SETTINGS", appState.isDarkMode),
                  _settingsCard([
                    _settingsTile(
                      icon: Icons.person_search,
                      title: "Edit Profile",
                      onTap: () => context.push(AppRoutes.editProfile),
                      isDark: appState.isDarkMode,
                    ),
                    _settingsTile(
                      icon: Icons.lock_outline,
                      title: "Change Password",
                      onTap: () => context.push(AppRoutes.changePassword),
                      isDark: appState.isDarkMode,
                    ),
                    _settingsTile(
                      icon: Icons.email_outlined,
                      title: "Update Email",
                      onTap: () => context.push(AppRoutes.updateEmail),
                      isDark: appState.isDarkMode,
                    ),
                  ], appState.isDarkMode),

                  const SizedBox(height: 20),

                  /// SECURITY
                  _sectionHeader("SECURITY", appState.isDarkMode),
                  _settingsCard([
                    _switchTile(
                      icon: Icons.fingerprint,
                      title: "Biometric Login",
                      subtitle: isBiometricAvailable ? "Secure your access" : "Not available on this device",
                      value: biometricsEnabled,
                      enabled: isBiometricAvailable,
                      isDark: appState.isDarkMode,
                      onChanged: (v) async {
                        await _biometricService.setBiometricsEnabled(v);
                        setState(() => biometricsEnabled = v);
                      },
                    ),
                  ], appState.isDarkMode),

                  const SizedBox(height: 20),

                  /// NOTIFICATIONS
                  _sectionHeader("NOTIFICATIONS", appState.isDarkMode),
                  _settingsCard([
                    _switchTile(
                      icon: Icons.bar_chart,
                      title: "New Analysis Result",
                      value: newAnalysisNotification,
                      isDark: appState.isDarkMode,
                      onChanged: (v) =>
                          setState(() => newAnalysisNotification = v),
                    ),
                    _switchTile(
                      icon: Icons.warning_amber_rounded,
                      title: "System Alerts",
                      value: systemAlertsNotification,
                      isDark: appState.isDarkMode,
                      onChanged: (v) =>
                          setState(() => systemAlertsNotification = v),
                    ),
                  ], appState.isDarkMode),

                  const SizedBox(height: 20),

                  /// PREFERENCES
                  _sectionHeader("PREFERENCES", appState.isDarkMode),
                  _settingsCard([
                    _settingsTile(
                      icon: Icons.translate,
                      title: "Language (Arabic / English)",
                      onTap: () {},
                      isDark: appState.isDarkMode,
                    ),
                    _switchTile(
                      icon: Icons.dark_mode_outlined,
                      title: "Dark Mode",
                      value: appState.isDarkMode,
                      isDark: appState.isDarkMode,
                      onChanged: (v) => appState.toggleDarkMode(v),
                    ),
                  ], appState.isDarkMode),

                  const SizedBox(height: 20),

                  /// SUPPORT
                  _sectionHeader("SUPPORT", appState.isDarkMode),
                  _settingsCard([
                    _settingsTile(
                      icon: Icons.help_outline,
                      title: "Help Center",
                      onTap: () {},
                      isDark: appState.isDarkMode,
                    ),
                    _settingsTile(
                      icon: Icons.info_outline,
                      title: "About App",
                      onTap: () {},
                      isDark: appState.isDarkMode,
                    ),
                  ], appState.isDarkMode),

                  const SizedBox(height: 30),

                  /// LOGOUT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final router = GoRouter.of(context);
                        await TokenManager.clearToken();
                        router.go(AppRoutes.login);
                      },
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white70 : Colors.black54,
        ),
      ),
    );
  }

  Widget _settingsCard(List<Widget> children, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF2B4F7A), size: 22),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isDark ? Colors.white : Colors.black)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    bool enabled = true,
    required bool isDark,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FB),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: enabled ? const Color(0xFF2B4F7A) : Colors.grey, size: 22),
      ),
      title: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: enabled ? (isDark ? Colors.white : Colors.black) : Colors.grey)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? Colors.white54 : Colors.black54)) : null,
      trailing: Switch(
        value: value,
        onChanged: enabled ? onChanged : null,
        thumbColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0xFF2B4F7A);
          }
          return null;
        }),
        trackColor: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return const Color(0x802B4F7A);
          }
          return null;
        }),
      ),
    );
  }
}
