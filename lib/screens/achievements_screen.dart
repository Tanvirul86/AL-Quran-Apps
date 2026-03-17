import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/achievement_provider.dart';
import '../models/achievement.dart';

/// Achievements Screen - Gamification with badges and rewards
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, _) {
          final unlockedAchievements = provider.achievements
              .where((a) => a.isUnlocked)
              .toList();
          final lockedAchievements = provider.achievements
              .where((a) => !a.isUnlocked)
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Stats Summary Card
              _buildStatsCard(provider),

              const SizedBox(height: 24),

              // Unlocked Achievements
              if (unlockedAchievements.isNotEmpty) ...[
                const Text(
                  'Unlocked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...unlockedAchievements.map((achievement) =>
                    _buildAchievementCard(achievement, true)),
              ],

              const SizedBox(height: 24),

              // Locked Achievements
              if (lockedAchievements.isNotEmpty) ...[
                const Text(
                  'Locked',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ...lockedAchievements.map((achievement) =>
                    _buildAchievementCard(achievement, false)),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatsCard(AchievementProvider provider) {
    final unlockedCount = provider.achievements
        .where((a) => a.isUnlocked)
        .length;
    final totalCount = provider.achievements.length;
    final percentage = (unlockedCount / totalCount * 100).toInt();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.purple.shade400, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Trophy Icon
            const Icon(
              Icons.emoji_events,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),

            // Total Points
            Text(
              '${provider.totalPoints}',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const Text(
              'Total Points',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 24),

            // Progress Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  '$unlockedCount/$totalCount',
                  'Unlocked',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                ),
                _buildStatColumn(
                  '$percentage%',
                  'Complete',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                ),
                _buildStatColumn(
                  '${provider.currentStreak}',
                  'Day Streak',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: unlockedCount / totalCount,
                minHeight: 8,
                backgroundColor: Colors.white30,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isUnlocked ? 4 : 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [
                    _getTypeColor(achievement.type).withOpacity(0.1),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getTypeColor(achievement.type)
                      : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getTypeIcon(achievement.type),
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isUnlocked ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      achievement.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: isUnlocked
                            ? Colors.grey.shade700
                            : Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Progress Bar (for locked achievements)
                    if (!isUnlocked && achievement.progress < 1.0) ...[
                      LinearProgressIndicator(
                        value: achievement.progress,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation(
                          _getTypeColor(achievement.type),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(achievement.progress * 100).toInt()}% Complete',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],

                    // Unlock Date (for unlocked achievements)
                    if (isUnlocked && achievement.unlockedDate != null)
                      Text(
                        'Unlocked ${_formatDate(achievement.unlockedDate!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),

              // Points Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _getTypeColor(achievement.type)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${achievement.points}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(AchievementType type) {
    switch (type) {
      case AchievementType.reading:
        return Colors.blue;
      case AchievementType.memorization:
        return Colors.green;
      case AchievementType.streak:
        return Colors.orange;
      case AchievementType.completion:
        return Colors.purple;
      case AchievementType.social:
        return Colors.pink;
      case AchievementType.special:
        return Colors.amber;
    }
  }

  IconData _getTypeIcon(AchievementType type) {
    switch (type) {
      case AchievementType.reading:
        return Icons.menu_book;
      case AchievementType.memorization:
        return Icons.psychology;
      case AchievementType.streak:
        return Icons.local_fire_department;
      case AchievementType.completion:
        return Icons.check_circle;
      case AchievementType.social:
        return Icons.share;
      case AchievementType.special:
        return Icons.star;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }
}
