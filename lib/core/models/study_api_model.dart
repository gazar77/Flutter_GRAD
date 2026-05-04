double _safeDouble(dynamic v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

int _safeInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString()) ?? 0;
}

DateTime? _safeDate(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  return DateTime.tryParse(v.toString());
}

/// Nested `analysisResults` row from backend `StudyDto`.
class AnalysisApiModel {
  final int id;
  final double stenosisPercentage;
  final String riskLevel;
  final String imagePath;
  final String arteryName;

  AnalysisApiModel({
    required this.id,
    required this.stenosisPercentage,
    required this.riskLevel,
    required this.imagePath,
    required this.arteryName,
  });

  factory AnalysisApiModel.fromJson(Map<String, dynamic> json) {
    return AnalysisApiModel(
      id: _safeInt(json['id']),
      stenosisPercentage: _safeDouble(json['stenosisPercentage']),
      riskLevel: json['riskLevel']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      arteryName: json['arteryName']?.toString() ?? '',
    );
  }
}

class StudyApiModel {
  final int id;
  final String filePath;
  final String status;
  final DateTime? uploadDate;
  final List<AnalysisApiModel> analysisResults;

  StudyApiModel({
    required this.id,
    required this.filePath,
    required this.status,
    this.uploadDate,
    List<AnalysisApiModel>? analysisResults,
  }) : analysisResults = analysisResults ?? [];

  factory StudyApiModel.fromJson(Map<String, dynamic> json) {
    final list = json['analysisResults'];
    List<AnalysisApiModel> analyses = [];
    if (list is List) {
      for (final e in list) {
        if (e is Map<String, dynamic>) {
          analyses.add(AnalysisApiModel.fromJson(e));
        }
      }
    }
    return StudyApiModel(
      id: _safeInt(json['id']),
      filePath: json['filePath']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      uploadDate: _safeDate(json['uploadDate']),
      analysisResults: analyses,
    );
  }
}
