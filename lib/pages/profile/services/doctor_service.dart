import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../core/networking/api_constants.dart';
import '../../../core/networking/dio_factory.dart';

class DoctorService {
  final Dio _dio = DioFactory.getDio();

  Future<bool> updateProfile({
    required String name,
    required String hospital,
    required String title,
    required String mobile,
    required String extension,
  }) async {
    try {
      final formData = FormData.fromMap({
        'FullName': name,
        'Hospital': hospital,
        'Title': title,
        'Mobile': mobile,
        'Extension': extension,
      });

      final response = await _dio.put(
        ApiConstants.updateProfile,
        data: formData,
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Update Profile Error: $e');
      return false;
    }
  }
}
