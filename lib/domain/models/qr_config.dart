import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum QrType { url, text, wifi }

enum QrCornerStyle { square, rounded, circular }

enum QrFrameStyle { none, standard }

class QrConfig extends Equatable {
  final QrType type;
  final String content;
  final Color fgColor;
  final Color bgColor;
  final String? logoPath;
  final QrCornerStyle cornerStyle;
  final QrFrameStyle frameStyle;
  final int resolution;
  final bool isPremium;

  const QrConfig({
    this.type = QrType.url,
    this.content = '',
    this.fgColor = Colors.black,
    this.bgColor = Colors.white,
    this.logoPath,
    this.cornerStyle = QrCornerStyle.square,
    this.frameStyle = QrFrameStyle.none,
    this.resolution = 512,
    this.isPremium = false,
  });

  QrConfig copyWith({
    QrType? type,
    String? content,
    Color? fgColor,
    Color? bgColor,
    String? logoPath,
    QrCornerStyle? cornerStyle,
    QrFrameStyle? frameStyle,
    int? resolution,
    bool? isPremium,
  }) {
    return QrConfig(
      type: type ?? this.type,
      content: content ?? this.content,
      fgColor: fgColor ?? this.fgColor,
      bgColor: bgColor ?? this.bgColor,
      logoPath: logoPath ?? this.logoPath,
      cornerStyle: cornerStyle ?? this.cornerStyle,
      frameStyle: frameStyle ?? this.frameStyle,
      resolution: resolution ?? this.resolution,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  List<Object?> get props => [
    type,
    content,
    fgColor,
    bgColor,
    logoPath,
    cornerStyle,
    frameStyle,
    resolution,
    isPremium,
  ];
}
