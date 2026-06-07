import 'dart:convert';
import 'package:paralelo_app/core/constants/api_constants.dart';
import 'package:paralelo_app/core/network/api_client.dart';

class AuthService {
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiClient.postPublic(kAuthLogin, {
      'email': email,
      'password': password,
    });
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> register(String nombre, String email, String password, String rol) async {
    final response = await ApiClient.postPublic(kAuthRegister, {
      'nombre': nombre,
      'email': email,
      'password': password,
      'rol': rol,
    });
    return jsonDecode(response.body);
  }
}
