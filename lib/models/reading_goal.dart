import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for reading goals and progress tracking
class ReadingGoal {
  final int dailyAyahsGoal;
  final int todayProgress;
  final DateTime lastReadDate;
  final int currentStreak;
  final int longestStreak;
  final Map<String, int> weeklyProgress; // Date -> ayah count
  
  ReadingGoal({
    this.dailyAyahsGoal = 10,
    this.todayProgress = 0,
    DateTime? lastReadDate,
    this.currentStreak = 0,
    this.longestStreak = 0,
    Map<String, int>? weeklyProgress,
  }) : lastReadDate = lastReadDate ?? DateTime.now(),
       weeklyProgress = weeklyProgress ?? {};

  Map<String, dynamic> toJson() => {
    'dailyAyahsGoal': dailyAyahsGoal,
    'todayProgress': todayProgress,
    'lastReadDate': lastReadDate.toIso8601String(),
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'weeklyProgress': weeklyProgress,
  };

  factory ReadingGoal.fromJson(Map<String, dynamic> json) => ReadingGoal(
    dailyAyahsGoal: json['dailyAyahsGoal'] ?? 10,
    todayProgress: json['todayProgress'] ?? 0,
    lastReadDate: DateTime.parse(json['lastReadDate'] ?? DateTime.now().toIso8601String()),
    currentStreak: json['currentStreak'] ?? 0,
    longestStreak: json['longestStreak'] ?? 0,
    weeklyProgress: Map<String, int>.from(json['weeklyProgress'] ?? {}),
  );

  ReadingGoal copyWith({
    int? dailyAyahsGoal,
    int? todayProgress,
    DateTime? lastReadDate,
    int? currentStreak,
    int? longestStreak,
    Map<String, int>? weeklyProgress,
  }) => ReadingGoal(
    dailyAyahsGoal: dailyAyahsGoal ?? this.dailyAyahsGoal,
    todayProgress: todayProgress ?? this.todayProgress,
    lastReadDate: lastReadDate ?? this.lastReadDate,
    currentStreak: currentStreak ?? this.currentStreak,
    longestStreak: longestStreak ?? this.longestStreak,
    weeklyProgress: weeklyProgress ?? this.weeklyProgress,
  );

  bool get isGoalMet => todayProgress >= dailyAyahsGoal;
  double get progressPercentage => 
      (todayProgress / dailyAyahsGoal * 100).clamp(0, 100);
}

/// Provider for managing reading goals and statistics
class ReadingGoalProvider with ChangeNotifier {
  static const String _key = 'reading_goal';
  ReadingGoal _goal = ReadingGoal();

  ReadingGoal get goal => _goal;

  Future<void> loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonStr = prefs.getString(_key);
    if (jsonStr != null) {
      try {
        _goal = ReadingGoal.fromJson(
          Map<String, dynamic>.from(
            // Parse JSON string
            {'temp': 'placeholder'} // TODO: Implement proper JSON parsing
          ),
        );
        _checkAndResetDaily();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading reading goal: $e');
      }
    }
  }

  /// Check if it's a new day and reset daily progress
  void _checkAndResetDaily() {
    final now = DateTime.now();
    final lastRead = _goal.lastReadDate;
    
    if (!_isSameDay(now, lastRead)) {
      // New day - check streak
      int newStreak = _goal.currentStreak;
      
      if (_isConsecutiveDay(now, lastRead) && _goal.isGoalMet) {
        // Continue streak if goal was met yesterday
        newStreak++;
      } else if (!_isSameDay(now, lastRead)) {
        // Streak broken
        newStreak = 0;
      }
      
      _goal = _goal.copyWith(
        todayProgress: 0,
        lastReadDate: now,
        currentStreak: newStreak,
        longestStreak: newStreak > _goal.longestStreak ? newStreak : _goal.longestStreak,
      );
      
      _saveGoal();
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isConsecutiveDay(DateTime now, DateTime last) {
    final yesterday = now.subtract(const Duration(days: 1));
    return _isSameDay(yesterday, last);
  }

  /// Record that ayahs were read
  Future<void> recordAyahsRead(int count) async {
    _checkAndResetDaily();
    
    final today = _formatDate(DateTime.now());
    final weeklyProgress = Map<String, int>.from(_goal.weeklyProgress);
    weeklyProgress[today] = (_goal.weeklyProgress[today] ?? 0) + count;
    
    _goal = _goal.copyWith(
      todayProgress: _goal.todayProgress + count,
      weeklyProgress: weeklyProgress,
      lastReadDate: DateTime.now(),
    );
    
    // Update streak if goal is newly met
    if (_goal.isGoalMet && _goal.currentStreak == 0) {
      _goal = _goal.copyWith(
        currentStreak: 1,
        longestStreak: _goal.longestStreak > 0 ? _goal.longestStreak : 1,
      );
    }
    
    await _saveGoal();
    notifyListeners();
  }

  /// Set daily goal
  Future<void> setDailyGoal(int ayahs) async {
    _goal = _goal.copyWith(dailyAyahsGoal: ayahs);
    await _saveGoal();
    notifyListeners();
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _saveGoal() async {
    final prefs = await SharedPreferences.getInstance();
    // Save goal data - implement JSON serialization
    await prefs.setInt('daily_goal', _goal.dailyAyahsGoal);
    await prefs.setInt('today_progress', _goal.todayProgress);
    await prefs.setString('last_read_date', _goal.lastReadDate.toIso8601String());
    await prefs.setInt('current_streak', _goal.currentStreak);
    await prefs.setInt('longest_streak', _goal.longestStreak);
  }
}
