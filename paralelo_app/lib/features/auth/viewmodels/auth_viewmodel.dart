import 'package:flutter/material.dart';
import 'package:paralelo_app/features/auth/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repo = AuthRepository();

  bool _loading = false;
  String? _error;

  bool get loading => _loading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final err = await _repo.login(email, password);
    _loading = false;
    _error = err;
    notifyListeners();
    return err == null;
  }

  Future<bool> register(String nombre, String email, String password, String rol) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final err = await _repo.register(nombre, email, password, rol);
    _loading = false;
    _error = err;
    notifyListeners();
    return err == null;
  }

  Future<void> logout() async {
    await _repo.logout();
    notifyListeners();
  }

  Future<bool> isLoggedIn() => _repo.isLoggedIn();
}
