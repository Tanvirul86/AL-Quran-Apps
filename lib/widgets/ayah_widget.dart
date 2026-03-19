import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/ayah.dart';
import '../providers/settings_provider.dart';
import '../providers/audio_provider.dart';
import '../theme/app_theme.dart';
import '../providers/ai_provider.dart';
import 'glass_card.dart';
import 'tafsir_bottom_sheet.dart';
import 'quran_text_settings_sheet.dart';
import '../utils/tajweed_parser.dart';
import '../screens/translations_selector_screen.dart';
import '../services/translation_service.dart';
import '../utils/word_highlighter.dart';

class AyahWidget extends StatelessWidget {
  final Ayah ayah;
  final bool arabicOnlyMode;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onPlay;
  static final TranslationService _translationService = TranslationService();

  const AyahWidget({
    super.key,
    required this.ayah,
    this.arabicOnlyMode = false,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = context.select<AudioProvider, bool>(
      (audio) =>
          audio.currentSurah == ayah.surahNumber &&
          audio.currentAyah == ayah.ayahNumber,
    );

    // CRITICAL: Watch position + duration for smooth word highlighting updates
    // This causes AyahWidget to rebuild whenever audio position changes
    if (isActive) {
      context.watch<AudioProvider>();
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final primary = Theme.of(context).primaryColor;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        final bgColor = isActive
            ? primary.withOpacity(isDark ? 0.15 : 0.07)
            : Colors.transparent;

        return GestureDetector(
          onLongPress: () => _showAyahActions(context),
          onTap: () => _showAyahActions(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: bgColor,
              border: isActive
                  ? Border(left: BorderSide(color: primary, width: 3.5))
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    left: isActive ? 17 : 20,
                    right: 20,
                    top: 18,
                    bottom: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Arabic text + verse badge (RTL layout)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        textDirection: TextDirection.rtl,
                        children: [
                          _VerseNumberBadge(number: ayah.ayahNumber, color: primary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: settings.isTajweedEnabled && ayah.tajweedText != null
                                ? RichText(
                                    textDirection: TextDirection.rtl,
                                    textAlign: TextAlign.right,
                                    text: TextSpan(
                                      children: TajweedParser.parse(
                                        ayah.tajweedText!,
                                        _getArabicStyle(settings, isDark),
                                      ),
                                    ),
                                  )
                                : _buildArabicTextWithWordHighlighting(
                                    context: context,
                                    arabicText: _getArabicText(settings),
                                    ayah: ayah,
                                    settings: settings,
                                    isDark: isDark,
                                  ),
                          ),
                        ],
                      ),

                      if (!arabicOnlyMode)
                        ..._buildTranslationWidgets(settings, primary, isDark),
                    ],
                  ),
                ),
                Divider(
                  height: 1,
                  thickness: 0.4,
                  color: isDark
                      ? Colors.white.withOpacity(0.08)
                      : Colors.black.withOpacity(0.08),
                  indent: 20,
                  endIndent: 20,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildTranslationWidgets(
    SettingsProvider settings,
    Color primary,
    bool isDark,
  ) {
    final widgets = <Widget>[];

    // Preferred mode: use explicit translation selections from Translation tab.
    if (settings.selectedTranslations.isNotEmpty) {
      for (int i = 0; i < settings.selectedTranslations.length; i++) {
        final sel = settings.selectedTranslations[i];
        final lang = sel['language'] ?? '';
        final id = sel['id'] ?? '';

        widgets.add(SizedBox(height: i == 0 ? 12 : 8));

        // Local fast path for EN/BN bundled texts.
        final localText = _resolveTranslationText(lang, id);
        if (localText != null && localText.trim().isNotEmpty) {
          widgets.add(
            _TranslationRow(
              label: _languageLabel(lang),
              text: localText,
              fontSize: lang == 'bn' ? settings.banglaFontSize : settings.englishFontSize,
              fontFamily: lang == 'bn' ? AppTheme.banglaFont : AppTheme.englishFont,
              accentColor: primary,
              isDark: isDark,
              italic: lang == 'en',
            ),
          );
        } else {
          // Remote path for other selected languages/translators.
          widgets.add(
            _AsyncTranslationRow(
              label: _languageLabel(lang),
              surahNumber: ayah.surahNumber,
              ayahNumber: ayah.ayahNumber,
              translationId: id,
              translationService: _translationService,
              fontSize: settings.englishFontSize - 1,
              fontFamily: AppTheme.englishFont,
              accentColor: primary,
              isDark: isDark,
            ),
          );
        }
      }
      return widgets;
    }

    // Fallback mode for legacy toggles.
    if (settings.showBangla && ayah.banglaTranslation.isNotEmpty) {
      widgets.add(const SizedBox(height: 12));
      widgets.add(
        _TranslationRow(
          label: 'বাংলা',
          text: ayah.banglaTranslation,
          fontSize: settings.banglaFontSize,
          fontFamily: AppTheme.banglaFont,
          accentColor: primary,
          isDark: isDark,
        ),
      );
    }

    if (settings.showEnglish && ayah.englishTranslation.isNotEmpty) {
      widgets.add(const SizedBox(height: 8));
      widgets.add(
        _TranslationRow(
          label: 'EN',
          text: ayah.englishTranslation,
          fontSize: settings.englishFontSize,
          fontFamily: AppTheme.englishFont,
          accentColor: primary,
          isDark: isDark,
          italic: true,
        ),
      );
    }

    return widgets;
  }

  String? _resolveTranslationText(String language, String translationId) {
    if (language == 'en' && ayah.englishTranslation.isNotEmpty) {
      return ayah.englishTranslation;
    }
    if (language == 'bn' && ayah.banglaTranslation.isNotEmpty) {
      return ayah.banglaTranslation;
    }
    return ayah.getTranslation(translationId);
  }

  String _languageLabel(String code) {
    switch (code) {
      case 'bn':
        return 'বাংলা';
      case 'en':
        return 'EN';
      default:
        return code.toUpperCase();
    }
  }

  void _showAyahActions(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.86,
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${ayah.surahNumber} : ${ayah.ayahNumber}',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        ayah.arabicText.length > 60
                            ? '${ayah.arabicText.substring(0, 60)}...'
                            : ayah.arabicText,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontFamily: AppTheme.arabicFont,
                          fontSize: 16,
                          color: primary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.play_circle_outline_rounded,
                label: 'Play from this verse',
                color: primary,
                onTap: () {
                  Navigator.pop(context);
                  onPlay();
                },
              ),
              _ActionTile(
                icon: isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                label: isBookmarked ? 'Remove Bookmark' : 'Add Bookmark',
                color: const Color(0xFFD4AF37),
                onTap: () {
                  Navigator.pop(context);
                  onBookmarkToggle();
                },
              ),
              if (!arabicOnlyMode)
                _ActionTile(
                  icon: Icons.translate_rounded,
                  label: 'Select / Deselect Translation',
                  color: Colors.deepPurple,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TranslationsSelectorScreen(),
                      ),
                    );
                  },
                ),
              _ActionTile(
                icon: Icons.auto_awesome,
                label: 'AI Spiritual Insight',
                color: Colors.purple,
                onTap: () {
                  Navigator.pop(context);
                  _showAIInsight(context);
                },
              ),
              if (!arabicOnlyMode)
                _ActionTile(
                  icon: Icons.menu_book_rounded,
                  label: 'View Tafsir',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.pop(context);
                    showTafsirBottomSheet(
                      context,
                      surahNumber: ayah.surahNumber,
                      ayahNumber: ayah.ayahNumber,
                      arabicText: ayah.arabicText,
                    );
                  },
                ),
              _ActionTile(
                icon: Icons.text_fields_rounded,
                label: 'Quran Text Settings',
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                    builder: (context) => const QuranTextSettingsSheet(),
                  );
                },
              ),
              _ActionTile(
                icon: Icons.copy_rounded,
                label: 'Copy Arabic Text',
                color: Colors.teal,
                onTap: () {
                  Clipboard.setData(ClipboardData(text: ayah.arabicText));
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Arabic text copied'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
              _ActionTile(
                icon: Icons.share_rounded,
                label: 'Share this Verse',
                color: Colors.blue,
                onTap: () {
                  Navigator.pop(context);
                  final shareText = arabicOnlyMode
                      ? '${ayah.arabicText}\n\n— Surah ${ayah.surahNumber}, Verse ${ayah.ayahNumber}\nAl-Quran Pro'
                      : '${ayah.arabicText}\n\n${ayah.englishTranslation}\n\n— Surah ${ayah.surahNumber}, Verse ${ayah.ayahNumber}\nAl-Quran Pro';
                  Share.share(
                    shareText,
                  );
                },
              ),
              const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showAIInsight(BuildContext context) async {
    final aiProvider = context.read<AIProvider>();
    final primary = Theme.of(context).primaryColor;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        maxChildSize: 0.7,
        minChildSize: 0.3,
        expand: false,
        builder: (_, scrollController) => GlassCard(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          child: FutureBuilder<String?>(
            future: aiProvider.getAyahInsight(ayah.surahNumber, ayah.ayahNumber),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              final insight = snapshot.data ?? "Spiritual wisdom is flowing through the digital realms...";
              
              return ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.purple, size: 28),
                      const SizedBox(width: 12),
                      const Text(
                        'AI Spiritual Insight',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    insight,
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.7,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    "Note: This insight is designed for contemplation and spiritual reflection.",
                    style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.normal),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  String _getArabicText(SettingsProvider settings) {
    if (settings.scriptType == QuranScriptType.indopak && ayah.indopakText != null) {
      return ayah.indopakText!;
    }
    return ayah.uthmaniText ?? ayah.arabicText;
  }

  TextStyle _getArabicStyle(SettingsProvider settings, bool isDark) {
    return TextStyle(
      fontFamily: AppTheme.arabicFont,
      fontSize: settings.arabicFontSize,
      height: 2.1,
      color: isDark ? Colors.white.withOpacity(0.93) : const Color(0xFF1A1A2E),
      letterSpacing: 0.6,
    );
  }

  /// Build Arabic text with word-level highlighting for current playing word
  Widget _buildArabicTextWithWordHighlighting({
    required BuildContext context,
    required String arabicText,
    required Ayah ayah,
    required SettingsProvider settings,
    required bool isDark,
  }) {
    // Get audio provider to check if this ayah is playing and get current playback position
    final audioProvider = context.watch<AudioProvider>();
    
    final isPlaying = audioProvider.currentSurah == ayah.surahNumber &&
        audioProvider.currentAyah == ayah.ayahNumber;

    // If not playing, show plain text
    if (!isPlaying) {
      return Text(
        arabicText,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: _getArabicStyle(settings, isDark),
      );
    }

    // Split text into words
    final words = SimpleWordHighlighter.splitIntoWords(arabicText);
    if (words.isEmpty) {
      return Text(
        arabicText,
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        style: _getArabicStyle(settings, isDark),
      );
    }

    // Get current word index based on playback progress
    final currentWordIndex = SimpleWordHighlighter.getCurrentWordIndex(
      audioProvider.position,
      audioProvider.duration,
      words.length,
    );

    final children = <InlineSpan>[];
    final baseStyle = _getArabicStyle(settings, isDark);
    final highlightColor = Theme.of(context).primaryColor;

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final isCurrentWord = isPlaying && i == currentWordIndex;

      if (isCurrentWord) {
        // Highlight current word with bold, highlight color, and background
        children.add(
          TextSpan(
            text: word,
            style: baseStyle.copyWith(
              backgroundColor: highlightColor.withOpacity(0.3),
              color: highlightColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      } else {
        // Normal word style
        children.add(
          TextSpan(
            text: word,
            style: baseStyle,
          ),
        );
      }

      // Add space between words (except after last word)
      if (i < words.length - 1) {
        children.add(TextSpan(text: ' ', style: baseStyle));
      }
    }

    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      text: TextSpan(children: children),
    );
  }
}

// ── Ornate verse number badge (diamond/star style) ──────────────────────────
class _VerseNumberBadge extends StatelessWidget {
  final int number;
  final Color color;

  const _VerseNumberBadge({required this.number, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.rotate(
            angle: 0.785398, // 45 degrees
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 1.4),
                borderRadius: BorderRadius.circular(4),
                color: color.withOpacity(0.08),
              ),
            ),
          ),
          Text(
            '$number',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Clean translation row ────────────────────────────────────────────────────
class _TranslationRow extends StatelessWidget {
  final String label;
  final String text;
  final double fontSize;
  final String fontFamily;
  final Color accentColor;
  final bool isDark;
  final bool italic;

  const _TranslationRow({
    required this.label,
    required this.text,
    required this.fontSize,
    required this.fontFamily,
    required this.accentColor,
    required this.isDark,
    this.italic = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? Colors.white.withOpacity(0.65)
        : const Color(0xFF4A4A6A);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: accentColor,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontFamily: fontFamily,
              fontSize: fontSize,
              color: textColor,
              height: 1.65,
              fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _AsyncTranslationRow extends StatelessWidget {
  final String label;
  final int surahNumber;
  final int ayahNumber;
  final String translationId;
  final TranslationService translationService;
  final double fontSize;
  final String fontFamily;
  final Color accentColor;
  final bool isDark;

  const _AsyncTranslationRow({
    required this.label,
    required this.surahNumber,
    required this.ayahNumber,
    required this.translationId,
    required this.translationService,
    required this.fontSize,
    required this.fontFamily,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: translationService
          .getTranslationTextCached(
            surahNumber: surahNumber,
            ayahNumber: ayahNumber,
            translationId: translationId,
          )
          .timeout(const Duration(seconds: 10), onTimeout: () => null),
      builder: (context, snapshot) {
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final text = snapshot.data;

        return _TranslationRow(
          label: label,
          text: loading
              ? 'Loading translation...'
              : ((text != null && text.trim().isNotEmpty)
                  ? text
                  : 'Translation not available for this ayah yet.'),
          fontSize: fontSize,
          fontFamily: fontFamily,
          accentColor: accentColor,
          isDark: isDark,
          italic: true,
        );
      },
    );
  }
}

// ── Action tile for bottom sheet ─────────────────────────────────────────────
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      onTap: onTap,
      dense: true,
      horizontalTitleGap: 12,
    );
  }
}

