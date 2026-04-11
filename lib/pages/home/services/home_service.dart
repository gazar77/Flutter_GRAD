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
      debugPrint('DEBUG: Home Data RAW: ${response.data}');
      debugPrint('DEBUG: Home Data TYPE: ${response.data.runtimeType}');
      return HomeDataModel.fromJson(response.data);
    } catch (e, stack) {
      debugPrint('ERROR: Home Data fetch failed: $e');
      debugPrint('STACKTRACE: $stack');
      
      // If the error is a DioException, log more details
      if (e is DioException) {
        debugPrint('DIO_ERROR: Status=${e.response?.statusCode}, Data=${e.response?.data}');
      }
      
      return HomeDataModel(
        doctorName: 'Error Loading',
        doctorImage: null,
        totalPatients: 0,
        totalReports: 0,
        recentAnalyses: <AnalysisItemModel>[],
        error: e.toString(),
      );
    }
  }
}