import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/routing/app_routes.dart';
import 'widget/custom_text_field.dart';
import 'widget/social_button.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool isAgree = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),

                /// 🔙 Back Button
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                  ],
                ),

                /// Title
                const Text(
                  'Sign up',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2B4F7A),
                  ),
                ),

                const SizedBox(height: 30),

                /// Name
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Name'),
                ),
                const SizedBox(height: 8),
                CustomTextField(hint: 'Enter your Name'),

                const SizedBox(height: 20),

                /// Email or Phone
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Email or Phone'),
                ),
                const SizedBox(height: 8),
                CustomTextField(hint: 'Enter your Email / Phone'),

                const SizedBox(height: 20),

                /// Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Password'),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Create Password',
                  isPassword: true,
                ),

                const SizedBox(height: 20),

                /// Confirm Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Confirm Password'),
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  hint: 'Re-enter Password',
                  isPassword: true,
                ),

                const SizedBox(height: 16),

                /// ✅ Checkbox
                Row(
                  children: [
                    Checkbox(
                      value: isAgree,
                      activeColor: const Color(0xFF2B4F7A),
                      onChanged: (value) {
                        setState(() {
                          isAgree = value ?? false;
                        });
                      },
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

                /// 🚀 Sign Up Button (يرجع Login)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: isAgree
                        ? () {
                            context.go(AppRoutes.login);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2B4F7A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Divider
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

                /// Social Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    SocialButton(
                      text: 'Facebook',
                      icon: Icons.facebook,
                    ),
                    SocialButton(
                      text: 'Google',
                      icon: Icons.g_mobiledata,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                /// 🔁 Go to Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        context.go(AppRoutes.login);
                      },
                      child: const Text(
                        "Log In",
                        style: TextStyle(
                          color: Color(0xFF2B4F7A),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}