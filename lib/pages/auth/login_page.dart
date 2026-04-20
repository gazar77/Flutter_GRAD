import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/app_state.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/biometric_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/networking/dio_factory.dart';
import '../../core/networking/api_constants.dart';
import '../../core/networking/token_manager.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final BiometricService _biometricService = BiometricService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await AuthService().login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      if (mounted) {
        final userData = result['user'];
        if (userData != null) {
          final email = userData['email'];
          context.read<AppState>().updateDoctorProfile(
            name: userData['fullName'],
            email: email,
            specialty: userData['title'],
            hospital: userData['hospital'],
            phone: userData['mobile'],
            extension: userData['extension'],
          );
          if (email != null && email.isNotEmpty) {
            await context.read<AppState>().loadUserSettings(email);
          }
        }
        if (!mounted) return;
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        String errorKey = 'login_error';
        if (e.toString().contains('invalid_credentials')) {
          errorKey = 'invalid_credentials';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    errorKey.tr(context, listen: false),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(20),
            elevation: 0,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBiometricLogin() async {
    final bool canAuthenticate = await _biometricService.isBiometricAvailable();
    if (!canAuthenticate) return;

    final bool authenticated = await _biometricService.authenticate();
    if (authenticated) {
      final token = await TokenManager.getToken();
      if (token == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please login with password once to enable biometrics')),
          );
        }
        return;
      }

      setState(() => _isLoading = true);
      try {
        final dio = DioFactory.getDio();
        final response = await dio.get(ApiConstants.updateProfile);
        
        if (response.statusCode == 200 && mounted) {
          final userData = response.data;
          context.read<AppState>().updateDoctorProfile(
            name: userData['fullName'],
            email: userData['email'],
            specialty: userData['title'],
            hospital: userData['hospital'],
            phone: userData['mobile'],
            extension: userData['extension'],
          );
          context.go(AppRoutes.home);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Please login again.')),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/first_screen.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.favorite, size: 100, color: AppColors.danger),
                    ),
                  ),
                ).animate().fadeIn().scale(),
              ),
              const SizedBox(height: 40),
              Text(
                'welcome_back'.tr(context),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
              ).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text(
                'sign_in_dash'.tr(context),
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),
              AppTextField(
                label: 'email'.tr(context),
                hint: 'email_hint'.tr(context),
                controller: _emailController,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 20),
              AppTextField(
                label: 'password'.tr(context),
                hint: 'password_hint'.tr(context),
                controller: _passwordController,
                isPassword: true,
                prefixIcon: Icons.lock_outline_rounded,
              ).animate().fadeIn(delay: 300.ms),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.push(AppRoutes.forgetPassword),
                  child: Text(
                    'forgot_password'.tr(context),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 24),
              AppButton(
                text: 'login'.tr(context),
                isLoading: _isLoading,
                onPressed: _handleLogin,
              ).animate().fadeIn(delay: 500.ms).scale(),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'biometric_login'.tr(context),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: FutureBuilder<bool>(
                  future: _biometricService.isBiometricsEnabled(),
                  builder: (context, snapshot) {
                    if (snapshot.data == true) {
                      return IconButton(
                        icon: Icon(Icons.fingerprint_rounded, size: 48, color: Theme.of(context).colorScheme.primary),
                        onPressed: _handleBiometricLogin,
                      ).animate().shake();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('dont_have_account'.tr(context)),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.signup),
                    child: Text(
                      'sign_up'.tr(context),
                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}