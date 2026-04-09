import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../../core/networking/api_constants.dart';
import '../../../core/networking/dio_factory.dart';
import '../models/home_data_model.dart';

class HomeService {
  final Dio _dio = DioFactory.getDio();

  Future<HomeDataModel> getHomeData() async {
    try {
      final response = await _dio.get(ApiConstants.dashboard);
      debugPrint('DEBUG: Home Data success: ${response.data}');
      return HomeDataModel.fromJson(response.data);
    } catch (e) {
      debugPrint('DEBUG: Home Data error: $e');
      
      // Return empty model instead of throwing — keeps UI usable even without login
      return HomeDataModel(
        doctorName: '',
        doctorImage: null,
        totalPatients: 0,
        totalReports: 0,
        recentAnalyses: [],
      );
    }
  }
}