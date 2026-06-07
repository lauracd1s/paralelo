import 'package:paralelo_app/features/usuarios/models/usuario_model.dart';
import 'package:paralelo_app/features/usuarios/services/usuarios_service.dart';

class UsuariosRepository {
  final UsuariosService _service = UsuariosService();

  Future<List<Usuario>> getAll() => _service.getAll();

  // ============================================================
  // PARALELISMO / CONCURRENCIA con Future.wait()
  // Carga múltiples usuarios por ID de forma simultánea
  // En lugar de hacer las peticiones una por una (secuencial),
  // las lanza todas al mismo tiempo y espera que terminen todas.
  // ============================================================
  Future<List<Usuario>> getManyByIds(List<int> ids) async {
    final futures = ids.map((id) => _service.getById(id));
    return Future.wait(futures); // peticiones en paralelo
  }

  Future<String?> update(int id, Map<String, dynamic> body) => _service.update(id, body);

  Future<String?> delete(int id) => _service.delete(id);
}
