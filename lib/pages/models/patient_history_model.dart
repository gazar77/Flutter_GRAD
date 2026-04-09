class PatientHistoryModel {
  final int id;
  final String fullName;
  final int age;
  final String gender;
  final String? phoneNumber;
  final String? chronicDiseases;
  final String? notes;
  final List<StudyModel> studies;

  PatientHistoryModel({
    required this.id,
    required this.fullName,
    required this.age,
    required this.gender,
    this.phoneNumber,
    this.chronicDiseases,
    this.notes,
    this.studies = const [],
  });

  factory PatientHistoryModel.fromJson(Map<String, dynamic> json) {
    return PatientHistoryModel(
      id: json['id'],
      fullName: json['fullName'],
      age: json['age'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      chronicDiseases: json['chronicDiseases'],
      notes: json['notes'],
      studies: (json['studies'] as List?)
              ?.map((e) => StudyModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class StudyModel {
  final int id;
  final DateTime uploadDate;
  final List<AnalysisResultModel> analysisResults;

  StudyModel({
    required this.id,
    required this.uploadDate,
    this.analysisResults = const [],
  });

  factory StudyModel.fromJson(Map<String, dynamic> json) {
    return StudyModel(
      id: json['id'],
      uploadDate: DateTime.parse(json['uploadDate']),
      analysisResults: (json['analysisResults'] as List?)
              ?.map((e) => AnalysisResultModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class AnalysisResultModel {
  final int id;
  final double stenosisPercentage;
  final String riskLevel;
  final String? imagePath;
  final String? arteryName;

  AnalysisResultModel({
    required this.id,
    required this.stenosisPercentage,
    required this.riskLevel,
    this.imagePath,
    this.arteryName,
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResultModel(
      id: json['id'],
      stenosisPercentage: (json['stenosisPercentage'] ?? 0.0).toDouble(),
      riskLevel: json['riskLevel'] ?? 'Unknown',
      imagePath: json['imagePath'],
      arteryName: json['arteryName'],
    );
  }
}