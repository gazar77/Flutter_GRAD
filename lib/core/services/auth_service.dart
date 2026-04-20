import 'package:dio/dio.dart';
import '../networking/api_constants.dart';
import '../networking/dio_factory.dart';
import '../networking/token_manager.dart';

class AuthService {
  final Dio _dio = DioFactory.getDio();

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final data = response.data;
      if (data['success'] == true && data['token'] != null) {
        await TokenManager.saveToken(data['token']);
      }
      
      return data;
    } catch (e) {
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          throw Exception('invalid_credentials');
        }
      }
      throw Exception('login_error');
    }
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    String? confirmPassword,
    String? title,
    String? hospital,
    String? mobile,
    String? extension,
  }) async {
    try {
      await _dio.post(
        ApiConstants.register,
        data: {
          'username': name,
          'email': email,
          'password': password,
          'confirmPassword': confirmPassword ?? password,
          if (title != null && title.isNotEmpty) 'title': title,
          if (hospital != null && hospital.isNotEmpty) 'hospital': hospital,
          if (mobile != null && mobile.isNotEmpty) 'mobile': mobile,
          if (extension != null && extension.isNotEmpty) 'extension': extension,
        },
      );
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }
}
