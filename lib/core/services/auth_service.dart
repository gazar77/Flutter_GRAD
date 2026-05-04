import 'package:dio/dio.dart';
import '../models/auth_result.dart';
import '../networking/api_constants.dart';
import '../networking/dio_factory.dart';
import '../networking/token_manager.dart';

class AuthService {
  final Dio _dio = DioFactory.getDio();

  AuthResultModel _fromDio(dynamic e) {
    if (e is DioException && e.response?.data != null) {
      final raw = e.response!.data;
      if (raw is Map) {
        return AuthResultModel.fromJson(Map<String, dynamic>.from(raw));
      }
      if (raw is String) {
        return AuthResultModel(success: false, message: raw);
      }
    }
    return AuthResultModel(success: false, message: e.toString());
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      if (data['success'] == true && data['token'] != null) {
        await TokenManager.saveToken(data['token'] as String);
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

  Future<AuthResultModel> forgotPassword(String email) async {
    try {
      final res = await _dio.post(
        ApiConstants.forgotPassword,
        data: {'email': email.trim().toLowerCase()},
      );
      return AuthResultModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (e) {
      return _fromDio(e);
    }
  }

  Future<AuthResultModel> verifyOtp(String email, String otp) async {
    try {
      final res = await _dio.post(
        ApiConstants.verifyOtp,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
        },
      );
      return AuthResultModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (e) {
      return _fromDio(e);
    }
  }

  Future<AuthResultModel> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.resetPassword,
        data: {
          'email': email.trim().toLowerCase(),
          'otp': otp.trim(),
          'newPassword': newPassword,
        },
      );
      return AuthResultModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (e) {
      return _fromDio(e);
    }
  }

  Future<AuthResultModel> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.changePassword,
        data: {
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        },
      );
      return AuthResultModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (e) {
      return _fromDio(e);
    }
  }

  Future<AuthResultModel> updateEmail(String newEmail) async {
    try {
      final res = await _dio.post(
        ApiConstants.updateEmail,
        data: {'newEmail': newEmail.trim().toLowerCase()},
      );
      return AuthResultModel.fromJson(Map<String, dynamic>.from(res.data as Map));
    } catch (e) {
      return _fromDio(e);
    }
  }
}
