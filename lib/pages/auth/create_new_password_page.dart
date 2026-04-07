import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateNewPasswordPage extends StatefulWidget {
  const CreateNewPasswordPage({super.key});

  @override
  State<CreateNewPasswordPage> createState() =>
      _CreateNewPasswordPageState();
}

class _CreateNewPasswordPageState extends State<CreateNewPasswordPage> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isObscure = true;

  bool hasMinLength = false;
  bool hasNumber = false;
  bool hasSpecial = false;

  String strength = "Weak";

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

  Color getStrengthColor() {
    if (strength == "Strong") return Colors.green;
    if (strength == "Medium") return Colors.orange;
    return Colors.red;
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
              /// Header
              Container(
                width: double.infinity,
                color: const Color(0xFFDCE7F2),
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () {
                        context.pop();
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
                    /// Password field
                    TextField(
                      controller: passwordController,
                      obscureText: isObscure,
                      onChanged: checkPassword,
                      decoration: InputDecoration(
                        hintText: "Enter new password",
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isObscure
                                ? Icons.visibility_off
                                : Icons.visibility,
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

                    /// Strength bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _StrengthBar(
                            color: Colors.red,
                            active: strength == "Weak" ||
                                strength == "Medium" ||
                                strength == "Strong"),
                        _StrengthBar(
                            color: Colors.orange,
                            active: strength == "Medium" ||
                                strength == "Strong"),
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
                        Text("Medium",
                            style: TextStyle(color: Colors.orange)),
                        Text("Strong",
                            style: TextStyle(color: Colors.green)),
                      ],
                    ),

                    const SizedBox(height: 15),

                    /// Conditions
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

                    /// Confirm password
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

                    /// Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // next step
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Reset Password",
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// Info box
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