import '../models/home_data_model.dart';

class HomeService {
  Future<HomeDataModel> getHomeData() async {
    await Future.delayed(const Duration(seconds: 1));

    final Map<String, dynamic> response = {
      "doctorName": "Ahmed",
      "doctorImage": null,
      "totalPatients": 160,
      "totalReports": 74,
      "recentAnalyses": [
        {
          "patientName": "Nora Ahmed",
          "stenosisPercent": 75,
          "date": "12 May"
        },
        {
          "patientName": "Sara Hassan",
          "stenosisPercent": 60,
          "date": "10 May"
        },
        {
          "patientName": "Khaled Ahmed",
          "stenosisPercent": 30,
          "date": "8 May"
        },
        {
          "patientName": "Ahmed Ali",
          "stenosisPercent": 20,
          "date": "7 May"
        }
      ]
    };

    return HomeDataModel.fromJson(response);
  }
}