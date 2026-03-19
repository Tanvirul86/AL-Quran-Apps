import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../providers/quran_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/audio_provider.dart';
import '../providers/bookmark_provider.dart';
import '../services/database_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ayah_widget.dart';
import '../widgets/audio_controls_widget.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/juz_navigation_widget.dart';
import '../widgets/reading_progress_widget.dart';
import '../widgets/reading_controls_sheet.dart';
import 'reciter_selector_screen.dart';

class AyahReadingScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;
  final bool arabicOnlyMode;

  const AyahReadingScreen({
    super.key,
    required this.surah,
    this.initialAyah,
    this.arabicOnlyMode = false,
  });

  @override
  State<AyahReadingScreen> createState() => _AyahReadingScreenState();
}

class _AyahReadingScreenState extends State<AyahReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _ayahItemKeys = {};
  List<Ayah> _ayahs = [];
  List<Ayah> _processedAyahs = [];
  bool _isLoading = true;
  Map<int, bool> _bookmarkedAyahs = {};
  int _currentVisibleAyah = 1;
  AudioProvider? _audioProvider;
  VoidCallback? _audioListener;
  int? _lastScrolledToAyah; // Track which ayah we've scrolled to (different from playing)
  ReadingMode _readingMode = ReadingMode.day;
  
  // Bismillah text
  static const String _bismillahText = "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ";
  static const String _bismillahEnglish = "In the name of Allah, the Entirely Merciful, the Especially Merciful.";
  static const String _bismillahBangla = "শুরু করছি আল্লাহর নামে যিনি পরম করুণাময়, অতি দয়ালু।";

  @override
  void initState() {
    super.initState();
    _loadAyahs();
    _loadBookmarks();
    _loadLastReadPosition();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<AudioProvider>();
    if (_audioProvider != provider) {
      if (_audioProvider != null && _audioListener != null) {
        _audioProvider!.removeListener(_audioListener!);
      }
      _audioProvider = provider;
      _audioListener = _handleAudioProgress;
      _audioProvider!.addListener(_audioListener!);
    }
  }

  void _handleAudioProgress() {
    if (!mounted || _audioProvider == null || _processedAyahs.isEmpty) {
      return;
    }

    final currentSurah = _audioProvider!.currentSurah;
    final currentAyah = _audioProvider!.currentAyah;

    // Exit early if not in this surah
    if (currentSurah != widget.surah.number || currentAyah == null) {
      return;
    }

    // Update visible ayah for UI state
    if (_currentVisibleAyah != currentAyah) {
      setState(() {
        _currentVisibleAyah = currentAyah;
      });
      _saveReadingProgress(currentAyah);
    }

    // Scroll only when ayah changes (not on every position update)
    // The word highlighting updates smoothly via AyahWidget's watch of AudioProvider
    if (_lastScrolledToAyah != currentAyah) {
      _lastScrolledToAyah = currentAyah;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _scrollToAyah(currentAyah);
      });
    }
  }

  Future<void> _loadAyahs() async {
    final quranProvider = context.read<QuranProvider>();
    final ayahs = await quranProvider.loadAyahs(widget.surah.number);
    

    
    // Process ayahs to separate Bismillah
    final processedAyahs = _processAyahsForBismillah(ayahs);
    

    
    setState(() {
      _ayahs = ayahs;
      _processedAyahs = processedAyahs;
      _ayahItemKeys
        ..clear()
        ..addEntries(
          processedAyahs.map(
            (a) => MapEntry(a.ayahNumber, GlobalKey()),
          ),
        );
      _isLoading = false;
    });
    
    // If an initial ayah is specified, scroll to it after build
    if (widget.initialAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(widget.initialAyah!);
      });
    }
  }

  Future<void> _loadBookmarks() async {
    final bookmarkProvider = context.read<BookmarkProvider>();
    for (final ayah in _ayahs) {
      final isBookmarked = await bookmarkProvider.isBookmarked(
        ayah.surahNumber,
        ayah.ayahNumber,
      );
      setState(() {
        _bookmarkedAyahs[ayah.ayahNumber] = isBookmarked;
      });
    }
  }

  Future<void> _loadLastReadPosition() async {
    final db = DatabaseService();
    final lastRead = await db.getLastReadAyah();
    if (lastRead != null && lastRead['surahNumber'] == widget.surah.number) {
      final ayahNumber = lastRead['ayahNumber']!;
      // Scroll to last read ayah after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToAyah(ayahNumber);
      });
    }
  }

  void _scrollToAyah(int ayahNumber) {
    if (_scrollController.positions.isEmpty || _processedAyahs.isEmpty) return;

    final targetKey = _ayahItemKeys[ayahNumber];
    final targetContext = targetKey?.currentContext;
    if (targetContext != null) {
      // Keep currently reciting ayah around the middle of the screen.
      Scrollable.ensureVisible(
        targetContext,
        alignment: 0.5,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeInOutCubic,
      );
      return;
    }

    final index = _processedAyahs.indexWhere((ayah) => ayah.ayahNumber == ayahNumber);
    if (index == -1) return;

    // Fallback centered offset calculation if key-based ensureVisible is not ready yet.
    const baseItemHeight = 140.0; // Refined average for variable content
    final adjustedIndex = _shouldShowBismillah() ? index + 1 : index;
    
    // Position target ayah near screen center.
    final viewportHeight = _scrollController.position.viewportDimension;
    final targetVisiblePosition = viewportHeight / 2;
    final scrollOffset = (adjustedIndex * baseItemHeight) - targetVisiblePosition;
    
    // Clamp to valid range
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = scrollOffset.clamp(0.0, maxScroll);
    
    // Use smooth animation with adaptive duration based on distance
    final currentOffset = _scrollController.offset;
    final distance = (targetOffset - currentOffset).abs();
    final duration = Duration(
      milliseconds: (300 + (distance * 0.5).toInt()).clamp(200, 800),
    );
    
    _scrollController.animateTo(
      targetOffset,
      duration: duration,
      curve: Curves.easeInOutCubic,
    );
  }

  bool _isSurahWithStandaloneBismillah() {
    // Standalone bismillah is shown for all surahs except Al-Fatiha (1) and At-Tawbah (9)
    return widget.surah.number != 1 && widget.surah.number != 9;
  }

  bool _shouldShowBismillah() {
    if (!_isSurahWithStandaloneBismillah()) return false;
    if (_processedAyahs.isEmpty) return true;

    // If first ayah still contains leading bismillah in any script variant,
    // don't render standalone bismillah to avoid duplication.
    final first = _processedAyahs.first;
    return !_hasLeadingBismillah(first);
  }

  List<Ayah> _processAyahsForBismillah(List<Ayah> ayahs) {
    if (!_isSurahWithStandaloneBismillah() || ayahs.isEmpty) {
      return ayahs;
    }

    // Process first ayah to remove Bismillah if it's merged
    final processedAyahs = <Ayah>[];
    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      if (i == 0) {
        // Remove Bismillah from the beginning of the first ayah.
        String cleanArabic = _stripLeadingBismillah(ayah.arabicText.trim());
        final cleanUthmani = _stripLeadingBismillahNullable(ayah.uthmaniText);
        final cleanIndopak = _stripLeadingBismillahNullable(ayah.indopakText);
        final cleanTajweed = _stripLeadingBismillahNullable(ayah.tajweedText);

        // Only add ayah if there's content remaining after removing Bismillah
        if (cleanArabic.isNotEmpty) {
          final cleanAyah = Ayah(
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            globalAyahNumber: ayah.globalAyahNumber,
            arabicText: cleanArabic,
            uthmaniText: cleanUthmani,
            indopakText: cleanIndopak,
            tajweedText: cleanTajweed,
            englishTranslation: ayah.englishTranslation,
            banglaTranslation: ayah.banglaTranslation,
            transliteration: ayah.transliteration,
            translations: ayah.translations,
          );
          processedAyahs.add(cleanAyah);
        }
        // If cleanArabic is empty after removing Bismillah, skip this ayah entirely
      } else {
        processedAyahs.add(ayah);
      }
    }
    
    return processedAyahs;
  }

  String _stripLeadingBismillah(String text) {
    var clean = text.trim();

    // Robust prefix strip for forms where exact diacritic matching fails.
    final hasBism = clean.contains('بسم') || clean.contains('بِسْم');
    final hasRahman = clean.contains('الرحمن') || clean.contains('ٱلرَّحۡمَ') || clean.contains('الرَّحْم');
    final rahimMatch = RegExp(r'رح[يی]م').firstMatch(clean);
    if (hasBism && hasRahman && rahimMatch != null) {
      final bismIndex = clean.indexOf('بسم') >= 0 ? clean.indexOf('بسم') : clean.indexOf('بِسْم');
      if (bismIndex >= 0 && bismIndex <= 20 && rahimMatch.start <= 90) {
        final cut = rahimMatch.end;
        final tail = clean.substring(cut).trim();
        if (tail.isNotEmpty) {
          return tail;
        }
      }
    }

    final endings = <String>[
      'ٱلرَّحِيمِ',
      'ٱلرَّحِیمِ',
      'الرَّحِيمِ',
      'الرَّحِیمِ',
      'الرَّحِيمِ',
      'الرَّحِیمِ',
      'الرحيم',
      'الرحیم',
    ];

    for (final endWord in endings) {
      final idx = clean.indexOf(endWord);
      if (idx != -1 && idx < 40) {
        final cut = idx + endWord.length;
        clean = clean.substring(cut).trim();
        break;
      }
    }

    return clean;
  }

  String? _stripLeadingBismillahNullable(String? text) {
    if (text == null) return null;
    final stripped = _stripLeadingBismillah(text.trim());
    return stripped.isEmpty ? null : stripped;
  }

  bool _hasLeadingBismillah(Ayah ayah) {
    final candidates = <String?>[
      ayah.arabicText,
      ayah.uthmaniText,
      ayah.indopakText,
      ayah.tajweedText,
    ];

    for (final raw in candidates) {
      if (raw == null || raw.trim().isEmpty) continue;
      final normalized = _normalizeArabicForMatch(raw);
      if (normalized.length >= 6 && normalized.indexOf('بسم') <= 3) {
        final hasRahman = normalized.contains('الرحمن') || normalized.contains('ٱلرحمن');
        final hasRahim = normalized.contains('الرحيم') || normalized.contains('ٱلرحيم');
        if (hasRahman && hasRahim) {
          return true;
        }
      }
      if (normalized.startsWith('بسماللهالرحمنالرحيم') ||
          normalized.startsWith('بسمٱللهٱلرحمنٱلرحيم')) {
        return true;
      }
    }
    return false;
  }

  String _normalizeArabicForMatch(String input) {
    // Remove common tajweed/html markers for matching only.
    var out = input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'\{[^\}]*\}'), '');

    // Remove Arabic diacritics and tatweel.
    out = out
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]'), '')
        .replaceAll(RegExp(r'\s+'), '');

    return out;
  }

  Widget _buildBismillahWidget() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withOpacity(isDark ? 0.25 : 0.12),
            primary.withOpacity(isDark ? 0.10 : 0.04),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        border: Border(
          bottom: BorderSide(
            color: primary.withOpacity(0.2),
            width: 0.8,
          ),
        ),
      ),
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return Column(
            children: [
              // Ornate top border
              _OrnateDivider(color: primary),
              const SizedBox(height: 18),
              Text(
                _bismillahText,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: AppTheme.arabicFont,
                  fontSize: settings.arabicFontSize + 3,
                  height: 2.0,
                  color: isDark ? Colors.white.withOpacity(0.93) : const Color(0xFF1A1A2E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              if (!widget.arabicOnlyMode && settings.showBangla)
                Text(
                  _bismillahBangla,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.banglaFont,
                    fontSize: settings.banglaFontSize - 1,
                    color: isDark ? Colors.white.withOpacity(0.55) : const Color(0xFF4A4A6A),
                    height: 1.6,
                  ),
                ),
              if (!widget.arabicOnlyMode && settings.showEnglish) ...[  
                const SizedBox(height: 4),
                Text(
                  _bismillahEnglish,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: AppTheme.englishFont,
                    fontSize: settings.englishFontSize - 1,
                    color: isDark ? Colors.white.withOpacity(0.50) : const Color(0xFF6A6A8A),
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _OrnateDivider(color: primary),
            ],
          );
        },
      ),
    );
  }

  Future<void> _saveReadingProgress(int ayahNumber) async {
    final db = DatabaseService();
    await db.saveReadingProgress(widget.surah.number, ayahNumber);
    
    // Also save to SharedPreferences for Dashboard quick access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_surah_name', widget.surah.englishName);
    await prefs.setInt('last_read_surah', widget.surah.number);
    await prefs.setInt('last_read_ayah', ayahNumber);
    // Save the reading mode (Arabic-only or normal)
    await prefs.setBool('last_read_arabic_only_mode', widget.arabicOnlyMode);
    
    // Update reading streak
    if (mounted) {
      // Reading goal provider logic could go here if exposed
    }
  }

  @override
  void dispose() {
    if (_audioProvider != null && _audioListener != null) {
      _audioProvider!.removeListener(_audioListener!);
    }
    _scrollController.dispose();
    _audioProvider?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = Theme.of(context).primaryColor;
    // Reading mode background
    final readingBg = isDark && _readingMode == ReadingMode.day
        ? const Color(0xFF141414)
        : ReadingModeColors.background(_readingMode);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < -600) {
          _navigateToNextSurah();
        } else if (details.primaryVelocity! > 600) {
          _navigateToPreviousSurah();
        }
      },
      child: Scaffold(
        backgroundColor: readingBg,
        appBar: AppBar(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.surah.englishName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                '${widget.surah.revelationType} • ${widget.surah.totalAyahs} Verses',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(24),
            child: Column(
              children: [
                // Ayah counter label
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Ayah $_currentVisibleAyah/${widget.surah.totalAyahs}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${((_currentVisibleAyah / (widget.surah.totalAyahs == 0 ? 1 : widget.surah.totalAyahs)) * 100).round()}%',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                // Animated progress bar
                TweenAnimationBuilder<double>(
                  tween: Tween(
                    begin: 0,
                    end: _currentVisibleAyah / (widget.surah.totalAyahs == 0 ? 1 : widget.surah.totalAyahs),
                  ),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => LinearProgressIndicator(
                    value: value,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD4AF37)),
                    minHeight: 3,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            // Reading controls (mode + font)
            IconButton(
              icon: const Icon(Icons.text_fields_rounded, color: Colors.white),
              tooltip: 'Reading Controls',
              onPressed: () {
                showReadingControlsSheet(
                  context,
                  currentMode: _readingMode,
                  onModeChanged: (mode) {
                    setState(() => _readingMode = mode);
                  },
                );
              },
            ),
            // Reciter selector + ayah-wise playback
            IconButton(
              icon: const Icon(Icons.headphones_rounded, color: Colors.white),
              tooltip: 'Select Qari & Play Ayah by Ayah',
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReciterSelectorScreen(),
                  ),
                );

                if (!mounted) return;

                final startAyah = _currentVisibleAyah.clamp(1, widget.surah.totalAyahs);
                await context.read<AudioProvider>().playAyah(
                      widget.surah.number,
                      startAyah,
                      totalAyahs: widget.surah.totalAyahs,
                    );
              },
            ),
            // Juz navigation
            IconButton(
              icon: const Icon(Icons.menu_book_outlined, color: Colors.white),
              tooltip: 'Jump to Juz',
              onPressed: () {
                showJuzNavigation(
                  context,
                  onJuzSelected: (juzNumber) async {
                    Navigator.pop(context);
                    final juzInfo = JuzNavigationWidget.juzInfo[juzNumber];
                    if (juzInfo != null) {
                      final surahNumber = juzInfo['surah'] as int;
                      final ayahNumber = juzInfo['ayah'] as int;
                      final quranProvider = context.read<QuranProvider>();
                      final targetSurah = quranProvider.surahs.firstWhere(
                        (s) => s.number == surahNumber,
                        orElse: () => quranProvider.surahs.first,
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AyahReadingScreen(
                            surah: targetSurah,
                            initialAyah: ayahNumber,
                            arabicOnlyMode: widget.arabicOnlyMode,
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: _isLoading
            ? const LoadingSkeletons(type: 'ayah', count: 5)
            : Column(
                children: [
                  // Surah header banner
                  if (!widget.arabicOnlyMode)
                    _SurahHeaderBanner(
                      surah: widget.surah,
                      primary: primary,
                      isDark: isDark,
                    ),

                  // Reading progress
                  if (!widget.arabicOnlyMode)
                    ReadingProgressWidget(
                      surahNumber: widget.surah.number,
                      currentAyahNumber: _currentVisibleAyah,
                    ),

                  // Ayah list
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: _processedAyahs.length +
                          (_shouldShowBismillah() ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (_shouldShowBismillah() && index == 0) {
                          return _buildBismillahWidget();
                        }
                        final ayahIndex =
                            _shouldShowBismillah() ? index - 1 : index;
                        final ayah = _processedAyahs[ayahIndex];
                        return KeyedSubtree(
                          key: _ayahItemKeys[ayah.ayahNumber],
                          child: AyahWidget(
                            ayah: ayah,
                            arabicOnlyMode: widget.arabicOnlyMode,
                            isBookmarked:
                                _bookmarkedAyahs[ayah.ayahNumber] ?? false,
                            onBookmarkToggle: () async {
                              final bookmarkProvider =
                                  context.read<BookmarkProvider>();
                              await bookmarkProvider.toggleBookmark(
                                ayah.surahNumber,
                                ayah.ayahNumber,
                              );
                              setState(() {
                                _bookmarkedAyahs[ayah.ayahNumber] =
                                    !(_bookmarkedAyahs[ayah.ayahNumber] ?? false);
                              });
                            },
                            onPlay: () {
                              context.read<AudioProvider>().playAyah(
                                    ayah.surahNumber,
                                    ayah.ayahNumber,
                                    totalAyahs: widget.surah.totalAyahs,
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  // Audio player bar
                  const AudioControlsWidget(),
                ],
              ),
      ),
    );
  }

  void _navigateToNextSurah() {
    if (widget.surah.number < 114) {
      final quranProvider = context.read<QuranProvider>();
      final nextSurah = quranProvider.surahs.firstWhere(
        (s) => s.number == widget.surah.number + 1,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AyahReadingScreen(
            surah: nextSurah,
            arabicOnlyMode: widget.arabicOnlyMode,
          ),
        ),
      );
    }
  }

  void _navigateToPreviousSurah() {
    if (widget.surah.number > 1) {
      final quranProvider = context.read<QuranProvider>();
      final prevSurah = quranProvider.surahs.firstWhere(
        (s) => s.number == widget.surah.number - 1,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AyahReadingScreen(
            surah: prevSurah,
            arabicOnlyMode: widget.arabicOnlyMode,
          ),
        ),
      );
    }
  }
}

// ─── Ornate divider (decorative Islamic chapter separator) ─────────────────
class _OrnateDivider extends StatelessWidget {
  final Color color;
  const _OrnateDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: color.withOpacity(0.35), thickness: 0.8)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.diamond_outlined, size: 10, color: color.withOpacity(0.7)),
        ),
        SizedBox(
          width: 24,
          child: Center(
            child: Transform.rotate(
              angle: 0.785,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  border: Border.all(color: color.withOpacity(0.7), width: 1.2),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Icon(Icons.diamond_outlined, size: 10, color: color.withOpacity(0.7)),
        ),
        Expanded(child: Divider(color: color.withOpacity(0.35), thickness: 0.8)),
      ],
    );
  }
}

// ─── Surah header banner ────────────────────────────────────────────────────
class _SurahHeaderBanner extends StatelessWidget {
  final Surah surah;
  final Color primary;
  final bool isDark;

  const _SurahHeaderBanner({
    required this.surah,
    required this.primary,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final goldenAccent = isDark ? const Color(0xFFD4AF37) : const Color(0xFFB8860B);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary,
            primary.withOpacity(0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          // Surah number badge + Arabic name
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
                  color: Colors.white.withOpacity(0.15),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${surah.number}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                surah.arabicName,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 28,
                  color: Colors.white,
                  height: 1.3,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 14),
              const SizedBox(width: 32), // balance
            ],
          ),
          const SizedBox(height: 6),
          // English + Bangla name
          Text(
            '${surah.englishName}  •  ${surah.banglaName}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.88),
              fontSize: 13,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 10),
          // Metadata row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _badge('${surah.totalAyahs} Verses', goldenAccent),
              const SizedBox(width: 8),
              _badge(surah.revelationType, goldenAccent),
              const SizedBox(width: 8),
              _badge('Juz ${_getJuzNumber(surah.number)}', goldenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _badge(String label, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withOpacity(0.6), width: 0.8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  int _getJuzNumber(int surahNumber) {
    const juzBoundaries = [
      2, 2, 3, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 15, 16,
      17, 17, 18, 19, 19, 20, 21, 22, 22, 23, 24, 25, 25, 26, 26, 27,
      27, 27, 28, 28, 28, 28, 29, 29, 29, 29, 29, 30, 30, 30, 30, 30,
      30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
      30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30,
    ];
    if (surahNumber < 1 || surahNumber > 114) return 1;
    return juzBoundaries[surahNumber - 1];
  }
}

