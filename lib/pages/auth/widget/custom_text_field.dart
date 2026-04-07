import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String hint;
  final bool isPassword;

  const CustomTextField({
    super.key,
    required this.hint,
    this.isPassword = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      obscureText: widget.isPassword ? obscure : false,
      decoration: InputDecoration(
        hintText: widget.hint,
        filled: true,
        fillColor: Colors.grey.shade200,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
              )
            : null,
      ),
    );
  }
}