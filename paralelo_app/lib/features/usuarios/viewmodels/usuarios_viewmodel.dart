import 'package:flutter/material.dart';
import 'package:paralelo_app/features/usuarios/models/usuario_model.dart';
import 'package:paralelo_app/features/usuarios/repositories/usuarios_repository.dart';

class UsuariosViewModel extends ChangeNotifier {
  final UsuariosRepository _repo = UsuariosRepository();

  List<Usuario> _usuarios = [];
  bool _loading = false;
  String? _error;

  List<Usuario> get usuarios => _usuarios;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> cargarUsuarios() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _usuarios = await _repo.getAll();
    } catch (e) {
      _error = 'Error al cargar usuarios: $e';
    }
    _loading = false;
    notifyListeners();
  }

  Future<bool> actualizarUsuario(int id, String nombre, String email, String rol) async {
    _loading = true;
    notifyListeners();
    final err = await _repo.update(id, {'nombre': nombre, 'email': email, 'rol': rol});
    _loading = false;
    if (err == null) await cargarUsuarios();
    _error = err;
    notifyListeners();
    return err == null;
  }

  Future<bool> eliminarUsuario(int id) async {
    final err = await _repo.delete(id);
    if (err == null) {
      _usuarios.removeWhere((u) => u.id == id);
      notifyListeners();
      return true;
    }
    _error = err;
    notifyListeners();
    return false;
  }

  // Demostración de concurrencia: carga varios usuarios en paralelo
  Future<void> cargarEnParalelo(List<int> ids) async {
    _loading = true;
    notifyListeners();
    try {
      _usuarios = await _repo.getManyByIds(ids);
    } catch (e) {
      _error = 'Error en carga paralela: $e';
    }
    _loading = false;
    notifyListeners();
  }
}
