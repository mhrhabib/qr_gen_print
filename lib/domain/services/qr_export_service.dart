import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/qr_config.dart';

abstract class IQrExportService {
  Future<String> exportPng(QrConfig config);
  Future<String> exportPdf(QrConfig config);
}

class QrExportService implements IQrExportService {
  @override
  Future<String> exportPng(QrConfig config) async {
    // Logic to render QR to image and save to local path
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';

    // Mock implementation of saving:
    // In a real app, you'd use a RepaintBoundary or a canvas to generate the bytes.
    await File(path).writeAsBytes([0]);

    return path;
  }

  @override
  Future<String> exportPdf(QrConfig config) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes([0]);
    return path;
  }
}
