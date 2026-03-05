import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../models/ayah.dart';
import '../models/surah.dart';
import 'ayah_widget.dart';
import 'package:intl/intl.dart';

/// Widget for displaying daily ayah with reflection
class DailyAyahWidget extends StatelessWidget {
  const DailyAyahWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, quranProvider, _) {
        // Get today's ayah (simple rotation based on day of year)
        final today = DateTime.now();
        final dayOfYear = today.difference(DateTime(today.year, 1, 1)).inDays;
        final ayahNumber = (dayOfYear % 6236) + 1; // 6236 total ayahs
        
        return FutureBuilder<Ayah?>(
          future: _getDailyAyah(quranProvider, ayahNumber),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const SizedBox.shrink();
            }

            final ayah = snapshot.data!;
            return Card(
              margin: const EdgeInsets.all(16),
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Daily Ayah - ${DateFormat('MMM d, yyyy').format(today)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      ayah.arabicText,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 20,
                        height: 2.0,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ayah.englishTranslation,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            ayah.banglaTranslation,
                            style: const TextStyle(
                              fontSize: 14,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Surah ${ayah.surahNumber}, Ayah ${ayah.ayahNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<Ayah?> _getDailyAyah(QuranProvider quranProvider, int globalAyahNumber) async {
    // This is a simplified version - in production, you'd want a more efficient lookup
    final surahs = quranProvider.surahs;
    if (surahs.isEmpty) return null;

    // Find which surah contains this ayah
    for (final surah in surahs) {
      if (globalAyahNumber >= surah.startAyahNumber &&
          globalAyahNumber < surah.startAyahNumber + surah.totalAyahs) {
        final ayahs = await quranProvider.loadAyahs(surah.number);
        final localAyahNumber = globalAyahNumber - surah.startAyahNumber + 1;
        try {
          return ayahs.firstWhere((ayah) => ayah.ayahNumber == localAyahNumber);
        } catch (e) {
          return null;
        }
      }
    }
    return null;
  }
}
