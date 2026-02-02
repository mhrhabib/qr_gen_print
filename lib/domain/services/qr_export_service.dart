import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import '../models/qr_config.dart';

abstract class IQrExportService {
  Future<String> saveImage(Uint8List bytes);
  Future<String> exportPdf(QrConfig config);
}

class QrExportService implements IQrExportService {
  @override
  Future<String> saveImage(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(path);
    await file.writeAsBytes(bytes);
    return path;
  }

  @override
  Future<String> exportPdf(QrConfig config) async {
    // PDF export implementation would go here
    // For now returning a mock path
    final directory = await getTemporaryDirectory();
    final path = '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.pdf';
    await File(path).writeAsBytes([0]);
    return path;
  }
}
