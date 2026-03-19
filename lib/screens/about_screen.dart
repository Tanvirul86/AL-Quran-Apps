import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:math' as math;
import '../utils/app_info.dart';
import '../widgets/glass_card.dart';
import '../widgets/spiritual_background.dart';
import '../theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('About'),
      ),
      body: SpiritualBackground(
        child: FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snapshot) {
            final version = snapshot.hasData
                ? snapshot.data!.version
                : AppInfo.appVersion;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      // Hero header
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 70,
                          bottom: 40,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [primary, primary.withOpacity(0.7)],
                          ),
                        ),
                        child: Column(
                          children: [
                            // Animated logo
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: _StarPainter(Colors.white),
                                child: const Center(
                                  child: Text('☪', style: TextStyle(fontSize: 36)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Al-Quran Pro',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Version $version',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.75),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '🌙 القرآن الكريم',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white.withOpacity(0.85),
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Description card
                            GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  Icon(Icons.info_outline_rounded,
                                      color: primary, size: 28),
                                  const SizedBox(height: 12),
                                  Text(
                                    AppInfo.appDescription,
                                    style: TextStyle(
                                      fontSize: 14,
                                      height: 1.7,
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black87,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            // Features
                            _SectionHeader(title: 'Features', icon: Icons.star_rounded),
                            const SizedBox(height: 10),
                            GlassCard(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 16),
                              child: Column(
                                children: AppInfo.features
                                    .asMap()
                                    .entries
                                    .map((e) {
                                  final isLast =
                                      e.key == AppInfo.features.length - 1;
                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 28,
                                              height: 28,
                                              decoration: BoxDecoration(
                                                color: primary.withOpacity(0.1),
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(Icons.check_rounded,
                                                  color: primary, size: 16),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                e.value,
                                                style: const TextStyle(
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.withOpacity(0.2),
                                        ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Developer Info
                            _SectionHeader(title: 'Developer', icon: Icons.person_rounded),
                            const SizedBox(height: 10),
                            GlassCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  _InfoRow(
                                    icon: Icons.person_outline,
                                    label: 'Developer',
                                    value: AppInfo.developerName,
                                    color: primary,
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    icon: Icons.email_outlined,
                                    label: 'Contact',
                                    value: AppInfo.supportEmail,
                                    color: primary,
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      Clipboard.setData(ClipboardData(
                                          text: AppInfo.supportEmail));
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Email copied!'),
                                            duration: Duration(seconds: 2)),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  _InfoRow(
                                    icon: Icons.language_outlined,
                                    label: 'Website',
                                    value: AppInfo.website,
                                    color: primary,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Disclaimer
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: Colors.amber.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.info_outline,
                                      color: Colors.amber.shade700, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'The Arabic text of the Qur\'an is authentic and unmodified. Translations are for understanding only.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.amber.shade800,
                                        height: 1.6,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 24),
                            Center(
                              child: Text(
                                '© ${DateTime.now().year} ${AppInfo.developerName}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Row(
      children: [
        Icon(icon, color: primary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: primary,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          if (onTap != null) ...[
            const Spacer(),
            Icon(Icons.copy_outlined, size: 14, color: Colors.grey.shade400),
          ],
        ],
      ),
    );
  }
}

class _StarPainter extends CustomPainter {
  final Color color;
  _StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width / 2 - 6;
    const n = 8;
    for (int i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawLine(
        Offset(cx, cy),
        Offset(cx + r * math.cos(a), cy + r * math.sin(a)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.color != color;
}
