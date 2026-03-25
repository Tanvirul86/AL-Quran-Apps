import 'package:flutter/material.dart';
import 'dart:math' as math;

class MuslimProStyleLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const MuslimProStyleLogo({
    super.key,
    this.size = 140,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow ? [
          BoxShadow(
            color: const Color(0xFF16A085).withOpacity(0.35),
            blurRadius: size * 0.3,
            spreadRadius: size * 0.05,
          )
        ] : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Gradient Circle
          Container(
            width: size * 0.9,
            height: size * 0.9,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1ABC9C),
                  Color(0xFF16A085),
                  Color(0xFF0D6353),
                ],
              ),
            ),
          ),
          // Decorative Outer Ring
          CustomPaint(
            size: Size(size * 0.95, size * 0.95),
            painter: _OuterRingPainter(
              color: Colors.white.withOpacity(0.2),
            ),
          ),
          // Main Iconic Element: Mosque Dome + Mihrab
          CustomPaint(
            size: Size(size * 0.55, size * 0.65),
            painter: _MosqueLogoPainter(
              primaryColor: Colors.white,
              accentColor: const Color(0xFFF1C40F), // Gold
            ),
          ),
        ],
      ),
    );
  }
}

class _OuterRingPainter extends CustomPainter {
  final Color color;
  _OuterRingPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw dashed/decorative circle
    const count = 32;
    for (var i = 0; i < count; i++) {
      final angle = (i * 2 * math.pi) / count;
      final start = Offset(
        center.dx + (radius - 4) * math.cos(angle),
        center.dy + (radius - 4) * math.sin(angle),
      );
      final end = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MosqueLogoPainter extends CustomPainter {
  final Color primaryColor;
  final Color accentColor;

  _MosqueLogoPainter({
    required this.primaryColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final accentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;

    // 1. Draw the Dome (Top half-ish)
    final domePath = Path();
    domePath.moveTo(w * 0.1, h * 0.5);
    // Left shoulder
    domePath.quadraticBezierTo(w * 0.1, h * 0.3, w * 0.5, 0);
    // Right shoulder
    domePath.quadraticBezierTo(w * 0.9, h * 0.3, w * 0.9, h * 0.5);
    domePath.lineTo(w * 0.1, h * 0.5);
    canvas.drawPath(domePath, paint);

    // 2. The Crescent on top
    final crescentPaint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(w * 0.5, -h * 0.05), w * 0.08, crescentPaint);

    // 3. The Arch / Mihrab (Bottom part)
    final archPath = Path();
    archPath.moveTo(w * 0.2, h * 0.55);
    archPath.lineTo(w * 0.2, h * 0.95);
    archPath.lineTo(w * 0.8, h * 0.95);
    archPath.lineTo(w * 0.8, h * 0.55);
    
    // Inner arch
    archPath.moveTo(w * 0.35, h * 0.95);
    archPath.lineTo(w * 0.35, h * 0.7);
    archPath.quadraticBezierTo(w * 0.5, h * 0.55, w * 0.65, h * 0.7);
    archPath.lineTo(w * 0.65, h * 0.95);
    archPath.close();

    canvas.drawPath(archPath, paint);

    // 4. Gold Leaf detailing inside the dome
    final detailPath = Path();
    detailPath.moveTo(w * 0.5, h * 0.15);
    detailPath.quadraticBezierTo(w * 0.6, h * 0.25, w * 0.5, h * 0.35);
    detailPath.quadraticBezierTo(w * 0.4, h * 0.25, w * 0.5, h * 0.15);
    canvas.drawPath(detailPath, accentPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
