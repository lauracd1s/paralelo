import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paralelo_app/features/auth/viewmodels/auth_viewmodel.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nombreCtrl = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  String _rol = 'usuario';

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(backgroundColor: Colors.transparent, foregroundColor: Colors.white, title: const Text('Crear cuenta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          children: [
            TextField(controller: _nombreCtrl, style: const TextStyle(color: Colors.white),
              decoration: _deco('Nombre completo', Icons.person_outline)),
            const SizedBox(height: 14),
            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, style: const TextStyle(color: Colors.white),
              decoration: _deco('Email', Icons.email_outlined)),
            const SizedBox(height: 14),
            TextField(controller: _passCtrl, obscureText: true, style: const TextStyle(color: Colors.white),
              decoration: _deco('Contraseña', Icons.lock_outline)),
            const SizedBox(height: 14),

            // Selector de rol
            DropdownButtonFormField<String>(
              value: _rol,
              dropdownColor: const Color(0xFF16213E),
              style: const TextStyle(color: Colors.white),
              decoration: _deco('Rol', Icons.badge_outlined),
              items: ['usuario', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _rol = v!),
            ),
            const SizedBox(height: 16),

            if (vm.error != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(8)),
                child: Text(vm.error!, style: const TextStyle(color: Colors.white)),
              ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF7C6FCD), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: vm.loading ? null : _register,
                child: vm.loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Registrarse', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _register() async {
    final ok = await context.read<AuthViewModel>().register(
      _nombreCtrl.text.trim(), _emailCtrl.text.trim(), _passCtrl.text, _rol);
    if (ok && mounted) Navigator.pop(context);
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Colors.white54),
    prefixIcon: Icon(icon, color: Colors.white54), filled: true,
    fillColor: const Color(0xFF16213E),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
  );
}
