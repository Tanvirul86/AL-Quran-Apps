import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/ayah.dart';

/// Service for creating beautiful share cards
class ShareCardService {
  static final ShareCardService _instance = ShareCardService._internal();
  factory ShareCardService() => _instance;
  ShareCardService._internal();

  Future<File> createShareCard({
    required Ayah ayah,
    required String englishTranslation,
    required String banglaTranslation,
    bool showTranslations = true,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = Size(1080, 1920); // Instagram story size

    // Background gradient
    const gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1B5E20),
        const Color(0xFF2E7D32),
        const Color(0xFF4CAF50),
      ],
    );
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);

    // Decorative pattern (simplified)
    _drawPattern(canvas, size);

    // Arabic text
    final arabicStyle = ui.TextStyle(
      fontSize: 48,
      color: Colors.white,
      height: 2.0,
    );
    final arabicParagraph = _buildParagraph(
      ayah.arabicText,
      arabicStyle,
      size.width - 160,
      TextAlign.right,
    );
    canvas.drawParagraph(
      arabicParagraph,
      const Offset(80, 200),
    );

    // Reference
    final referenceStyle = ui.TextStyle(
      fontSize: 32,
      color: Colors.white70,
      fontWeight: FontWeight.bold,
    );
    final referenceParagraph = _buildParagraph(
      'Surah ${ayah.surahNumber}, Ayah ${ayah.ayahNumber}',
      referenceStyle,
      size.width - 160,
      TextAlign.center,
    );
    canvas.drawParagraph(
      referenceParagraph,
      Offset(80, size.height - 400),
    );

    // Translations
    if (showTranslations) {
      double yPos = size.height - 350;
      
      if (englishTranslation.isNotEmpty) {
        final engStyle = ui.TextStyle(
          fontSize: 28,
          color: Colors.white,
          height: 1.5,
        );
        final engParagraph = _buildParagraph(
          englishTranslation,
          engStyle,
          size.width - 160,
          TextAlign.left,
        );
        canvas.drawParagraph(engParagraph, Offset(80, yPos));
        yPos += engParagraph.height + 40;
      }

      if (banglaTranslation.isNotEmpty) {
        final banglaStyle = ui.TextStyle(
          fontSize: 28,
          color: Colors.white,
          height: 1.5,
        );
        final banglaParagraph = _buildParagraph(
          banglaTranslation,
          banglaStyle,
          size.width - 160,
          TextAlign.left,
        );
        canvas.drawParagraph(banglaParagraph, Offset(80, yPos));
      }
    }

    // App name
    final appStyle = ui.TextStyle(
      fontSize: 24,
      color: Colors.white70,
    );
    final appParagraph = _buildParagraph(
      'Qur\'an App',
      appStyle,
      size.width - 160,
      TextAlign.center,
    );
    canvas.drawParagraph(
      appParagraph,
      Offset(80, size.height - 100),
    );

    // Convert to image
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    // Save to file
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/share_card_${ayah.surahNumber}_${ayah.ayahNumber}.png');
    await file.writeAsBytes(bytes);

    return file;
  }

  ui.Paragraph _buildParagraph(
    String text,
    ui.TextStyle style,
    double maxWidth,
    TextAlign align,
  ) {
    final builder = ui.ParagraphBuilder(ui.ParagraphStyle(
      textAlign: align,
      maxLines: 10,
    ))
      ..pushStyle(style)
      ..addText(text);

    final paragraph = builder.build();
    paragraph.layout(ui.ParagraphConstraints(width: maxWidth));
    return paragraph;
  }

  void _drawPattern(Canvas canvas, Size size) {
    // Draw decorative Islamic pattern
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Simple geometric pattern
    for (int i = 0; i < 20; i++) {
      final x = (size.width / 20) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }
}
