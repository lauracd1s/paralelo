class AuthResponse {
  final String token;
  final String message;

  AuthResponse({required this.token, required this.message});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
    token: json['token'] ?? '',
    message: json['message'] ?? '',
  );
}
