import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:paralelo_app/features/upload/viewmodels/upload_viewmodel.dart';

class UploadView extends StatelessWidget {
  const UploadView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UploadViewModel(),
      child: const _UploadBody(),
    );
  }
}

class _UploadBody extends StatelessWidget {
  const _UploadBody();

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<UploadViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        foregroundColor: Colors.white,
        title: const Text('Subir archivo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Preview
            Container(
              height: 220,
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF7C6FCD).withOpacity(0.4), width: 1.5),
              ),
              child: vm.filePath != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(File(vm.filePath!), fit: BoxFit.cover),
                  )
                : const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 60, color: Color(0xFF7C6FCD)),
                      SizedBox(height: 8),
                      Text('Selecciona una imagen', style: TextStyle(color: Colors.white54)),
                    ],
                  ),
            ),

            const SizedBox(height: 16),

            // Botones de selección
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF7C6FCD)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                    onPressed: () => context.read<UploadViewModel>().pickFromGallery(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF7C6FCD)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Cámara'),
                    onPressed: () => context.read<UploadViewModel>().pickFromCamera(),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progreso con Stream
            StreamBuilder<double>(
              stream: context.read<UploadViewModel>().progressStream,
              builder: (_, snap) {
                final progress = snap.data ?? 0.0;
                if (progress <= 0) return const SizedBox.shrink();
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: const Color(0xFF16213E),
                      color: const Color(0xFF7C6FCD),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    const SizedBox(height: 6),
                    Text('${(progress * 100).toInt()}%',
                      style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            if (vm.error != null)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.red.shade900, borderRadius: BorderRadius.circular(8)),
                child: Text(vm.error!, style: const TextStyle(color: Colors.white)),
              ),

            if (vm.uploadedUrl != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.green.shade900, borderRadius: BorderRadius.circular(8)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('✅ Subido correctamente:', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(vm.uploadedUrl!, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),

            const Spacer(),

            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C6FCD),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: vm.uploading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.cloud_upload, color: Colors.white),
                label: Text(vm.uploading ? 'Subiendo...' : 'Subir imagen',
                  style: const TextStyle(fontSize: 16, color: Colors.white)),
                onPressed: (vm.filePath == null || vm.uploading) ? null
                  : () => context.read<UploadViewModel>().upload(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
