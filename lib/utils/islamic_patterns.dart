import 'package:flutter/material.dart';

/// Utility for Islamic design elements and patterns
class IslamicPatterns {
  /// Generates a decorative Islamic geometric pattern background
  static Widget geometricPattern({
    Color primaryColor = const Color(0xFF2E7D32),
    Color secondaryColor = const Color(0xFF1B5E20),
    double opacity = 0.05,
  }) {
    return CustomPaint(
      painter: IslamicGeometricPainter(
        primaryColor: primaryColor.withOpacity(opacity),
        secondaryColor: secondaryColor.withOpacity(opacity),
      ),
      child: const SizedBox.expand(),
    );
  }

  /// Creates a decorative border with Islamic pattern
  static BoxDecoration islamicBorderDecoration({
    Color borderColor = const Color(0xFF2E7D32),
    double borderWidth = 2,
    double borderRadius = 12,
    Color backgroundColor = Colors.white,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: borderColor,
        width: borderWidth,
      ),
      boxShadow: [
        BoxShadow(
          color: borderColor.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  /// Creates a decorative divider
  static Widget decorativeDivider({
    Color color = const Color(0xFF2E7D32),
    double height = 1,
    double thickness = 1.5,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0),
            color.withOpacity(0.5),
            color.withOpacity(0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Divider(
        color: color.withOpacity(0.3),
        thickness: thickness,
        height: height,
      ),
    );
  }

  /// Islamic badge widget
  static Widget badge({
    required String label,
    Color backgroundColor = const Color(0xFFD4AF37),
    Color textColor = Colors.black87,
    double fontSize = 12,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
          color: textColor,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Waqf (pause) mark indicators
  static Widget waqfMark({
    String type = 'waqfRequired', // 'waqfRequired', 'waqfAllowed', 'noWaqf'
    Color color = const Color(0xFF2E7D32),
  }) {
    const String arabicWaqf = 'ۖ';
    
    switch (type) {
      case 'waqfRequired':
        return Tooltip(
          message: 'Waqf (Full stop) required',
          child: Text(
            arabicWaqf,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      case 'waqfAllowed':
        return Tooltip(
          message: 'Waqf (Full stop) is allowed',
          child: Text(
            'ۗ',
            style: TextStyle(
              color: color.withOpacity(0.6),
              fontSize: 16,
            ),
          ),
        );
      case 'noWaqf':
        return Tooltip(
          message: 'No pause here',
          child: Text(
            '۝',
            style: TextStyle(
              color: color.withOpacity(0.4),
              fontSize: 14,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  /// Tajweed rule indicator
  static Widget tajweedIndicator({
    required String rule,
    required Color color,
    double fontSize = 14,
  }) {
    final Map<String, String> ruleNames = {
      'noon': 'Noon Saakin',
      'tanwin': 'Tanwin',
      'emphatic': 'Emphatic Letter',
      'gunnah': 'Gunnah',
      'qalqalah': 'Qalqalah',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border(bottom: BorderSide(color: color, width: 2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        ruleNames[rule] ?? rule,
        style: TextStyle(
          fontSize: fontSize - 2,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  /// Creates an Islamic gradient background
  static LinearGradient islamicGradient({
    Color startColor = const Color(0xFF2E7D32),
    Color endColor = const Color(0xFF1B5E20),
  }) {
    return LinearGradient(
      colors: [startColor, endColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}

/// Custom painter for geometric Islamic patterns
class IslamicGeometricPainter extends CustomPainter {
  final Color primaryColor;
  final Color secondaryColor;

  IslamicGeometricPainter({
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint1 = Paint()
      ..color = primaryColor
      ..strokeWidth = 1;

    final paint2 = Paint()
      ..color = secondaryColor
      ..strokeWidth = 1;

    // Draw geometric pattern (simple repeating star pattern)
    const double spacing = 40;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw small circles in pattern
        canvas.drawCircle(Offset(x, y), 3, paint1);

        // Draw connecting lines
        if (x + spacing < size.width) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x + spacing, y),
            paint2,
          );
        }
        if (y + spacing < size.height) {
          canvas.drawLine(
            Offset(x, y),
            Offset(x, y + spacing),
            paint2,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(IslamicGeometricPainter oldDelegate) => false;
}
