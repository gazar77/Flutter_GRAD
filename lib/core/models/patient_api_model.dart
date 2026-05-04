import 'study_api_model.dart';

int _patientSafeInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

DateTime? _patientSafeDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

/// Matches backend `Areas.Doctor.PatientRequest` JSON.
class PatientApiModel {
  final int id;
  final String fullName;
  final int? age;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? phoneNumber;
  final String? medicalRecordNumber;
  final String? notes;
  final String? chronicDiseases;
  final DateTime? createdAt;
  final List<StudyApiModel> studies;

  PatientApiModel({
    required this.id,
    required this.fullName,
    this.age,
    this.dateOfBirth,
    this.gender,
    this.phoneNumber,
    this.medicalRecordNumber,
    this.notes,
    this.chronicDiseases,
    this.createdAt,
    List<StudyApiModel>? studies,
  }) : studies = studies ?? [];

  factory PatientApiModel.fromJson(Map<String, dynamic> json) {
    final studiesJson = json['studies'];
    List<StudyApiModel> list = [];
    if (studiesJson is List) {
      for (final e in studiesJson) {
        if (e is Map<String, dynamic>) {
          list.add(StudyApiModel.fromJson(e));
        }
      }
    }

    return PatientApiModel(
      id: _patientSafeInt(json['id']),
      fullName: json['fullName']?.toString() ?? '',
      age: _parseAge(json['age']),
      dateOfBirth: _patientSafeDate(json['dateOfBirth']),
      gender: json['gender']?.toString(),
      phoneNumber: json['phoneNumber']?.toString(),
      medicalRecordNumber: json['medicalRecordNumber']?.toString(),
      notes: json['notes']?.toString(),
      chronicDiseases: json['chronicDiseases']?.toString(),
      createdAt: _patientSafeDate(json['createdAt']),
      studies: list,
    );
  }

  static int? _parseAge(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
