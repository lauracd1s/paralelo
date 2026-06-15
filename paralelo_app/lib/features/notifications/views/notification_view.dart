import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paralelo_app/features/notifications/viewmodels/notification_viewmodel.dart';

class NotificationView extends StatefulWidget {
  const NotificationView({super.key});

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView> {
  final _emailCtrl   = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NotificationViewModel(),
      child: Consumer<NotificationViewModel>(
        builder: (context, vm, _) => Scaffold(
          backgroundColor: const Color(0xFF1A1A2E),
          appBar: AppBar(
            backgroundColor: const Color(0xFF16213E),
            foregroundColor: Colors.white,
            title: const Text('Enviar notificación'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                // Ícono ilustrativo
                const Center(
                  child: Icon(Icons.mark_email_read_outlined,
                    size: 72, color: Color(0xFF7C6FCD)),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text('SNS → SQS → Lambda → Email',
                    style: TextStyle(color: Colors.white38, fontSize: 12)),
                ),
                const SizedBox(height: 32),

                // Campo email
                TextField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _deco('Correo destino', Icons.email_outlined),
                ),
                const SizedBox(height: 16),

                // Campo asunto
                TextField(
                  controller: _subjectCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: _deco('Asunto', Icons.subject),
                ),
                const SizedBox(height: 16),

                // Campo mensaje
                TextField(
                  controller: _messageCtrl,
                  maxLines: 5,
                  style: const TextStyle(color: Colors.white),
                  decoration: _deco('Mensaje', Icons.message_outlined),
                ),
                const SizedBox(height: 24),

                // Respuesta exitosa
                if (vm.success != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.greenAccent),
                        const SizedBox(width: 10),
                        Text(vm.success!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),

                // Error
                if (vm.error != null)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Text(vm.error!,
                          style: const TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Botón enviar
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C6FCD),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: vm.loading
                      ? const SizedBox(width: 20, height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send, color: Colors.white),
                    label: Text(
                      vm.loading ? 'Enviando...' : 'Enviar notificación',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    onPressed: vm.loading ? null : () => _send(vm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _send(NotificationViewModel vm) async {
    if (_emailCtrl.text.isEmpty ||
        _subjectCtrl.text.isEmpty ||
        _messageCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')));
      return;
    }
    await vm.sendNotification(
      _emailCtrl.text.trim(),
      _subjectCtrl.text.trim(),
      _messageCtrl.text.trim(),
    );
    if (vm.success != null) {
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();
    }
  }

  InputDecoration _deco(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    prefixIcon: Icon(icon, color: Colors.white54),
    filled: true,
    fillColor: const Color(0xFF16213E),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none),
  );
}
