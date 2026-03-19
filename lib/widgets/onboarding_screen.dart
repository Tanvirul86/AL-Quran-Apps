import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import '../screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  late AnimationController _entryController;
  late AnimationController _bgController;
  int _currentPage = 0;

  static const _pages = [
    _OnboardingData(
      titleAr: 'بِسْمِ اللَّهِ',
      title: 'Welcome to Al-Quran Pro',
      subtitle: 'Experience the Holy Qur\'an with authentic Uthmani Arabic text, English & Bangla translations.',
      icon: Icons.menu_book_rounded,
      gradient: [Color(0xFF0D1B2A), Color(0xFF1B3A5C)],
      accent: Color(0xFF4FC3F7),
      particle: '✦',
    ),
    _OnboardingData(
      titleAr: 'اقْرَأْ',
      title: 'Read & Understand',
      subtitle: 'Word-by-word meanings, Tafsir commentary, and Tajweed color-coding deepen your understanding.',
      icon: Icons.auto_stories_rounded,
      gradient: [Color(0xFF1B5E20), Color(0xFF2E7D32)],
      accent: Color(0xFF81C784),
      particle: '❋',
    ),
    _OnboardingData(
      titleAr: 'اسْتَمِعْ',
      title: 'Listen & Learn',
      subtitle: 'Beautiful recitations from world-renowned Qaris. Background audio, sleep timer, and speed control.',
      icon: Icons.headphones_rounded,
      gradient: [Color(0xFF4A148C), Color(0xFF6A1B9A)],
      accent: Color(0xFFCE93D8),
      particle: '♫',
    ),
    _OnboardingData(
      titleAr: 'تَتَبَّعْ',
      title: 'Track Your Journey',
      subtitle: 'Bookmark verses, build reading streaks, and track your memorization progress day by day.',
      icon: Icons.track_changes_rounded,
      gradient: [Color(0xFF7B3F00), Color(0xFFC47F1A)],
      accent: Color(0xFFFFD54F),
      particle: '★',
    ),
    _OnboardingData(
      titleAr: 'صَلِّ',
      title: 'Prayer Times & Qibla',
      subtitle: 'Precise prayer times by GPS, Athan alerts, and an accurate Qibla compass wherever you are.',
      icon: Icons.explore_rounded,
      gradient: [Color(0xFF006064), Color(0xFF00838F)],
      accent: Color(0xFF80DEEA),
      particle: '◈',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    _bgController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    HapticFeedback.lightImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  void _nextPage() {
    HapticFeedback.selectionClick();
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: page.gradient,
          ),
        ),
        child: Stack(
          children: [
            // Floating particle background
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (_, __) => CustomPaint(
                  painter: _ParticlePainter(
                    progress: _bgController.value,
                    symbol: page.particle,
                    color: page.accent,
                  ),
                ),
              ),
            ),

            // Content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 16, top: 8),
                      child: TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Page view
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: (i) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _currentPage = i;
                          _entryController.forward(from: 0);
                        });
                      },
                      itemBuilder: (_, i) =>
                          _PageContent(data: _pages[i], controller: _entryController),
                    ),
                  ),

                  // Indicators
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      final sel = i == _currentPage;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: sel ? 28 : 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: sel ? page.accent : Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // CTA Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: GestureDetector(
                      onTap: _nextPage,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: page.accent,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: page.accent.withOpacity(0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started 🌟'
                                : 'Continue →',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: page.gradient.last,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageContent extends StatelessWidget {
  final _OnboardingData data;
  final AnimationController controller;

  const _PageContent({required this.data, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) => Opacity(
        opacity: controller.value,
        child: Transform.translate(
          offset: Offset(0, 30 * (1 - controller.value)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon in glowing circle
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: data.accent.withOpacity(0.15),
                    border: Border.all(
                      color: data.accent.withOpacity(0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.accent.withOpacity(0.3),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(data.icon, size: 70, color: data.accent),
                ),
                const SizedBox(height: 36),

                // Arabic heading
                Text(
                  data.titleAr,
                  style: TextStyle(
                    fontSize: 32,
                    color: data.accent.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // English title
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Subtitle
                Text(
                  data.subtitle,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingData {
  final String titleAr;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final Color accent;
  final String particle;

  const _OnboardingData({
    required this.titleAr,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.accent,
    required this.particle,
  });
}

class _ParticlePainter extends CustomPainter {
  final double progress;
  final String symbol;
  final Color color;

  _ParticlePainter({required this.progress, required this.symbol, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withOpacity(0.07);
    final positions = [
      Offset(size.width * 0.1, size.height * 0.15),
      Offset(size.width * 0.88, size.height * 0.1),
      Offset(size.width * 0.05, size.height * 0.7),
      Offset(size.width * 0.92, size.height * 0.6),
      Offset(size.width * 0.5, size.height * 0.05),
      Offset(size.width * 0.35, size.height * 0.88),
      Offset(size.width * 0.75, size.height * 0.82),
    ];
    for (int i = 0; i < positions.length; i++) {
      final r = 30.0 + (i * 15) + (progress * 10 * (i % 2 == 0 ? 1 : -1));
      canvas.drawCircle(positions[i], r, paint);
    }
    // Stars
    final starPaint = Paint()
      ..color = color.withOpacity(0.1 + progress * 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    for (int i = 0; i < 4; i++) {
      final cx = size.width * (0.2 + i * 0.23);
      final cy =
          size.height * (0.3 + math.sin(progress * math.pi + i) * 0.12);
      canvas.drawCircle(Offset(cx, cy), 8 + i * 4.0, starPaint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) =>
      old.progress != progress || old.symbol != symbol;
}
