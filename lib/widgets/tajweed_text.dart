import 'package:flutter/material.dart';
import '../services/tajweed_service.dart';

/// Widget for displaying Arabic text with Tajweed color-coding
class TajweedText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final TextDirection textDirection;

  const TajweedText({
    super.key,
    required this.text,
    this.fontSize = 24.0,
    this.textAlign = TextAlign.right,
    this.textDirection = TextDirection.rtl,
  });

  @override
  Widget build(BuildContext context) {
    final tajweedService = TajweedService();
    
    // Split text into characters and apply colors
    final textSpans = <TextSpan>[];
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final color = tajweedService.getTajweedColor(char);
      
      textSpans.add(
        TextSpan(
          text: char,
          style: TextStyle(
            fontSize: fontSize,
            color: color ?? Colors.black,
            fontWeight: color != null ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(children: textSpans),
      textAlign: textAlign,
      textDirection: textDirection,
    );
  }
}
