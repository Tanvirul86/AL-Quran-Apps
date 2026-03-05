import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/ayah.dart';
import '../models/word_meaning.dart';
import '../providers/settings_provider.dart';
import '../services/quran_service.dart';
import '../theme/app_theme.dart';

/// Enhanced ayah widget with word meanings, tajweed, and sharing
class EnhancedAyahWidget extends StatefulWidget {
  final Ayah ayah;
  final bool showWordMeanings;
  final bool showTajweed;
  final VoidCallback? onBookmark;
  final VoidCallback? onNote;
  final VoidCallback? onPlay;

  const EnhancedAyahWidget({
    super.key,
    required this.ayah,
    this.showWordMeanings = false,
    this.showTajweed = false,
    this.onBookmark,
    this.onNote,
    this.onPlay,
  });

  @override
  State<EnhancedAyahWidget> createState() => _EnhancedAyahWidgetState();
}

class _EnhancedAyahWidgetState extends State<EnhancedAyahWidget> {
  bool _isTextSelected = false;
  String _selectedText = '';

  void _onTextSelection(String text) {
    setState(() {
      _selectedText = text;
      _isTextSelected = text.isNotEmpty;
    });
  }

  Future<void> _shareAyah() async {
    final settings = context.read<SettingsProvider>();
    final shareText = '''
${widget.ayah.arabicText}

${settings.showEnglish ? widget.ayah.englishTranslation : ''}
${settings.showBangla ? widget.ayah.banglaTranslation : ''}

Surah ${widget.ayah.surahNumber}, Ayah ${widget.ayah.ayahNumber}
- Qur'an App
''';
    
    await Share.share(shareText);
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _selectedText));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Text copied to clipboard')),
    );
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
                // Header with actions
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
                          icon: const Icon(Icons.share),
                          onPressed: _shareAyah,
                          tooltip: 'Share ayah',
                        ),
                        if (widget.onBookmark != null)
                          IconButton(
                            icon: const Icon(Icons.bookmark_border),
                            onPressed: widget.onBookmark,
                            tooltip: 'Bookmark',
                          ),
                        if (widget.onNote != null)
                          IconButton(
                            icon: const Icon(Icons.note_outlined),
                            onPressed: widget.onNote,
                            tooltip: 'Add note',
                          ),
                        if (widget.onPlay != null)
                          IconButton(
                            icon: const Icon(Icons.play_circle_outline),
                            onPressed: widget.onPlay,
                            tooltip: 'Play audio',
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Arabic text with selection (Quranic - Scheherazade font)
                SelectableText(
                  widget.ayah.arabicText,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: AppTheme.arabicTextStyle(
                    fontSize: settings.arabicFontSize,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  onSelectionChanged: (selection, cause) {
                    if (selection.isValid) {
                      // Handle text selection
                    }
                  },
                ),
                
                // Word meanings (if enabled)
                if (widget.showWordMeanings) ...[
                  const SizedBox(height: 16),
                  _buildWordMeanings(),
                ],
                
                const SizedBox(height: 16),
                
                // Translations
                if (settings.showEnglish)
                  _buildTranslation(
                    widget.ayah.englishTranslation,
                    settings.englishFontSize,
                    'English',
                  ),
                if (settings.showEnglish && settings.showBangla)
                  const SizedBox(height: 12),
                if (settings.showBangla)
                  _buildTranslation(
                    widget.ayah.banglaTranslation,
                    settings.banglaFontSize,
                    'বাংলা',
                  ),
                
                // Selection actions
                if (_isTextSelected) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: _copyToClipboard,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy'),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isTextSelected = false;
                            _selectedText = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('Clear'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTranslation(String text, double fontSize, String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            text,
            style: TextStyle(
              fontSize: fontSize,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordMeanings() {
    // Placeholder for word meanings
    // In production, fetch from word_meaning service
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Word-by-word meanings (coming soon)',
        style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
      ),
    );
  }
}
