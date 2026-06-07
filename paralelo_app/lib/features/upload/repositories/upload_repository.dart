import 'package:paralelo_app/features/upload/services/upload_service.dart';

class UploadRepository {
  final UploadService _service = UploadService();

  Future<String?> upload(String filePath) async {
    try {
      final data = await _service.uploadFile(filePath);
      return data['url'] as String?;
    } catch (e) {
      return null;
    }
  }
}
