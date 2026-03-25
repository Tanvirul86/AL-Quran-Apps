import 'package:flutter/material.dart';
import '../models/word_meaning.dart';
import '../services/word_by_word_service.dart';
import '../theme/app_theme.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Dialog to show word-by-word meaning when tapping Arabic words
class WordMeaningDialog extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final int wordPosition;

  const WordMeaningDialog({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.wordPosition,
  });

  @override
  State<WordMeaningDialog> createState() => _WordMeaningDialogState();
}

class _WordMeaningDialogState extends State<WordMeaningDialog> {
  final WordByWordService _wordService = WordByWordService();
  WordMeaning? _wordMeaning;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWordMeaning();
  }

  Future<void> _loadWordMeaning() async {
    final meaning = await _wordService.getWordMeaning(
      surahNumber: widget.surahNumber,
      ayahNumber: widget.ayahNumber,
      position: widget.wordPosition,
    );

    setState(() {
      _wordMeaning = meaning;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(20),
          child: _loading
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _wordMeaning == null
                  ? _buildNoData()
                  : _buildContent(settings),
        ),
      ),
    );
  }

  Widget _buildNoData() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.info_outline, size: 48, color: Colors.grey),
        const SizedBox(height: 16),
        const Text(
          'Word meaning not available',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildContent(SettingsProvider settings) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Arabic Word
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.islamicGradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _wordMeaning!.arabicWord,
            style: TextStyle(
              fontFamily: settings.arabicFontFamily,
              fontSize: 36,
              color: Colors.white,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
          ),
        ),

        const SizedBox(height: 16),

        // Transliteration
        _buildInfoCard(
          icon: Icons.record_voice_over,
          label: 'Transliteration',
          value: _wordMeaning!.transliteration,
          color: Colors.blue,
        ),

        const SizedBox(height: 12),

        // English Meaning
        _buildInfoCard(
          icon: Icons.translate,
          label: 'English',
          value: _wordMeaning!.englishMeaning,
          color: Colors.green,
        ),

        const SizedBox(height: 12),

        // Bangla Meaning
        _buildInfoCard(
          icon: Icons.translate,
          label: 'বাংলা',
          value: _wordMeaning!.banglaMeaning,
          color: Colors.teal,
          settings: settings,
        ),

        if (_wordMeaning!.rootWord.isNotEmpty) ...[
          const SizedBox(height: 12),
          // Root Word
          _buildInfoCard(
            icon: Icons.account_tree,
            label: 'Root Word',
            value: _wordMeaning!.rootWord,
            color: Colors.purple,
            isArabic: true,
            settings: settings,
          ),
        ],

        const SizedBox(height: 20),

        // Close Button
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required SettingsProvider settings,
    bool isArabic = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontFamily: isArabic 
                  ? settings.arabicFontFamily 
                  : (label == 'বাংলা' ? settings.banglaFontFamily : null),
              height: 1.4,
            ),
            textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          ),
        ],
      ),
    );
  }
}

/// Helper function to show word meaning dialog
void showWordMeaningDialog(
  BuildContext context, {
  required int surahNumber,
  required int ayahNumber,
  required int wordPosition,
}) {
  showDialog(
    context: context,
    builder: (context) => WordMeaningDialog(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      wordPosition: wordPosition,
    ),
  );
}
