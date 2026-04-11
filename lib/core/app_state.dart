import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState extends ChangeNotifier {
  static const String _profileImagePathKey = 'profile_image_path';

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

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

  Future<void> loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(_profileImagePathKey);
    if (path != null && File(path).existsSync()) {
      _profileImageFile = File(path);
      notifyListeners();
    }
  }

  Future<void> setProfileImage(File file) async {
    _profileImageFile = file;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileImagePathKey, file.path);
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void toggleDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
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
}
