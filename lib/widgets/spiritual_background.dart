import 'package:flutter/material.dart';

class SpiritualBackground extends StatelessWidget {
  final Widget child;
  final bool animate;

  const SpiritualBackground({
    super.key,
    required this.child,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brightness = theme.brightness;
    
    // Determine gradient based on theme and potentially time (simulated via brightness for now)
    List<Color> colors;
    if (brightness == Brightness.light) {
      colors = [
        theme.primaryColor.withOpacity(0.05),
        theme.colorScheme.surface,
        theme.colorScheme.tertiary.withOpacity(0.05),
      ];
    } else {
      colors = [
        theme.colorScheme.background,
        theme.primaryColor.withOpacity(0.1),
        theme.colorScheme.background,
      ];
    }

    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: colors,
              ),
            ),
          ),
        ),
        // Add subtle geometric patterns (simulated with circles for now)
        Positioned(
          top: -100,
          right: -100,
          child: _CircularPattern(
            color: theme.primaryColor.withOpacity(0.03),
            size: 300,
          ),
        ),
        Positioned(
          bottom: -50,
          left: -50,
          child: _CircularPattern(
            color: theme.colorScheme.tertiary.withOpacity(0.04),
            size: 200,
          ),
        ),
        child,
      ],
    );
  }
}

class _CircularPattern extends StatelessWidget {
  final Color color;
  final double size;

  const _CircularPattern({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
