import 'dart:convert';
import 'package:paralelo_app/core/constants/api_constants.dart';
import 'package:paralelo_app/core/network/api_client.dart';

class UploadService {
  Future<Map<String, dynamic>> uploadFile(String filePath) async {
    final res = await ApiClient.uploadFile(kUpload, filePath, 'file');
    return jsonDecode(res.body);
  }
}
