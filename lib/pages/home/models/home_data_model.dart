class HomeDataModel {
  final String doctorName;
  final String? doctorImage;
  final int totalPatients;
  final int totalReports;
  final List<AnalysisItemModel> recentAnalyses;

  HomeDataModel({
    required this.doctorName,
    required this.doctorImage,
    required this.totalPatients,
    required this.totalReports,
    required this.recentAnalyses,
  });

  factory HomeDataModel.fromJson(Map<String, dynamic> json) {
    return HomeDataModel(
      doctorName: json['doctorName'] ?? json['DoctorName'] ?? '',
      doctorImage: json['doctorImage'] ?? json['DoctorImage'],
      totalPatients: (json['totalPatients'] ?? json['TotalPatients'] ?? 0) as int,
      totalReports: (json['totalReports'] ?? json['TotalReports'] ?? 0) as int,
      recentAnalyses: (json['recentAnalyses'] ?? json['RecentAnalyses'] as List<dynamic>? ?? [])
          .map((e) => AnalysisItemModel.fromJson(e))
          .toList(),
    );
  }
}

class AnalysisItemModel {
  final String patientName;
  final int stenosisPercent;
  final String date;

  AnalysisItemModel({
    required this.patientName,
    required this.stenosisPercent,
    required this.date,
  });

  factory AnalysisItemModel.fromJson(Map<String, dynamic> json) {
    return AnalysisItemModel(
      patientName: json['patientName'] ?? json['PatientName'] ?? '',
      stenosisPercent: json['stenosisPercent'] ?? json['StenosisPercent'] ?? 0,
      date: json['date'] ?? json['Date'] ?? '',
    );
  }
}