import 'package:flutter/material.dart';
import 'package:paralelo_app/features/notifications/services/notification_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _service = NotificationService();

  bool _loading = false;
  String? _error;
  String? _success;

  bool get loading   => _loading;
  String? get error   => _error;
  String? get success => _success;

  Future<void> sendNotification(String email, String subject, String message) async {
    _loading = true;
    _error   = null;
    _success = null;
    notifyListeners();

    try {
      final data = await _service.sendNotification(email, subject, message);
      if (data.containsKey('message_id')) {
        _success = 'Mensaje enviado correctamente.';
      } else {
        _error = data['error'] ?? 'Error al enviar mensaje.';
      }
    } catch (e) {
      _error = 'Error al enviar mensaje.';
    }

    _loading = false;
    notifyListeners();
  }

  void reset() {
    _error   = null;
    _success = null;
    notifyListeners();
  }
}
