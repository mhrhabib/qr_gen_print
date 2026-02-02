import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import '../../domain/models/qr_config.dart';

class QrPreview extends StatelessWidget {
  final QrConfig config;
  final double size;

  const QrPreview({super.key, required this.config, this.size = 240});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size + 48,
      height: size + 48,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: config.bgColor,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 30, offset: const Offset(0, 15)),
          BoxShadow(color: config.fgColor.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Center(
        child: PrettyQrView.data(
          data: config.content.isEmpty ? 'https://google.com' : config.content,
          decoration: PrettyQrDecoration(
            background: config.bgColor,
            shape: PrettyQrSmoothSymbol(
              color: config.fgColor,
              roundFactor: config.cornerStyle == QrCornerStyle.square
                  ? 0
                  : (config.cornerStyle == QrCornerStyle.circular ? 1.0 : 0.5),
            ),
            image: config.logoPath != null ? PrettyQrDecorationImage(image: FileImage(File(config.logoPath!))) : null,
          ),
        ),
      ),
    );
  }
}
