import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_routes.dart';
import '../../core/services/auth_service.dart';

class CreateNewPasswordPage extends StatefulWidget {
  final String email;
  final String otp;

  const CreateNewPasswordPage({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<CreateNewPasswordPage> createState() => _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isObscure = true;

  bool hasMinLength = false;
  bool hasNumber = false;
  bool hasSpecial = false;

  String strength = "Weak";
  bool _isSubmitting = false;

  void checkPassword(String value) {
    setState(() {
      hasMinLength = value.length >= 8;
      hasNumber = RegExp(r'[0-9]').hasMatch(value);
      hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value);

      if (hasMinLength && hasNumber && hasSpecial) {
        strength = "Strong";
      } else if (hasMinLength && hasNumber) {
        strength = "Medium";
      } else {
        strength = "Weak";
      }
    });
  }

  Future<void> _resetPassword() async {
    final email = widget.email.trim();
    final otp = widget.otp.trim();
    if (email.isEmpty || otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired — start again from Forgot Password')),
      );
      context.go(AppRoutes.forgetPassword);
      return;
    }

    if (!hasMinLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be at least 8 characters')),
      );
      return;
    }

    if (passwordController.text != confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final result = await AuthService().resetPassword(
      email: email,
      otp: otp,
      newPassword: passwordController.text,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      context.go(AppRoutes.login);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: const Color(0xFFDCE7F2),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.verifyCode, extra: {'email': widget.email});
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const Text(
                      'Create New Password',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'choose a new strong password to secure your account',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: passwordController,
                      obscureText: isObscure,
                      onChanged: checkPassword,
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              isObscure = !isObscure;
                            });
                          },
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StrengthBar(
                            color: Colors.red,
                            active: strength == "Weak" || strength == "Medium" || strength == "Strong"),
                        _StrengthBar(
                            color: Colors.orange,
                            active: strength == "Medium" || strength == "Strong"),
                        _StrengthBar(
                            color: Colors.green,
                            active: strength == "Strong"),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text("Weak", style: TextStyle(color: Colors.red)),
                        Text("Medium", style: TextStyle(color: Colors.orange)),
                        Text("Strong", style: TextStyle(color: Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    _ConditionItem(
                      text: "At least 8 characters",
                      valid: hasMinLength,
                    ),
                    _ConditionItem(
                      text: "Include numbers",
                      valid: hasNumber,
                    ),
                    _ConditionItem(
                      text: "Include special characters",
                      valid: hasSpecial,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: confirmController,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: "Confirm Password",
                        prefixIcon: const Icon(Icons.lock),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _resetPassword,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Reset Password",
                                style: TextStyle(fontSize: 18),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7E7F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user_outlined),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Your password will be updated after confirmation",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/// Strength bar
class _StrengthBar extends StatelessWidget {
  final Color color;
  final bool active;

  const _StrengthBar({required this.color, required this.active});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        height: 5,
        decoration: BoxDecoration(
          color: active ? color : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// Condition item
class _ConditionItem extends StatelessWidget {
  final String text;
  final bool valid;

  const _ConditionItem({required this.text, required this.valid});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          valid ? Icons.check_circle : Icons.cancel,
          color: valid ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }
}
