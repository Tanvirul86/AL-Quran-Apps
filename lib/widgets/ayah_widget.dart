import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../models/ayah.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../services/translation_service.dart';
import 'tafsir_bottom_sheet.dart';

class AyahWidget extends StatefulWidget {
  final Ayah ayah;
  final bool isBookmarked;
  final VoidCallback onBookmarkToggle;
  final VoidCallback onPlay;
  final VoidCallback onVisibilityChanged;

  const AyahWidget({
    super.key,
    required this.ayah,
    required this.isBookmarked,
    required this.onBookmarkToggle,
    required this.onPlay,
    required this.onVisibilityChanged,
  });

  @override
  State<AyahWidget> createState() => _AyahWidgetState();
}

class _AyahWidgetState extends State<AyahWidget> {
  String? _selectedTranslationText;
  bool _isLoadingTranslation = false;
  String? _lastTranslationId;
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
    // Notify when ayah becomes visible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onVisibilityChanged();
    });
  }

  Future<void> _loadTranslation(String translationId) async {
    if (_lastTranslationId == translationId && _selectedTranslationText != null) {
      return; // Already loaded
    }
    
    if (!mounted) return;
    setState(() {
      _isLoadingTranslation = true;
    });
    
    try {
      final dio = Dio();
      final response = await dio.get(
        'https://api.quran.com/api/v4/quran/translations/$translationId',
        queryParameters: {
          'verse_key': '${widget.ayah.surahNumber}:${widget.ayah.ayahNumber}',
        },
      );
      
      if (response.statusCode == 200 && mounted) {
        final translations = response.data['translations'] as List?;
        if (translations != null && translations.isNotEmpty) {
          String text = translations[0]['text'] as String? ?? '';
          // Remove HTML tags
          text = text.replaceAll(RegExp(r'<[^>]*>'), '');
          setState(() {
            _selectedTranslationText = text;
            _lastTranslationId = translationId;
            _isLoadingTranslation = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTranslation = false;
          _selectedTranslationText = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Ayah number and actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${widget.ayah.ayahNumber}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            color: widget.isBookmarked
                                ? Theme.of(context).primaryColor
                                : null,
                          ),
                          onPressed: widget.onBookmarkToggle,
                          tooltip: 'Bookmark',
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.library_books,
                                color: Theme.of(context).primaryColor,
                              ),
                              onPressed: () {
                                showTafsirBottomSheet(
                                  context,
                                  surahNumber: widget.ayah.surahNumber,
                                  ayahNumber: widget.ayah.ayahNumber,
                                  arabicText: widget.ayah.arabicText,
                                );
                              },
                              tooltip: 'Tafsir',
                              padding: const EdgeInsets.only(bottom: 0),
                              constraints: const BoxConstraints(),
                            ),
                            const Text(
                              'Tafsir',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.play_circle_outline),
                          onPressed: widget.onPlay,
                          tooltip: 'Play',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Arabic text (Quranic - Uthmani script)
                Text(
                  widget.ayah.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: AppTheme.arabicTextStyle(
                    fontSize: settings.arabicFontSize,
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
                      widget.ayah.banglaTranslation,
                      textAlign: TextAlign.left,
                      style: AppTheme.banglaTextStyle(
                        fontSize: settings.banglaFontSize,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  ),
                if (settings.showBangla) const SizedBox(height: 12),
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
                      widget.ayah.englishTranslation,
                      textAlign: TextAlign.left,
                      style: AppTheme.englishTextStyle(
                        fontSize: settings.englishFontSize,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ).copyWith(fontStyle: FontStyle.italic),
                    ),
                  ),
                // Selected translation (other languages)
                if (settings.selectedTranslationLanguage != 'en' && 
                    settings.selectedTranslationLanguage != 'bn')
                  Builder(
                    builder: (context) {
                      // Load translation if not loaded
                      if (_lastTranslationId != settings.selectedTranslationId) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _loadTranslation(settings.selectedTranslationId);
                        });
                      }
                      
                      final langName = _translationService.getLanguageDisplayName(
                        settings.selectedTranslationLanguage
                      ).split(' ')[0];
                      
                      return Column(
                        children: [
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).primaryColor.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.translate,
                                      size: 16,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      langName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                if (_isLoadingTranslation)
                                  const Center(
                                    child: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  )
                                else if (_selectedTranslationText != null)
                                  Text(
                                    _selectedTranslationText!,
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontSize: settings.englishFontSize,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  )
                                else
                                  Text(
                                    'Tap to load translation',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
