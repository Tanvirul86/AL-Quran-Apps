import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/quran_provider.dart';
import '../models/surah.dart';
import '../widgets/daily_ayah_widget.dart';
import '../widgets/skeleton_loading.dart';
import '../theme/app_theme.dart';
import 'ayah_reading_screen.dart';
import 'prayer_times_screen.dart';
import 'qibla_compass_screen.dart';
import 'reading_streak_screen.dart';
import 'bookmarks_screen.dart';
import 'memorization_dashboard_screen.dart';
import 'enhanced_search_screen.dart';
import 'downloads_screen.dart';
import 'translations_selector_screen.dart';
import 'juz_navigation_screen.dart';
import 'analytics_dashboard_screen.dart';
import 'mushaf_page_screen.dart';
import 'inspiration_categories_screen.dart';
import 'dua_categories_screen.dart';
import 'tasbih_screen.dart';
import 'forty_hadith_screen.dart';
import 'biography_categories_screen.dart';
import 'islamic_months_screen.dart';
import '../services/mushaf_service.dart';

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
    setState(() {
      _lastReadSurah = prefs.getString('last_read_surah_name');
      _lastReadSurahNumber = prefs.getInt('last_read_surah');
      _lastReadAyah = prefs.getInt('last_read_ayah');
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
            onPressed: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
      body: Consumer<QuranProvider>(
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
                      ),
                      const SizedBox(height: 14),
                      // Continue Reading Button (Full Width)
                      _buildContinueReadingQuickAction(context),
                      const SizedBox(height: 12),
                      // Row 1
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Prayer Times',
                              Icons.access_time_filled,
                              Colors.orange,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Qibla',
                              Icons.explore,
                              Colors.teal,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const QiblaCompassScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Daily Duas',
                              Icons.favorite,
                              Colors.pink,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const DuaCategoriesScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 2
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Jump to Juz',
                              Icons.menu_book,
                              Colors.indigo,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const JuzNavigationScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Inspiration',
                              Icons.auto_awesome,
                              Colors.amber,
                              () => _showDailyInspirationDialog(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Mushaf Pages',
                              Icons.auto_stories,
                              Colors.brown,
                              () async {
                                final mushafService = MushafService();
                                final lastPage = await mushafService.getLastReadPage();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MushafPageScreen(initialPage: lastPage),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 3 - Additional Actions
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Tasbih',
                              Icons.radio_button_checked,
                              Colors.cyan,
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TasbihScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              '40 Hadith',
                              Icons.menu_book_rounded,
                              const Color(0xFF6A1B9A), // Deep purple color matching app theme
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FortyHadithScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Biographies',
                              Icons.people,
                              const Color(0xFF795548), // Brown color matching app theme
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const BiographyCategoriesScreen()),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Row 4 - Islamic Months
                      Row(
                        children: [
                          Expanded(
                            child: _buildQuickActionButton(
                              context,
                              'Islamic Months',
                              Icons.calendar_month,
                              const Color(0xFF00796B), // Teal color
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const IslamicMonthsScreen()),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox()), // Empty space
                          const SizedBox(width: 12),
                          const Expanded(child: SizedBox()), // Empty space
                        ],
                      ),
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
                            builder: (context) => AyahReadingScreen(surah: surah),
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
    );
  }

  Widget _buildLastReadCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          transform: const GradientRotation(45 * 3.14159 / 180),
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _lastReadSurahNumber != null
              ? () {
                  final surah = context.read<QuranProvider>().surahs.firstWhere(
                    (s) => s.number == _lastReadSurahNumber,
                    orElse: () => context.read<QuranProvider>().surahs.first,
                  );
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AyahReadingScreen(surah: surah),
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: Colors.white.withOpacity(0.9),
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Continue Reading',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _lastReadSurah ?? 'Start Reading',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _lastReadSurahNumber != null 
                          ? 'Ayah $_lastReadAyah'
                          : 'Open Qur\'an to begin',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinueReadingQuickAction(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showContinueReadingOptions(context),
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white.withOpacity(0.2),
        highlightColor: Colors.white.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.85),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.25),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white,
                  size: 22,
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
                        color: Colors.white.withOpacity(0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _lastReadSurah != null 
                          ? '$_lastReadSurah • Ayah $_lastReadAyah'
                          : 'Tap to start reading',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 18,
                ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContinueReadingOptions(BuildContext context) {
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
            
            // Surah Mode Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.list_alt, color: Colors.blue),
              ),
              title: const Text('Surah Mode'),
              subtitle: Text(_lastReadSurah ?? 'Continue from where you left off'),
              onTap: () {
                Navigator.pop(context);
                final surahs = context.read<QuranProvider>().surahs;
                if (surahs.isEmpty) return;
                
                final surah = _lastReadSurahNumber != null
                    ? surahs.firstWhere(
                        (s) => s.number == _lastReadSurahNumber,
                        orElse: () => surahs.first,
                      )
                    : surahs.first;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AyahReadingScreen(surah: surah),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 16),
            
            // Mushaf Mode Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.brown.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.auto_stories, color: Colors.brown),
              ),
              title: const Text('Mushaf Pages'),
              subtitle: const Text('Read page by page like real Quran'),
              onTap: () async {
                Navigator.pop(context);
                final mushafService = MushafService();
                final lastPage = await mushafService.getLastReadPage();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MushafPageScreen(initialPage: lastPage),
                  ),
                );
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
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
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
