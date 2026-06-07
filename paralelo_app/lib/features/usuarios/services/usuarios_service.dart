import 'dart:convert';
import 'package:paralelo_app/core/constants/api_constants.dart';
import 'package:paralelo_app/core/network/api_client.dart';
import 'package:paralelo_app/features/usuarios/models/usuario_model.dart';

class UsuariosService {
  Future<List<Usuario>> getAll() async {
    final res = await ApiClient.get(kUsuarios);
    final data = jsonDecode(res.body);
    final list = data['data'] as List? ?? [];
    return list.map((e) => Usuario.fromJson(e)).toList();
  }

  Future<Usuario> getById(int id) async {
    final res = await ApiClient.get('$kUsuarios/$id');
    return Usuario.fromJson(jsonDecode(res.body)['data']);
  }

  Future<String?> update(int id, Map<String, dynamic> body) async {
    final res = await ApiClient.put('$kUsuarios/$id', body);
    final data = jsonDecode(res.body);
    if (res.statusCode == 200) return null;
    return data['error'] ?? 'Error al actualizar';
  }

  Future<String?> delete(int id) async {
    final res = await ApiClient.delete('$kUsuarios/$id');
    if (res.statusCode == 200) return null;
    return jsonDecode(res.body)['error'] ?? 'Error al eliminar';
  }
}
