import 'dart:io';
import 'package:dio/dio.dart';
import '../networking/dio_factory.dart';

class StudyService {
  final Dio _dio = DioFactory.getDio();

  Future<Map<String, dynamic>> uploadStudy({
    required int patientId,
    required File file,
  }) async {
    try {
      String fileName = file.path.split('/').last;
      FormData formData = FormData.fromMap({
        'PatientId': patientId,
        'File': await MultipartFile.fromFile(file.path, filename: fileName),
      });

      final response = await _dio.post(
        'Doctor/Studies/upload',
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception('Upload failed: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeStudy(int studyId) async {
    try {
      final response = await _dio.post('Doctor/Analysis/$studyId');
      return response.data;
    } catch (e) {
      throw Exception('Analysis failed: $e');
    }
  }

  Future<Map<String, dynamic>> getAnalysisResult(int studyId) async {
    try {
      final response = await _dio.get('Doctor/Analysis/$studyId');
      return response.data;
    } catch (e) {
      throw Exception('Failed to fetch result: $e');
    }
  }
}
