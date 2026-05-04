/// Response shape from `GET/POST api/Doctor/Analysis/{studyId}`.
class AnalysisResultApiModel {
  final int studyId;
  final double stenosisPercentage;
  final String report;
  final String imagePath;
  final String arteryName;
  final String riskLevel;
  final String diagnosisDetails;
  final String patientName;

  const AnalysisResultApiModel({
    this.studyId = 0,
    this.stenosisPercentage = 0,
    this.report = '',
    this.imagePath = '',
    this.arteryName = '',
    this.riskLevel = '',
    this.diagnosisDetails = '',
    this.patientName = '',
  });

  factory AnalysisResultApiModel.fromJson(Map<String, dynamic> json) {
    final stRaw = json['stenosisPercentage'] ?? 0;
    final stNum = stRaw is num ? stRaw.toDouble() : double.tryParse(stRaw.toString()) ?? 0.0;

    return AnalysisResultApiModel(
      studyId: _parseInt(json['studyId']),
      stenosisPercentage: stNum,
      report: json['report']?.toString() ?? '',
      imagePath: json['imagePath']?.toString() ?? '',
      arteryName: json['arteryName']?.toString() ?? '',
      riskLevel: json['riskLevel']?.toString() ?? '',
      diagnosisDetails: json['diagnosisDetails']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toPdfReportPayload({
    String? patientAge,
    String? patientGender,
    String? caseId,
  }) {
    return {
      'id': caseId ?? studyId.toString(),
      'name': patientName,
      'patientName': patientName,
      'stenosisPercent': stenosisPercentage,
      'stenosis': stenosisPercentage,
      'artery': arteryName,
      'riskLevel': riskLevel,
      'diagnosisDetails': diagnosisDetails.isNotEmpty ? diagnosisDetails : report,
      'notes': report.isNotEmpty ? report : diagnosisDetails,
      'image1': imagePath.isNotEmpty ? imagePath : null,
      'image2': null,
      'age': patientAge ?? '',
      'gender': patientGender ?? '',
      'date': DateTime.now().toString().split(' ').first,
    };
  }

  static int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}
