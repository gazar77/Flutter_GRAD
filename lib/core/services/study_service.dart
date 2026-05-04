import 'dart:io';

import 'package:dio/dio.dart';
import '../networking/api_constants.dart';
import '../networking/dio_factory.dart';

class StudyService {
  final Dio _dio = DioFactory.getDio();

  Future<Map<String, dynamic>> uploadStudy({
    required int patientId,
    required File file,
  }) async {
    try {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final formData = FormData.fromMap({
        'PatientId': patientId,
        'File': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        '${ApiConstants.studies}/upload',
        data: formData,
      );

      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeStudy(int studyId) async {
    try {
      final response = await _dio.post('${ApiConstants.analysis}/$studyId');
      return Map<String, dynamic>.from(response.data as Map);
    } on DioException catch (e) {
      final serverMsg = e.response?.data?.toString() ?? e.message ?? 'Unknown error';
      throw Exception(serverMsg);
    } catch (e) {
      throw Exception('Analysis failed: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalysisResult(int studyId) async {
    try {
      final response = await _dio.get('${ApiConstants.analysis}/$studyId');
      return Map<String, dynamic>.from(response.data as Map);
    } catch (e) {
      throw Exception('Failed to fetch result: $e');
    }
  }
}
