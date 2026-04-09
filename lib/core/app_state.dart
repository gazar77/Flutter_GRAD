import 'dart:io';
import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

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

  void setProfileImage(File file) {
    _profileImageFile = file;
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
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
    if (name != null) _doctorName = name;
    if (specialty != null) _doctorSpecialty = specialty;
    if (hospital != null) _doctorHospital = hospital;
    if (email != null) _doctorEmail = email;
    if (phone != null) _doctorPhone = phone;
    if (extension != null) _doctorExtension = extension;
    notifyListeners();
  }
}
