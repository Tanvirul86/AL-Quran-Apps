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
import '../services/translation_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ayah_widget.dart';
import '../widgets/audio_controls_widget.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/juz_navigation_widget.dart';
import '../widgets/reading_progress_widget.dart';
import '../widgets/full_surah_player.dart';
import 'translations_selector_screen.dart';

class AyahReadingScreen extends StatefulWidget {
  final Surah surah;
  final int? initialAyah;

  const AyahReadingScreen({super.key, required this.surah, this.initialAyah});

  @override
  State<AyahReadingScreen> createState() => _AyahReadingScreenState();
}

class _AyahReadingScreenState extends State<AyahReadingScreen> {
  final ScrollController _scrollController = ScrollController();
  List<Ayah> _ayahs = [];
  List<Ayah> _processedAyahs = [];
  bool _isLoading = true;
  Map<int, bool> _bookmarkedAyahs = {};
  int _currentVisibleAyah = 1;
  
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

  Future<void> _loadAyahs() async {
    final quranProvider = context.read<QuranProvider>();
    final ayahs = await quranProvider.loadAyahs(widget.surah.number);
    
    // Debug: Print first ayah before processing
    if (ayahs.isNotEmpty) {
      print('DEBUG: Original first ayah: ${ayahs.first.arabicText}');
    }
    
    // Process ayahs to separate Bismillah
    final processedAyahs = _processAyahsForBismillah(ayahs);
    
    // Debug: Print first ayah after processing
    if (processedAyahs.isNotEmpty) {
      print('DEBUG: Processed first ayah: ${processedAyahs.first.arabicText}');
    }
    
    setState(() {
      _ayahs = ayahs;
      _processedAyahs = processedAyahs;
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
    final index = _processedAyahs.indexWhere((ayah) => ayah.ayahNumber == ayahNumber);
    if (index != -1) {
      // Account for Bismillah widget if present
      final adjustedIndex = _shouldShowBismillah() ? index + 1 : index;
      _scrollController.animateTo(
        adjustedIndex * 200.0, // Approximate height per ayah
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _shouldShowBismillah() {
    // Show Bismillah for all surahs except Al-Fatiha (1) and At-Tawbah (9)
    return widget.surah.number != 1 && widget.surah.number != 9;
  }

  List<Ayah> _processAyahsForBismillah(List<Ayah> ayahs) {
    if (!_shouldShowBismillah() || ayahs.isEmpty) {
      return ayahs;
    }

    // Process first ayah to remove Bismillah if it's merged
    final processedAyahs = <Ayah>[];
    for (int i = 0; i < ayahs.length; i++) {
      final ayah = ayahs[i];
      if (i == 0) {
        // Remove Bismillah from the beginning of the first ayah
        String cleanArabic = ayah.arabicText.trim();
        
        // Find the end of "ٱلرَّحِیمِ" and remove everything up to and including it
        if (cleanArabic.contains('ٱلرَّحِیمِ')) {
          final endIndex = cleanArabic.indexOf('ٱلرَّحِیمِ') + 'ٱلرَّحِیمِ'.length;
          cleanArabic = cleanArabic.substring(endIndex).trim();
        }
        
        // Only add ayah if there's content remaining after removing Bismillah
        if (cleanArabic.isNotEmpty) {
          final cleanAyah = Ayah(
            surahNumber: ayah.surahNumber,
            ayahNumber: ayah.ayahNumber,
            globalAyahNumber: ayah.globalAyahNumber,
            arabicText: cleanArabic,
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

  Widget _buildBismillahWidget() {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Consumer<SettingsProvider>(
          builder: (context, settings, _) {
            return Column(
              children: [
                // Arabic Bismillah
                Text(
                  _bismillahText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: AppTheme.arabicTextStyle(
                    fontSize: settings.arabicFontSize + 4, // Slightly larger
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Bangla translation
                if (settings.showBangla)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _bismillahBangla,
                      textAlign: TextAlign.center,
                      style: AppTheme.banglaTextStyle(
                        fontSize: settings.banglaFontSize,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                
                if (settings.showBangla && settings.showEnglish)
                  const SizedBox(height: 12),
                
                // English translation
                if (settings.showEnglish)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _bismillahEnglish,
                      textAlign: TextAlign.center,
                      style: AppTheme.englishTextStyle(
                        fontSize: settings.englishFontSize,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
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

  Future<void> _saveReadingProgress(int ayahNumber) async {
    final db = DatabaseService();
    await db.saveReadingProgress(widget.surah.number, ayahNumber);
    
    // Also save to SharedPreferences for Dashboard quick access
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_read_surah_name', widget.surah.englishName);
    await prefs.setInt('last_read_surah', widget.surah.number);
    await prefs.setInt('last_read_ayah', ayahNumber);
    
    // Update reading streak
    if (mounted) {
      // Reading goal provider logic could go here if exposed
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        // Swipe left = next surah, Swipe right = previous surah
        // Adjusted sensitivity for better UX
        if (details.primaryVelocity! < -500) {
          _navigateToNextSurah();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Swiped to next Surah'),
              duration: Duration(milliseconds: 800),
            ),
          );
        } else if (details.primaryVelocity! > 500) {
          _navigateToPreviousSurah();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Swiped to previous Surah'),
              duration: Duration(milliseconds: 800),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.surah.arabicName,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                '${widget.surah.englishName} • ${widget.surah.banglaName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            // Full Surah Player - Listen with World-Known Qaris
            IconButton(
              icon: const Icon(Icons.headphones),
              onPressed: () {
                showFullSurahPlayer(
                  context,
                  surahNumber: widget.surah.number,
                  surahName: '${widget.surah.englishName} - ${widget.surah.arabicName}',
                );
              },
              tooltip: 'Listen Full Surah',
            ),
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () {
                showJuzNavigation(
                  context,
                  onJuzSelected: (juzNumber) async {
                    Navigator.pop(context); // Close the modal
                    
                    // Get the starting surah for this juz
                    final juzInfo = JuzNavigationWidget.juzInfo[juzNumber];
                    if (juzInfo != null) {
                      final surahNumber = juzInfo['surah'] as int;
                      final ayahNumber = juzInfo['ayah'] as int;
                      
                      // Find the surah
                      final quranProvider = context.read<QuranProvider>();
                      final targetSurah = quranProvider.surahs.firstWhere(
                        (s) => s.number == surahNumber,
                        orElse: () => quranProvider.surahs.first,
                      );
                      
                      // Navigate to the surah and specific ayah
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AyahReadingScreen(
                            surah: targetSurah,
                            initialAyah: ayahNumber,
                          ),
                        ),
                      );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Jumped to Juz $juzNumber (${juzInfo['name']})'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
              tooltip: 'Jump to Juz',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search within surah
              },
              tooltip: 'Search in Surah',
            ),
          ],
        ),
        body: _isLoading
            ? const LoadingSkeletons(type: 'ayah', count: 5)
            : Column(
                children: [
                  // Reading progress with enhanced styling
                  ReadingProgressWidget(
                    surahNumber: widget.surah.number,
                    currentAyahNumber: _currentVisibleAyah,
                  ),
                  
                  // Translation selector with multi-select support
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) {
                      final selectedCount = settings.selectedTranslations.length;
                      final selectedText = selectedCount == 0 
                          ? 'None' 
                          : selectedCount == 1
                              ? settings.selectedTranslations[0]['language']!.toUpperCase()
                              : '${selectedCount} selected';
                      
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Show Translations',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const TranslationsSelectorScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.language, size: 18),
                                  label: Text(selectedText),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Horizontal scrollable list of all translation languages
                            SizedBox(
                              height: 40,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.zero,
                                children: [
                                  // English (most popular)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('en'),
                                      label: const Text('English'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('20', 'en');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Bangla/Bengali
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('bn'),
                                      label: const Text('বাংলা'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('161', 'bn');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Hindi
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('hi'),
                                      label: const Text('हिन्दी'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('122', 'hi');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Urdu
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('ur'),
                                      label: const Text('اردو'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('97', 'ur');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Arabic
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('ar'),
                                      label: const Text('العربية'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('90', 'ar');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Indonesian
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('id'),
                                      label: const Text('Indonesia'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('33', 'id');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Turkish
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('tr'),
                                      label: const Text('Türkçe'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('77', 'tr');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // French
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('fr'),
                                      label: const Text('Français'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('31', 'fr');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // German
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('de'),
                                      label: const Text('Deutsch'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('27', 'de');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Spanish
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('es'),
                                      label: const Text('Español'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('83', 'es');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Russian
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('ru'),
                                      label: const Text('Русский'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('45', 'ru');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Persian/Farsi
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('fa'),
                                      label: const Text('فارسی'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('135', 'fa');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Malay
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('ms'),
                                      label: const Text('Melayu'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('39', 'ms');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Chinese
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('zh'),
                                      label: const Text('中文'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('56', 'zh');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Japanese
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('ja'),
                                      label: const Text('日本語'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('35', 'ja');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Korean
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('ko'),
                                      label: const Text('한국어'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('219', 'ko');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Tamil
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('ta'),
                                      label: const Text('தமிழ்'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('229', 'ta');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Thai
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('th'),
                                      label: const Text('ไทย'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('53', 'th');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Swahili
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('sw'),
                                      label: const Text('Kiswahili'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('49', 'sw');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Portuguese
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('pt'),
                                      label: const Text('Português'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('43', 'pt');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Dutch
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('nl'),
                                      label: const Text('Nederlands'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('235', 'nl');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Italian
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('it'),
                                      label: const Text('Italiano'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('153', 'it');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Albanian
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('sq'),
                                      label: const Text('Shqip'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('47', 'sq');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Bosnian
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('bs'),
                                      label: const Text('Bosanski'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('25', 'bs');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                  // Uzbek
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: FilterChip(
                                      selected: settings.isTranslationSelected('uz'),
                                      label: const Text('Oʻzbek'),
                                      onSelected: (value) {
                                        settings.toggleTranslation('55', 'uz');
                                      },
                                      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                                      checkmarkColor: Theme.of(context).primaryColor,
                                      backgroundColor: Theme.of(context).cardColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // Ayahs list with swipe gesture indicator
                  Expanded(
                    child: Stack(
                      children: [
                        ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _processedAyahs.length + (_shouldShowBismillah() ? 1 : 0),
                          itemBuilder: (context, index) {
                            // Show Bismillah widget first if applicable
                            if (_shouldShowBismillah() && index == 0) {
                              return _buildBismillahWidget();
                            }
                            
                            // Adjust index for actual ayah
                            final ayahIndex = _shouldShowBismillah() ? index - 1 : index;
                            final ayah = _processedAyahs[ayahIndex];
                            
                            return AyahWidget(
                              ayah: ayah,
                              isBookmarked: _bookmarkedAyahs[ayah.ayahNumber] ?? false,
                              onBookmarkToggle: () async {
                                final bookmarkProvider = context.read<BookmarkProvider>();
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
                                    );
                              },
                              onVisibilityChanged: () {
                                setState(() {
                                  _currentVisibleAyah = ayah.ayahNumber;
                                });
                                _saveReadingProgress(ayah.ayahNumber);
                              },
                            );
                          },
                        ),
                        // Swipe hint indicator
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Opacity(
                              opacity: 0.4,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.chevron_left, size: 16),
                                  Text(
                                    'Swipe to navigate',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  const Icon(Icons.chevron_right, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Audio controls
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
          builder: (_) => AyahReadingScreen(surah: nextSurah),
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
          builder: (_) => AyahReadingScreen(surah: prevSurah),
        ),
      );
    }
  }


}
