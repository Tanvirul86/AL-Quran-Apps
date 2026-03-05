import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../models/surah.dart';
import '../widgets/daily_ayah_widget.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/empty_state_widget.dart';
import '../theme/app_theme.dart';
import '../utils/animations.dart';
import 'ayah_reading_screen.dart';

class SurahListScreen extends StatelessWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qur\'an'),
      ),
      body: Consumer<QuranProvider>(
        builder: (context, quranProvider, _) {
          if (quranProvider.isLoading) {
            return const LoadingSkeletons(type: 'surah', count: 10);
          }

          if (quranProvider.error != null) {
            return EmptyStates.error(
              context,
              message: quranProvider.error!,
              onRetry: () => quranProvider.loadSurahs(),
            );
          }

          final surahs = quranProvider.surahs;
          if (surahs.isEmpty) {
            return const Center(child: Text('No surahs available'));
          }

          return ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Daily Ayah (optional feature)
              const DailyAyahWidget(),
              const SizedBox(height: 8),
              // Surahs list with staggered animation
              ...surahs.asMap().entries.map((entry) {
                final index = entry.key;
                final surah = entry.value;
                return StaggeredListAnimation(
                  index: index,
                  child: _SurahListItem(
                    surah: surah,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AyahReadingScreen(surah: surah),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
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
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Surah number with Islamic pattern
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    '${surah.number}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Surah info
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
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        // Revelation type badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: surah.revelationType.toLowerCase() == 'meccan'
                                ? Colors.orange.withOpacity(0.2)
                                : Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            surah.revelationType,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: surah.revelationType.toLowerCase() == 'meccan'
                                  ? Colors.orange[800]
                                  : Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          surah.banglaName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${surah.totalAyahs} verses',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
            Expanded(
              child: Text(
                surah.englishName,
                style: const TextStyle(fontSize: 16),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(surah.banglaName),
            const SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text('${surah.totalAyahs} Ayahs'),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(surah.revelationType),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
