import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paralelo_app/features/auth/viewmodels/auth_viewmodel.dart';
import 'package:paralelo_app/features/auth/views/login_view.dart';
import 'package:paralelo_app/features/usuarios/models/usuario_model.dart';
import 'package:paralelo_app/features/usuarios/viewmodels/usuarios_viewmodel.dart';
import 'package:paralelo_app/features/upload/views/upload_view.dart';

class UsuariosView extends StatefulWidget {
  const UsuariosView({super.key});

  @override
  State<UsuariosView> createState() => _UsuariosViewState();
}

class _UsuariosViewState extends State<UsuariosView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UsuariosViewModel>().cargarUsuarios());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UsuariosViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Usuarios', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(icon: const Icon(Icons.upload_file, color: Colors.white),
            tooltip: 'Subir archivo',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadView()))),
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => vm.cargarUsuarios()),
          IconButton(icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout),
        ],
      ),
      body: vm.loading
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF7C6FCD)))
        : vm.error != null
          ? Center(child: Text(vm.error!, style: const TextStyle(color: Colors.red)))
          : vm.usuarios.isEmpty
            ? const Center(child: Text('No hay usuarios', style: TextStyle(color: Colors.white54)))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: vm.usuarios.length,
                itemBuilder: (_, i) => _UsuarioCard(usuario: vm.usuarios[i]),
              ),
    );
  }

  Future<void> _logout() async {
    await context.read<AuthViewModel>().logout();
    if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginView()));
  }
}

class _UsuarioCard extends StatelessWidget {
  final Usuario usuario;
  const _UsuarioCard({required this.usuario});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF16213E),
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF7C6FCD),
          child: Text(usuario.nombre.isNotEmpty ? usuario.nombre[0].toUpperCase() : '?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(usuario.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(usuario.email, style: const TextStyle(color: Colors.white54)),
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: usuario.rol == 'admin' ? Colors.orange.shade900 : Colors.teal.shade900,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(usuario.rol, style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, color: Color(0xFF7C6FCD), size: 20),
              onPressed: () => _showEditDialog(context)),
            IconButton(icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _confirmDelete(context)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nombreCtrl = TextEditingController(text: usuario.nombre);
    final emailCtrl  = TextEditingController(text: usuario.email);
    String rol = usuario.rol;

    showDialog(context: context, builder: (_) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Editar usuario', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(nombreCtrl, 'Nombre'),
            const SizedBox(height: 10),
            _dialogField(emailCtrl, 'Email'),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: rol,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(labelText: 'Rol', labelStyle: TextStyle(color: Colors.white54),
                filled: true, fillColor: Color(0xFF0F3460),
                border: OutlineInputBorder(borderSide: BorderSide.none)),
              items: ['usuario', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => rol = v!),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C6FCD)),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<UsuariosViewModel>().actualizarUsuario(usuario.id, nombreCtrl.text, emailCtrl.text, rol);
            },
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ));
  }

  void _confirmDelete(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: const Color(0xFF16213E),
      title: const Text('Eliminar usuario', style: TextStyle(color: Colors.white)),
      content: Text('¿Eliminar a ${usuario.nombre}?', style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.white54))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade800),
          onPressed: () async {
            Navigator.pop(context);
            await context.read<UsuariosViewModel>().eliminarUsuario(usuario.id);
          },
          child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
  }

  Widget _dialogField(TextEditingController c, String label) => TextField(
    controller: c,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.white54),
      filled: true, fillColor: const Color(0xFF0F3460),
      border: const OutlineInputBorder(borderSide: BorderSide.none)),
  );
}
