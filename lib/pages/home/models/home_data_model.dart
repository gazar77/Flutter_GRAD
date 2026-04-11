class HomeDataModel {
  final String doctorName;
  final String? doctorImage;
  final String? hospital;
  final String? title;
  final String? mobile;
  final String? extension;
  final int totalPatients;
  final int totalReports;
  final List<AnalysisItemModel> recentAnalyses;
  final String? error;

  HomeDataModel({
    required this.doctorName,
    this.doctorImage,
    this.hospital,
    this.title,
    this.mobile,
    this.extension,
    required this.totalPatients,
    required this.totalReports,
    required this.recentAnalyses,
    this.error,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      doctorName: (json['doctorName'] ?? json['DoctorName'] ?? '').toString(),
      doctorImage: (json['doctorImage'] ?? json['DoctorImage'])?.toString(),
      hospital: (json['hospital'] ?? json['Hospital'])?.toString(),
      title: (json['title'] ?? json['Title'])?.toString(),
      mobile: (json['mobile'] ?? json['Mobile'])?.toString(),
      extension: (json['extension'] ?? json['Extension'])?.toString(),
      totalPatients: _asInt(json['totalPatients'] ?? json['TotalPatients']),
      totalReports: _asInt(json['totalReports'] ?? json['TotalReports']),
      recentAnalyses: (json['recentAnalyses'] as List? ?? json['RecentAnalyses'] as List? ?? [])
          .map((e) => AnalysisItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      error: (json['error'] ?? json['Error'])?.toString(),
    );
  }

  static int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}

class AnalysisItemModel {
  final String? id;
  final String patientName;
  final int? age;
  final String? gender;
  final int stenosisPercent;
  final String artery;
  final String? riskLevel;
  final String? diagnosisDetails;
  final String? image1;
  final String? image2;
  final String date;

  AnalysisItemModel({
    this.id,
    required this.patientName,
    this.age,
    this.gender,
    required this.stenosisPercent,
    required this.artery,
    this.riskLevel,
    this.diagnosisDetails,
    this.image1,
    this.image2,
    required this.date,
  });

  factory AnalysisItemModel.fromJson(Map<String, dynamic> json) {
    return AnalysisItemModel(
      id: (json['id'] ?? json['Id'])?.toString(),
      patientName: (json['patientName'] ?? json['PatientName'] ?? '').toString(),
      age: _asInt(json['age'] ?? json['Age']),
      gender: (json['gender'] ?? json['Gender'])?.toString(),
      stenosisPercent: _asIntRequired(json['stenosisPercent'] ?? json['StenosisPercent']),
      artery: (json['artery'] ?? json['Artery'] ?? 'N/A').toString(),
      riskLevel: (json['riskLevel'] ?? json['RiskLevel'])?.toString(),
      diagnosisDetails: (json['diagnosisDetails'] ?? json['DiagnosisDetails'])?.toString(),
      image1: (json['image1'] ?? json['Image1'])?.toString(),
      image2: (json['image2'] ?? json['Image2'])?.toString(),
      date: (json['date'] ?? json['Date'] ?? '').toString(),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static int _asIntRequired(dynamic value) {
    return _asInt(value) ?? 0;
  }
}