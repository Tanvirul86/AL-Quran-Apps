import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/quran_provider.dart';
import '../models/surah.dart';
import '../widgets/skeleton_loading.dart';
import '../theme/app_theme.dart';
import 'ayah_reading_screen.dart';
import 'prayer_times_screen.dart';
import 'juz_navigation_screen.dart';
import 'inspiration_categories_screen.dart';
import 'dua_categories_screen.dart';
import 'tasbih_screen.dart';
import 'forty_hadith_screen.dart';
import 'biography_categories_screen.dart';
import 'islamic_months_screen.dart';
import 'asmaul_husna_screen.dart';
import 'notification_settings_screen.dart';
import '../widgets/glass_card.dart';
import '../widgets/spiritual_background.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'surah_list_screen.dart';
import '../providers/settings_provider.dart';
import '../services/database_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? _lastReadSurah;
  int? _lastReadSurahNumber;
  int? _lastReadAyah;

  @override
  void initState() {
    super.initState();
    _loadLastRead();
  }

  Future<void> _loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final db = DatabaseService();
    final dbLastRead = await db.getLastReadAyah();

    final rawSurahName = prefs.getString('last_read_surah_name');
    final rawSurahNumber = dbLastRead?['surahNumber'] ?? prefs.getInt('last_read_surah');
    final rawAyah = dbLastRead?['ayahNumber'] ?? prefs.getInt('last_read_ayah');

    // Guard against legacy values where Mushaf page text was stored in surah keys.
    final hasValidSurah =
        rawSurahNumber != null && rawSurahNumber >= 1 && rawSurahNumber <= 114;
    final looksLikeMushafText =
        (rawSurahName ?? '').toLowerCase().contains('page') ||
        (rawSurahName ?? '').toLowerCase().contains('mushaf') ||
        (rawSurahName ?? '').contains('পেজ');

    setState(() {
      _lastReadSurah = (!hasValidSurah || looksLikeMushafText) ? null : rawSurahName;
      _lastReadSurahNumber = hasValidSurah ? rawSurahNumber : null;
      _lastReadAyah = hasValidSurah ? rawAyah : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Al-Quran Pro'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            tooltip: 'Notification Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SpiritualBackground(
        child: Consumer<QuranProvider>(
          builder: (context, quranProvider, _) {
            if (quranProvider.isLoading) {
              return const LoadingSkeletons(type: 'surah', count: 8);
            }

            final surahs = quranProvider.surahs;

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Quick Actions Header
                        Row(
                          children: [
                            Icon(
                              Icons.flash_on,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        )
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideX(begin: -0.1),
                        const SizedBox(height: 14),
                        // Continue Reading Button (Full Width)
                        _buildContinueReadingQuickAction(context)
                            .animate()
                            .fadeIn(delay: 200.ms)
                            .scale(curve: Curves.easeOutBack),
                        const SizedBox(height: 20),
                        // Two-row horizontal quick actions
                        SizedBox(
                          height: 224,
                          child: GridView(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.65,
                            ),
                            children: [
                              _buildQuickActionButton(context, 'Prayer Times',
                                  Icons.schedule, Colors.orange, () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const PrayerTimesScreen()));
                              }),

                              _buildQuickActionButton(context, 'Daily Duas',
                                  Icons.local_florist, Colors.pink, () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const DuaCategoriesScreen()));
                              }),
                              _buildQuickActionButton(context, 'Jump to Juz',
                                  Icons.bookmark_outline, Colors.indigo, () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const JuzNavigationScreen()));
                              }),
                              _buildQuickActionButton(context, 'Inspiration',
                                  Icons.lightbulb_outline, Colors.amber, () {
                                HapticFeedback.lightImpact();
                                _showDailyInspirationDialog(context);
                              }),
                              _buildQuickActionButton(context, 'Al Quran',
                                  Icons.book, Colors.brown, () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SurahListScreen(
                                      arabicOnlyMode: true,
                                    ),
                                  ),
                                );
                              }),
                              _buildQuickActionButton(context, 'Tasbih',
                                  Icons.touch_app, Colors.cyan, () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const TasbihScreen()));
                              }),
                              _buildQuickActionButton(
                                  context,
                                  '40 Hadith',
                                  Icons.library_books,
                                  const Color(0xFF6A1B9A), () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const FortyHadithScreen()));
                              }),
                              _buildQuickActionButton(context, 'Biographies',
                                  Icons.history_edu, const Color(0xFF795548), () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const BiographyCategoriesScreen()));
                              }),
                              _buildQuickActionButton(
                                  context,
                                  'Islamic Months',
                                  Icons.calendar_today,
                                  const Color(0xFF00796B), () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const IslamicMonthsScreen()));
                              }),

                              _buildQuickActionButton(
                                  context,
                                  'Asma ul Husna',
                                  Icons.star_outline,
                                  const Color(0xFF6A1B9A), () {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const AsmaulHusnaScreen()));
                              }),
                            ],
                          ),
                        ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.05),
                        const SizedBox(height: 28),

                        // Surahs Header
                        Row(
                          children: [
                            Icon(
                              Icons.book_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Surahs',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).primaryColor,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Surah List
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final surah = surahs[index];
                      return _SurahListItem(
                        surah: surah,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  AyahReadingScreen(surah: surah),
                            ),
                          );
                          _loadLastRead(); // Refresh last read when returning
                        },
                      );
                    },
                    childCount: surahs.length,
                  ),
                ),
                const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContinueReadingQuickAction(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showContinueReadingOptions(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withOpacity(0.78)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Reading',
                      style: TextStyle(
                        color: primary.withOpacity(0.72),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _lastReadSurah != null
                          ? '$_lastReadSurah • Ayah $_lastReadAyah'
                          : 'Tap to continue Quran text',
                      style: TextStyle(
                        color: primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_rounded,
                color: primary.withOpacity(0.85),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final hasSpace = label.contains(' ');

    return GlassCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 7),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: hasSpace ? 2 : 1,
                softWrap: hasSpace,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 10.5,
                  height: 1.2,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContinueReadingOptions(BuildContext context) async {
    final settings = context.read<SettingsProvider>();
    final progressLabel = _lastReadSurah != null
      ? '$_lastReadSurah • Ayah ${_lastReadAyah ?? 1}'
      : 'Continue from where you left off';
    final selectedLanguages = settings.selectedTranslations
      .map((t) => (t['language'] ?? '').toUpperCase())
      .where((lang) => lang.isNotEmpty)
      .toSet()
      .toList();
    final translationLabel = selectedLanguages.isNotEmpty
      ? '$progressLabel • ${selectedLanguages.join('/')}'
      : progressLabel;

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Continue Reading',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Surah/Quran Text Mode Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.text_fields_rounded, color: Colors.blue),
              ),
              title: const Text('Al Quran'),
              subtitle: Text(progressLabel),
              onTap: () async {
                Navigator.pop(context);
                final surahs = context.read<QuranProvider>().surahs;
                if (surahs.isEmpty) return;

                final surah = _lastReadSurahNumber != null
                    ? surahs.firstWhere(
                        (s) => s.number == _lastReadSurahNumber,
                        orElse: () => surahs.first,
                      )
                    : surahs.first;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AyahReadingScreen(
                      surah: surah,
                      arabicOnlyMode: true,
                    ),
                  ),
                );
                _loadLastRead();
              },
            ),

            const SizedBox(height: 16),

            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.translate_rounded, color: Colors.deepPurple),
              ),
              title: const Text('Translation'),
              subtitle: Text(translationLabel),
              onTap: () async {
                Navigator.pop(context);
                final surahs = context.read<QuranProvider>().surahs;
                if (surahs.isEmpty) return;

                final surah = _lastReadSurahNumber != null
                    ? surahs.firstWhere(
                        (s) => s.number == _lastReadSurahNumber,
                        orElse: () => surahs.first,
                      )
                    : surahs.first;
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AyahReadingScreen(
                      surah: surah,
                      arabicOnlyMode: false,
                    ),
                  ),
                );
                _loadLastRead();
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showDailyInspirationDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InspirationCategoriesScreen(),
      ),
    );
  }
}

class _SurahListItem extends StatelessWidget {
  final Surah surah;
  final VoidCallback onTap;

  const _SurahListItem({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Surah number badge
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${surah.number}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              surah.englishName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .primaryColor
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${surah.totalAyahs} ↓',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        surah.banglaName,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Arabic name
                Text(
                  surah.arabicName,
                  style: AppTheme.arabicTextStyle(
                    fontSize: 22,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
