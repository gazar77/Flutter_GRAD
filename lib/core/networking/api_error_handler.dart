import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class ApiErrorHandler {
  static String getMessage(dynamic error, BuildContext context) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return 'connection_error'.tr(context, listen: false);
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 401) {
            return 'unauthorized_error'.tr(context, listen: false);
          } else if (statusCode == 403) {
            return 'forbidden_error'.tr(context, listen: false);
          } else if (statusCode != null && statusCode >= 500) {
            return 'server_error'.tr(context, listen: false);
          }
          break;
        
        default:
          return 'unknown_error'.tr(context, listen: false);
      }
    }
    
    // If it's a generic Exception or String
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('socketexception') || errorStr.contains('network')) {
      return 'connection_error'.tr(context, listen: false);
    }

    return 'unknown_error'.tr(context, listen: false);
  }
}
