import 'package:flutter/material.dart';

class AppColors {
  // Primary Medical Navy Palette
  static const Color primary = Color(0xFF1E3A8A); // Deeper, more professional navy
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1E3A5F);

  // Secondary & Accents
  static const Color secondary = Color(0xFF64748B); // Slate grey
  static const Color accent = Color(0xFF0EA5E9); // Sky blue accent
  
  // Backgrounds
  static const Color background = Color(0xFFF8FAFC);
  static const Color cardBg = Colors.white;
  static const Color surface = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Almost black
  static const Color textSecondary = Color(0xFF475569); // Medium grey-slate
  static const Color textMuted = Color(0xFF94A3B8); // Light grey-slate

  // Status Colors
  static const Color danger = Color(0xFFE11D48);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Dark Mode Palette - Deep Medical Navy
  static const Color backgroundDark = Color(0xFF0F172A); // Very deep navy
  static const Color surfaceDark = Color(0xFF1E293B);    // Slate surface
  static const Color cardBgDark = Color(0xFF1E293B);     // Slightly lighter than bg
  static const Color textPrimaryDark = Color(0xFFF1F5F9); // Crisp off-white
  static const Color textSecondaryDark = Color(0xFF94A3B8); // Slate grey secondary

  // Common UI Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color transparent = Colors.transparent;

  // Gradients
  static const List<Color> primaryGradient = [Color(0xFF1E3A8A), Color(0xFF3B82F6)];
}