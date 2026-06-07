import 'package:shared_preferences/shared_preferences.dart';
import 'package:paralelo_app/core/constants/api_constants.dart';
import 'package:paralelo_app/features/auth/services/auth_service.dart';

class AuthRepository {
  final AuthService _service = AuthService();

  Future<String?> login(String email, String password) async {
    final data = await _service.login(email, password);
    if (data.containsKey('token')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(kTokenKey, data['token']);
      return null; // sin error
    }
    return data['error'] ?? 'Error desconocido';
  }

  Future<String?> register(String nombre, String email, String password, String rol) async {
    final data = await _service.register(nombre, email, password, rol);
    if (data.containsKey('data')) return null;
    return data['error'] ?? 'Error desconocido';
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTokenKey);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(kTokenKey) != null;
  }
}
