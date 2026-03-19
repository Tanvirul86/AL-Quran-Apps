import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../models/surah.dart';
import '../widgets/daily_ayah_widget.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/empty_state_widget.dart';
import '../theme/app_theme.dart';
import 'ayah_reading_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/spiritual_background.dart';
import '../widgets/quran_text_settings_sheet.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

class SurahListScreen extends StatefulWidget {
  final bool arabicOnlyMode;

  const SurahListScreen({
    super.key,
    this.arabicOnlyMode = false,
  });

  @override
  State<SurahListScreen> createState() => _SurahListScreenState();
}

class _SurahListScreenState extends State<SurahListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  bool _showScrollTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 400;
      if (show != _showScrollTop) setState(() => _showScrollTop = show);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Surah> _filtered(List<Surah> surahs) {
    var list = surahs;
    if (_query.trim().isNotEmpty) {
      final q = _query.toLowerCase();
      list = list.where((s) =>
          s.englishName.toLowerCase().contains(q) ||
          s.number.toString().contains(q) ||
          s.banglaName.contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.arabicOnlyMode ? 'Quran Sharif' : "Qur'an"),
        actions: [
          IconButton(
            icon: const Icon(Icons.text_fields_rounded),
            tooltip: 'Quran Text Settings',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => const QuranTextSettingsSheet(),
              );
            },
          ),
        ],
      ),
      // Scroll-to-top FAB
      floatingActionButton: AnimatedScale(
        scale: _showScrollTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: FloatingActionButton.small(
          onPressed: () {
            HapticFeedback.lightImpact();
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            );
          },
          backgroundColor: primary,
          child: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
        ),
      ),
      body: SpiritualBackground(
        child: Consumer<QuranProvider>(
          builder: (context, quranProvider, _) {
            if (quranProvider.isLoading) {
              return const LoadingSkeletons(type: 'surah', count: 10);
            }
            if (quranProvider.error != null) {
              return EmptyStates.error(
                context,
                message: quranProvider.error!,
                onRetry: () => quranProvider.loadSurahs(),
              );
            }
            final surahs = _filtered(quranProvider.surahs);

            return CustomScrollView(
              controller: _scrollController,
              slivers: [
                // Daily Ayah widget
                if (!widget.arabicOnlyMode)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: const DailyAyahWidget()
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.1),
                    ),
                  ),

                // Search header
                SliverToBoxAdapter(
                  child: _SearchSection(
                    searchController: _searchController,
                    isDark: isDark,
                    primary: primary,
                    onQueryChanged: (v) => setState(() => _query = v),
                  ),
                ),

                if (surahs.isEmpty)
                  SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No surahs match "$_query"',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final surah = surahs[index];
                          return _SurahListItem(surah: surah, onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, anim, __) => AyahReadingScreen(
                                  surah: surah,
                                  arabicOnlyMode: widget.arabicOnlyMode,
                                ),
                                transitionsBuilder: (_, anim, __, child) => FadeTransition(
                                  opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                                  child: SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(0, 0.04),
                                      end: Offset.zero,
                                    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                                    child: child,
                                  ),
                                ),
                                transitionDuration: const Duration(milliseconds: 350),
                              ),
                            );
                          });
                        },
                        childCount: surahs.length,
                      ),
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

class _SearchSection extends StatelessWidget {
  final TextEditingController searchController;
  final bool isDark;
  final Color primary;
  final ValueChanged<String> onQueryChanged;

  const _SearchSection({
    required this.searchController,
    required this.isDark,
    required this.primary,
    required this.onQueryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF111827) : Colors.white;
    return Container(
      color: bg.withOpacity(0.97),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search bar
          TextField(
            controller: searchController,
            onChanged: onQueryChanged,
            decoration: InputDecoration(
              hintText: 'Search Surah name or number...',
              hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              prefixIcon: Icon(Icons.search, color: primary, size: 20),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        searchController.clear();
                        onQueryChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: isDark ? Colors.white10 : Colors.grey.shade100,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahListItem({required this.surah, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    final titleColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final subtitleColor = isDark ? Colors.white70 : const Color(0xFF4A4A4A);

    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              // 8-point Islamic star badge
              SizedBox(
                width: 50,
                height: 50,
                child: CustomPaint(
                  painter: _IslamicStarBadgePainter(
                    color: primary,
                    number: surah.number,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            surah.englishName,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.3,
                              color: null,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            surah.revelationType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            surah.banglaName,
                            maxLines: 2,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 13,
                              color: subtitleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 92),
                          child: Text(
                            '• ${surah.totalAyahs} ayahs',
                            maxLines: 1,
                            overflow: TextOverflow.fade,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor.withOpacity(0.85),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Arabic name
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 105),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    surah.arabicName,
                    textAlign: TextAlign.right,
                    style: AppTheme.arabicTextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 8-point star badge painter
class _IslamicStarBadgePainter extends CustomPainter {
  final Color color;
  final int number;

  _IslamicStarBadgePainter({required this.color, required this.number});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final outer = size.width / 2;
    final inner = outer * 0.5;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [color, color.withOpacity(0.75)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: outer));

    final shadowPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    const points = 8;
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outer : inner;
      final angle = (i * math.pi / points) - math.pi / 2;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, fillPaint);

    // Number text
    final tp = TextPainter(
      text: TextSpan(
        text: '$number',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_IslamicStarBadgePainter old) =>
      old.color != color || old.number != number;
}
