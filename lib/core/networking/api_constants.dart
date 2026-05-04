class ApiConstants {
  /// Production ASP.NET backend (Swagger: https://backnetgrad.runasp.net/swagger)
  static const String baseUrl = 'https://backnetgrad.runasp.net/api/';

  static const String _staticOrigin = 'https://backnetgrad.runasp.net';

  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String forgotPassword = 'auth/forgot-password';
  static const String verifyOtp = 'auth/verify-otp';
  static const String resetPassword = 'auth/reset-password';
  static const String changePassword = 'auth/change-password';
  static const String updateEmail = 'auth/update-email';

  static const String patients = 'Patients';
  static const String dashboard = 'Doctor/Dashboard';
  static const String studies = 'Doctor/Studies';
  static const String analysis = 'Doctor/Analysis';
  static const String dicomToVideo = 'Tools/Tools/dicom-to-video';
  /// Local/dev AI only; live analysis goes through backend `Doctor/Analysis`.
  static const String predictLocal = 'https://huggingface.co/spaces/MoGazar/angio-ai-service';
  static const String updateProfile = 'Doctor/Doctors/me';

  /// Builds absolute URL for static files (`/profiles/...`, `uploads/...`, `analysis/...`).
  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) {
      return 'https://via.placeholder.com/400x240';
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$_staticOrigin/$cleanPath';
  }
}
