import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const String _profileImagePathKey = 'profile_image_path';
  static const String _isDarkModeKey = 'is_dark_mode';
  static const String _localeKey = 'app_locale';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _locale = 'en';
  String get locale => _locale;

  File? _profileImageFile;
  String _doctorName = '';
  String _doctorSpecialty = '';
  String _doctorHospital = '';
  String _doctorEmail = '';
  String _doctorPhone = '';
  String _doctorExtension = '';

  File? get profileImageFile => _profileImageFile;
  String get doctorName => _doctorName;
  String get doctorSpecialty => _doctorSpecialty;
  String get doctorHospital => _doctorHospital;
  String get doctorEmail => _doctorEmail;
  String get doctorPhone => _doctorPhone;
  String get doctorExtension => _doctorExtension;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load Global Settings
    _isDarkMode = prefs.getBool(_isDarkModeKey) ?? false;
    _locale = prefs.getString(_localeKey) ?? 'en';

    notifyListeners();
  }

  Future<void> loadUserSettings(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final userKey = '${_profileImagePathKey}_$email';
    final path = prefs.getString(userKey);
    
    if (path != null && File(path).existsSync()) {
      _profileImageFile = File(path);
    } else {
      _profileImageFile = null;
    }
    notifyListeners();
  }

  Future<void> setProfileImage(File file) async {
    _profileImageFile = file;
    notifyListeners();
    
    if (_doctorEmail.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final userKey = '${_profileImagePathKey}_$_doctorEmail';
      await prefs.setString(userKey, file.path);
    }
  }

  void setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  Future<void> toggleDarkMode(bool value) async {
    if (_isDarkMode == value) return;
    _isDarkMode = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, value);
  }

  Future<void> setLocale(String code) async {
    if (_locale == code) return;
    _locale = code;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, code);
  }

  void updateDoctorProfile({
    String? name,
    String? specialty,
    String? hospital,
    String? email,
    String? phone,
    String? extension,
  }) {
    bool changed = false;
    if (name != null && name != _doctorName) { _doctorName = name; changed = true; }
    if (specialty != null && specialty != _doctorSpecialty) { _doctorSpecialty = specialty; changed = true; }
    if (hospital != null && hospital != _doctorHospital) { _doctorHospital = hospital; changed = true; }
    if (email != null && email != _doctorEmail) { _doctorEmail = email; changed = true; }
    if (phone != null && phone != _doctorPhone) { _doctorPhone = phone; changed = true; }
    if (extension != null && extension != _doctorExtension) { _doctorExtension = extension; changed = true; }
    
    if (changed) {
      notifyListeners();
    }
  }

  void triggerDashboardRefresh() {
    notifyListeners();
  }

  Future<void> logout() async {
    // Reset memory state only
    _profileImageFile = null;
    _doctorName = '';
    _doctorSpecialty = '';
    _doctorHospital = '';
    _doctorEmail = '';
    _doctorPhone = '';
    _doctorExtension = '';
    
    // Do NOT remove from SharedPreferences to allow persistence for next time this user logs in
    notifyListeners();
  }
}
