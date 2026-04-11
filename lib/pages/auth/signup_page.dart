import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/app_state.dart';
import '../../core/routing/app_routes.dart';
import '../../core/services/auth_service.dart';
import 'widget/custom_text_field.dart';
import 'widget/social_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final specialtyController = TextEditingController();
  final hospitalController = TextEditingController();
  final phoneController = TextEditingController();
  final extensionController = TextEditingController();
  bool isAgree = false;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    specialtyController.dispose();
    hospitalController.dispose();
    phoneController.dispose();
    extensionController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, Email and Password are required')),
      );
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await AuthService().signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        confirmPassword: confirmPasswordController.text.trim(),
        title: specialtyController.text.trim().isNotEmpty
            ? specialtyController.text.trim()
            : null,
        hospital: hospitalController.text.trim().isNotEmpty
            ? hospitalController.text.trim()
            : null,
        mobile: phoneController.text.trim().isNotEmpty
            ? phoneController.text.trim()
            : null,
        extension: extensionController.text.trim().isNotEmpty
            ? extensionController.text.trim()
            : null,
      );

      // ✅ Populate AppState immediately with profile data
      if (mounted) {
        context.read<AppState>().updateDoctorProfile(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          specialty: specialtyController.text.trim().isNotEmpty
              ? specialtyController.text.trim()
              : null,
          hospital: hospitalController.text.trim().isNotEmpty
              ? hospitalController.text.trim()
              : null,
          phone: phoneController.text.trim().isNotEmpty
              ? phoneController.text.trim()
              : null,
          extension: extensionController.text.trim().isNotEmpty
              ? extensionController.text.trim()
              : null,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please log in.'),
          ),
        );
        context.go(AppRoutes.login);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.login);
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),
                const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 24),

                // ─── Account Info ─────────────────────────────────────
                const _SectionHeader(title: 'Account Information'),
                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Name'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Enter your Name',
                  controller: nameController,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email address'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Enter your Email Address',
                  controller: emailController,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Create Password',
                  isPassword: true,
                  controller: passwordController,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Confirm Password'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'Re-enter Password',
                  isPassword: true,
                  controller: confirmPasswordController,
                ),
                const SizedBox(height: 24),

                // ─── Doctor Profile ───────────────────────────────────
                const _SectionHeader(title: 'Doctor Profile (Optional)'),
                const SizedBox(height: 12),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Specialty'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'e.g. Cardiologist',
                  controller: specialtyController,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Hospital / Clinic'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'e.g. Dar Al Fouad Hospital',
                  controller: hospitalController,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Phone Number'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'e.g. +20 10 1234 5678',
                  controller: phoneController,
                ),
                const SizedBox(height: 16),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Extension'),
                ),
                const SizedBox(height: 6),
                CustomTextField(
                  hint: 'e.g. +20 10 2534 2435',
                  controller: extensionController,
                ),
                const SizedBox(height: 16),

                // ─── Agreement & Submit ───────────────────────────────
                Row(
                  children: [
                    Checkbox(
                      value: isAgree,
                      activeColor: primaryColor,
                      onChanged: (value) =>
                          setState(() => isAgree = value ?? false),
                    ),
                    const Expanded(
                      child: Text(
                        'I agree to the Terms & Conditions and Privacy Policy',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (isAgree && !isLoading) ? _handleSignup : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Sign up',
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                Row(
                  children: const [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text('or sign up with'),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    SocialButton(text: 'Facebook', icon: Icons.facebook),
                    SocialButton(text: 'Google', icon: Icons.g_mobiledata),
                  ],
                ),

                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account? '),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text(
                        'Log In',
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0x142B4F7A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Color(0xFF2B4F7A),
        ),
      ),
    );
  }
}