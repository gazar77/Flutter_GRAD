class AuthResultModel {
  final bool success;
  final String message;
  final String? token;
  final Map<String, dynamic>? user;

  const AuthResultModel({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? userMap;
    final rawUser = json['user'];
    if (rawUser is Map<String, dynamic>) {
      userMap = rawUser;
    }

    return AuthResultModel(
      success: json['success'] == true,
      message: json['message']?.toString() ?? '',
      token: json['token']?.toString(),
      user: userMap,
    );
  }
}
