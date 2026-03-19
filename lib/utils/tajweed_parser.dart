import 'package:flutter/material.dart';

class TajweedParser {
  /// Map of Tajweed tags to colors
  /// Following the standard convention:
  /// Ghunnah = Green, Qalqalah = Blue, Ikhfa = Orange, Mad = Red
  static Map<String, Color> get tajweedColors => {
    'ghunna': const Color(0xFF16A085), // Emerald Green
    'qalqala': const Color(0xFF2980B9), // Blue
    'ikhfa': const Color(0xFFE67E22), // Orange
    'ikhfa_shafwi': const Color(0xFFE67E22),
    'iqlab': const Color(0xFF1ABC9C), // Light Emerald
    'idghm_gn': const Color(0xFF009688), // Teal
    'idghm_no_gn': const Color(0xFF7F8C8D), // Gray
    'madda_6': const Color(0xFFC0392B), // Dark Red
    'madda_5': const Color(0xFFE74C3C), // Red
    'madda_4': const Color(0xFFE74C3C),
    'madda_2': const Color(0xFFF1948A), // Pink/Light Red
    'ham_wasl': const Color(0xFF7F8C8D), // Gray
    'slnt': const Color(0xFFBDC3C7), // Light Gray (Silent)
  };

  /// Parses text containing <tajweed class=rule>... </tajweed> tags into TextSpans
  static List<TextSpan> parse(String text, TextStyle baseStyle) {
    final List<TextSpan> spans = [];
    final regExp = RegExp(r'<tajweed class=([^>]+)>(.*?)</tajweed>|([^<]+)');
    
    final matches = regExp.allMatches(text);

    for (final match in matches) {
      if (match.group(3) != null) {
        // Plain text
        spans.add(TextSpan(
          text: match.group(3),
          style: baseStyle,
        ));
      } else if (match.group(1) != null && match.group(2) != null) {
        // Tajweed tagged text
        final ruleClass = match.group(1)!;
        final content = match.group(2)!;
        final color = tajweedColors[ruleClass] ?? baseStyle.color;

        spans.add(TextSpan(
          text: content,
          style: baseStyle.copyWith(
            color: color,
            fontWeight: (ruleClass.contains('madda') || ruleClass == 'ghunna') 
                ? FontWeight.bold 
                : baseStyle.fontWeight,
          ),
        ));
      }
    }

    return spans;
  }
}
