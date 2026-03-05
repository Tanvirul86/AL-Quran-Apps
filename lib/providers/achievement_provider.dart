import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/achievement.dart';

/// Provider for achievements and gamification
class AchievementProvider extends ChangeNotifier {
  List<Achievement> _achievements = [];
  int _totalPoints = 0;
  int _currentStreak = 0;
  DateTime? _lastActivityDate;

  List<Achievement> get achievements => _achievements;
  List<Achievement> get unlockedAchievements => 
      _achievements.where((a) => a.isUnlocked).toList();
  List<Achievement> get lockedAchievements => 
      _achievements.where((a) => !a.isUnlocked).toList();
  int get totalPoints => _totalPoints;
  int get currentStreak => _currentStreak;
  
  AchievementProvider() {
    _loadData();
    _initializeAchievements();
  }

  /// Update reading activity (for streak tracking)
  Future<void> updateActivity() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (_lastActivityDate == null) {
      _currentStreak = 1;
    } else {
      final lastDate = DateTime(
        _lastActivityDate!.year,
        _lastActivityDate!.month,
        _lastActivityDate!.day,
      );
      
      final difference = today.difference(lastDate).inDays;
      
      if (difference == 0) {
        // Same day, no change
        return;
      } else if (difference == 1) {
        // Consecutive day, increment streak
        _currentStreak++;
      } else {
        // Streak broken
        _currentStreak = 1;
      }
    }
    
    _lastActivityDate = now;
    await _saveData();
    await _checkStreakAchievements();
    notifyListeners();
  }

  /// Unlock achievement
  Future<void> unlockAchievement(String achievementId) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1 && !_achievements[index].isUnlocked) {
      _achievements[index] = _achievements[index].copyWith(
        isUnlocked: true,
        unlockedDate: DateTime.now(),
      );
      
      _totalPoints += _achievements[index].points;
      await _saveData();
      notifyListeners();
    }
  }

  /// Update achievement progress
  Future<void> updateProgress(String achievementId, int value) async {
    final index = _achievements.indexWhere((a) => a.id == achievementId);
    if (index != -1) {
      _achievements[index] = _achievements[index].copyWith(
        currentValue: value,
      );
      
      // Auto-unlock if target reached
      if (value >= _achievements[index].targetValue && 
          !_achievements[index].isUnlocked) {
        await unlockAchievement(achievementId);
      } else {
        await _saveData();
        notifyListeners();
      }
    }
  }

  /// Check and unlock reading achievements
  Future<void> checkReadingAchievements({
    required int completedSurahs,
    required int completedJuz,
    required int totalAyahsRead,
  }) async {
    await updateProgress('read_first_surah', completedSurahs >= 1 ? 1 : 0);
    await updateProgress('read_10_surahs', completedSurahs >= 10 ? 10 : completedSurahs);
    await updateProgress('complete_juz', completedJuz >= 1 ? 1 : 0);
    await updateProgress('read_full_quran', completedSurahs >= 114 ? 114 : completedSurahs);
    await updateProgress('ayah_counter', totalAyahsRead);
  }

  Future<void> _checkStreakAchievements() async {
    await updateProgress('7_day_streak', _currentStreak >= 7 ? 7 : _currentStreak);
    await updateProgress('30_day_streak', _currentStreak >= 30 ? 30 : _currentStreak);
    await updateProgress('100_day_streak', _currentStreak >= 100 ? 100 : _currentStreak);
    await updateProgress('365_day_streak', _currentStreak >= 365 ? 365 : _currentStreak);
  }

  void _initializeAchievements() {
    _achievements = [
      // Reading Achievements
      Achievement(
        id: 'read_first_surah',
        title: 'First Steps',
        description: 'Complete reading your first Surah',
        iconName: 'book',
        type: AchievementType.reading,
        targetValue: 1,
        points: 10,
      ),
      Achievement(
        id: 'read_10_surahs',
        title: 'Dedicated Reader',
        description: 'Complete 10 Surahs',
        iconName: 'books',
        type: AchievementType.reading,
        targetValue: 10,
        points: 50,
      ),
      Achievement(
        id: 'complete_juz',
        title: 'Juz Master',
        description: 'Complete reading one Juz',
        iconName: 'star',
        type: AchievementType.completion,
        targetValue: 1,
        points: 100,
      ),
      Achievement(
        id: 'read_full_quran',
        title: 'Khatm Al-Quran',
        description: 'Complete reading the entire Quran',
        iconName: 'trophy',
        type: AchievementType.completion,
        targetValue: 114,
        points: 500,
      ),
      
      // Streak Achievements
      Achievement(
        id: '7_day_streak',
        title: 'Week Warrior',
        description: 'Read Quran for 7 consecutive days',
        iconName: 'fire',
        type: AchievementType.streak,
        targetValue: 7,
        points: 30,
      ),
      Achievement(
        id: '30_day_streak',
        title: 'Month Marathon',
        description: 'Read Quran for 30 consecutive days',
        iconName: 'fire',
        type: AchievementType.streak,
        targetValue: 30,
        points: 150,
      ),
      Achievement(
        id: '100_day_streak',
        title: 'Century Champion',
        description: 'Read Quran for 100 consecutive days',
        iconName: 'fire',
        type: AchievementType.streak,
        targetValue: 100,
        points: 500,
      ),
      Achievement(
        id: '365_day_streak',
        title: 'Annual Achiever',
        description: 'Read Quran every day for a year',
        iconName: 'crown',
        type: AchievementType.streak,
        targetValue: 365,
        points: 2000,
      ),
      
      // Memorization Achievements
      Achievement(
        id: 'memorize_first_surah',
        title: 'Memory Beginner',
        description: 'Memorize your first Surah',
        iconName: 'brain',
        type: AchievementType.memorization,
        targetValue: 1,
        points: 50,
      ),
      Achievement(
        id: 'memorize_juz_amma',
        title: 'Juz Amma Hafiz',
        description: 'Memorize Juz Amma (30th Juz)',
        iconName: 'star',
        type: AchievementType.memorization,
        targetValue: 1,
        points: 300,
      ),
      
      // Ayah Counter
      Achievement(
        id: 'ayah_counter',
        title: 'Verse Voyager',
        description: 'Read 1000 ayahs',
        iconName: 'counter',
        type: AchievementType.reading,
        targetValue: 1000,
        points: 100,
      ),
    ];
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load achievements
    final achievementsData = prefs.getString('achievements');
    if (achievementsData != null) {
      final List<dynamic> list = json.decode(achievementsData);
      _achievements = list.map((json) => Achievement.fromJson(json)).toList();
    }
    
    // Load points and streak
    _totalPoints = prefs.getInt('total_points') ?? 0;
    _currentStreak = prefs.getInt('current_streak') ?? 0;
    
    final lastActivityString = prefs.getString('last_activity_date');
    if (lastActivityString != null) {
      _lastActivityDate = DateTime.parse(lastActivityString);
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(
      'achievements',
      json.encode(_achievements.map((a) => a.toJson()).toList()),
    );
    
    await prefs.setInt('total_points', _totalPoints);
    await prefs.setInt('current_streak', _currentStreak);
    
    if (_lastActivityDate != null) {
      await prefs.setString(
        'last_activity_date',
        _lastActivityDate!.toIso8601String(),
      );
    }
  }
}
