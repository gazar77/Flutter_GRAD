class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5104/api/'; 
  static const String login = 'auth/login';
  static const String register = 'auth/register';
  static const String patients = 'Patients';
  static const String dashboard = 'Doctor/Dashboard';
  static const String studies = 'Doctor/Studies';
  static const String analysis = 'Doctor/Analysis';
  static const String dicomToVideo = 'Tools/Tools/dicom-to-video';
  static const String predict = 'http://10.0.2.2:8000/predict'; 
  static const String updateProfile = 'Doctor/Doctors/me';

  static String get baseImageUrl => baseUrl.replaceAll('/api/', '');

  static String getFullImageUrl(String? path) {
    if (path == null || path.isEmpty) return "https://via.placeholder.com/400x240";
    if (path.startsWith('http')) return path;
    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$baseImageUrl/$cleanPath';
  }
}
