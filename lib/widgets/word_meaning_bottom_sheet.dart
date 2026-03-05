import 'package:flutter/material.dart';
import '../models/word_meaning.dart';
import '../theme/app_theme.dart';

/// Bottom sheet widget for displaying word-by-word meanings
class WordMeaningBottomSheet extends StatelessWidget {
  final String arabicWord;
  final int position;
  final List<WordMeaning> wordMeanings;

  const WordMeaningBottomSheet({
    super.key,
    required this.arabicWord,
    required this.position,
    required this.wordMeanings,
  });

  @override
  Widget build(BuildContext context) {
    // Find the specific word meaning
    final wordMeaning = wordMeanings.isNotEmpty
        ? wordMeanings.firstWhere(
            (w) => w.position == position,
            orElse: () => WordMeaning(
              arabicWord: arabicWord,
              transliteration: 'N/A',
              englishMeaning: 'Word meaning not available',
              banglaMeaning: 'শব্দের অর্থ উপলব্ধ নেই',
              rootWord: '',
              position: position,
            ),
          )
        : WordMeaning(
            arabicWord: arabicWord,
            transliteration: 'Sample transliteration',
            englishMeaning: 'Sample English meaning',
            banglaMeaning: 'নমুনা বাংলা অর্থ',
            rootWord: 'Root',
            position: position,
          );

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Arabic word - large and centered
          Container(
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
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                wordMeaning.arabicWord,
                style: AppTheme.arabicTextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Transliteration
          if (wordMeaning.transliteration.isNotEmpty) ...[
            _buildInfoCard(
              context,
              icon: Icons.record_voice_over,
              title: 'Pronunciation',
              content: wordMeaning.transliteration,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
          ],
          
          // English meaning
          _buildInfoCard(
            context,
            icon: Icons.translate,
            title: 'English',
            content: wordMeaning.englishMeaning,
            color: Colors.green,
          ),
          
          const SizedBox(height: 12),
          
          // Bangla meaning
          _buildInfoCard(
            context,
            icon: Icons.translate,
            title: 'বাংলা',
            content: wordMeaning.banglaMeaning,
            color: Colors.orange,
            isBangla: true,
          ),
          
          // Root word
          if (wordMeaning.rootWord.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              context,
              icon: Icons.category,
              title: 'Root Word',
              content: wordMeaning.rootWord,
              color: Colors.purple,
              isArabic: true,
            ),
          ],
          
          const SizedBox(height: 20),
          
          // Close button
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String content,
    required Color color,
    bool isArabic = false,
    bool isBangla = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  content,
                  style: isArabic
                      ? AppTheme.arabicTextStyle(
                          fontSize: 18,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        )
                      : isBangla
                          ? AppTheme.banglaTextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            )
                          : AppTheme.englishTextStyle(
                              fontSize: 16,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Show word meaning bottom sheet
void showWordMeaningBottomSheet(
  BuildContext context, {
  required String arabicWord,
  required int position,
  List<WordMeaning> wordMeanings = const [],
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => WordMeaningBottomSheet(
      arabicWord: arabicWord,
      position: position,
      wordMeanings: wordMeanings,
    ),
  );
}
