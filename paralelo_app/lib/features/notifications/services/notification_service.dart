import 'dart:convert';
import 'package:paralelo_app/core/constants/api_constants.dart';
import 'package:paralelo_app/core/network/api_client.dart';

class NotificationService {
  Future<Map<String, dynamic>> sendNotification(
      String email, String subject, String message) async {
    final res = await ApiClient.post('$kBaseUrl/notifications/send', {
      'email':   email,
      'subject': subject,
      'message': message,
    });
    return jsonDecode(res.body);
  }
}
