import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:paralelo_app/features/upload/repositories/upload_repository.dart';

class UploadViewModel extends ChangeNotifier {
  final UploadRepository _repo = UploadRepository();
  final ImagePicker _picker = ImagePicker();

  final StreamController<double> _progressController = StreamController<double>.broadcast();
  Stream<double> get progressStream => _progressController.stream;

  String? _filePath;
  String? _uploadedUrl;
  bool _uploading = false;
  String? _error;

  String? get filePath    => _filePath;
  String? get uploadedUrl => _uploadedUrl;
  bool get uploading      => _uploading;
  String? get error       => _error;

  Future<void> pickFromGallery() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (file != null) {
      _filePath = file.path;
      _uploadedUrl = null;
      _error = null;
      notifyListeners();
    }
  }

  Future<void> pickFromCamera() async {
    final XFile? file = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (file != null) {
      _filePath = file.path;
      _uploadedUrl = null;
      _error = null;
      notifyListeners();
    }
  }

  Future<void> upload() async {
    if (_filePath == null) return;

    _uploading = true;
    _error = null;
    _progressController.add(0.2);
    notifyListeners();

    _progressController.add(0.5);
    final url = await _repo.upload(_filePath!);

    if (url != null) {
      _uploadedUrl = url;
      _progressController.add(1.0);
    } else {
      _error = 'Error al subir el archivo';
      _progressController.add(0.0);
    }

    _uploading = false;
    notifyListeners();
  }

  void reset() {
    _filePath = null;
    _uploadedUrl = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _progressController.close();
    super.dispose();
  }
}
