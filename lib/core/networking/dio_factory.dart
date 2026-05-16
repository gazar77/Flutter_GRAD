import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'token_manager.dart';
import 'package:flutter/foundation.dart';

class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static Dio getDio() {
    Duration timeOut = const Duration(seconds: 120); // Increased timeout for large file uploads

    if (_dio == null) {
      _dio = Dio();
      _dio!
        ..options.baseUrl = ApiConstants.baseUrl
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut;
      
      _addDioInterceptor();
    }
    return _dio!;
  }

  static void _addDioInterceptor() {
    // Custom Simple Logger Interceptor to avoid external dependency issues
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (kDebugMode) {
            print('REQUEST[${options.method}] => PATH: ${options.path}');
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          }
          return handler.next(response);
        },
        onError: (err, handler) {
          if (kDebugMode) {
            print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
          }
          return handler.next(err);
        },
      ),
    );
    
    // Add Authorization Interceptor for JWT
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }
}
