import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fp/core/routing/app_routes.dart';
import 'package:fp/core/services/auth_service.dart';

/// Backend sends a **6-digit** OTP (see HeartCathAPI AuthService.SendOtpAsync).
class VerifyCodePage extends StatefulWidget {
  /// Email carried from [ForgetPasswordPage] via router `extra`.
  final String email;

  const VerifyCodePage({super.key, required this.email});

  @override
  State<VerifyCodePage> createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  static const int _digits = 6;

  late final List<TextEditingController> _controllers =
      List.generate(_digits, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes = List.generate(_digits, (_) => FocusNode());

  int seconds = 60;
  Timer? timer;
  bool _verifying = false;
  bool _resending = false;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (seconds == 0) {
        t.cancel();
      } else {
        if (mounted) {
          setState(() {
            seconds--;
          });
        }
      }
    });
  }

  String get _code => _controllers.map((e) => e.text.trim()).join();

  Future<void> _verifyCode() async {
    final email = widget.email.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing email — go back and request a reset code.')),
      );
      return;
    }

    final code = _code;
    if (code.length != _digits) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter all $_digits digits')),
      );
      return;
    }

    setState(() => _verifying = true);
    final result = await AuthService().verifyOtp(email, code);
    if (!mounted) return;
    setState(() => _verifying = false);

    if (result.success) {
      context.go(AppRoutes.createNewPassword, extra: {'email': email.toLowerCase(), 'otp': code});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    }
  }

  Future<void> _resendCode() async {
    final email = widget.email.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Go back and enter your email.')),
      );
      return;
    }

    setState(() => _resending = true);
    final result = await AuthService().forgotPassword(email);
    if (!mounted) return;
    setState(() => _resending = false);

    if (!result.success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result.message)));
    setState(() {
      seconds = 60;
      for (final c in _controllers) {
        c.clear();
      }
    });
    startTimer();
    FocusScope.of(context).requestFocus(_focusNodes[0]);
  }

  @override
  void dispose() {
    timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF2B4F7A);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - 40,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(AppRoutes.forgetPassword);
                            }
                          },
                          icon: const Icon(Icons.arrow_back),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Verify Code',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.email.isNotEmpty
                            ? 'Enter the 6-digit code sent to\n${widget.email}'
                            : 'Enter the 6-digit code sent to your email',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(_digits, (index) {
                        return _OtpBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (value) {
                            if (value.isNotEmpty && index < _digits - 1) {
                              FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                            }
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      seconds > 0 ? 'Code expires in $seconds seconds' : 'Code expired',
                      style: const TextStyle(color: Colors.black54),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: (seconds == 0 && !_resending) ? _resendCode : null,
                      child: Text(
                        _resending ? 'Sending…' : 'Resend Code',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          decoration: seconds == 0 ? TextDecoration.underline : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        context.go(AppRoutes.forgetPassword);
                      },
                      child: const Text(
                        'Change Email',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _verifying ? null : _verifyCode,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _verifying
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                'Verify Code',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7E7F5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: primaryColor,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Verification helps us protect your account',
                              style: TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFF2B4F7A),
                width: 1,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                ),
              ],
            ),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: const TextStyle(fontSize: 22),
              decoration: const InputDecoration(
                counterText: '',
                border: InputBorder.none,
                contentPadding: EdgeInsets.only(bottom: 8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
