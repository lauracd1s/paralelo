import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // Headers con JWT
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, String>> _publicHeaders() async => {
    'Content-Type': 'application/json',
  };

  // GET
  static Future<http.Response> get(String url) async {
    final headers = await _authHeaders();
    return http.get(Uri.parse(url), headers: headers);
  }

  // POST público (login, register)
  static Future<http.Response> postPublic(String url, Map<String, dynamic> body) async {
    final headers = await _publicHeaders();
    return http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }

  // POST con auth
  static Future<http.Response> post(String url, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    return http.post(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }

  // PUT
  static Future<http.Response> put(String url, Map<String, dynamic> body) async {
    final headers = await _authHeaders();
    return http.put(Uri.parse(url), headers: headers, body: jsonEncode(body));
  }

  // DELETE
  static Future<http.Response> delete(String url) async {
    final headers = await _authHeaders();
    return http.delete(Uri.parse(url), headers: headers);
  }

  // Multipart para subir archivos
  static Future<http.Response> uploadFile(String url, String filePath, String fieldName) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath(fieldName, filePath));

    final streamed = await request.send();
    return http.Response.fromStream(streamed);
  }
}
