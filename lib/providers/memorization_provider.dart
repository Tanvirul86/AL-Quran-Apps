import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/memorization_session.dart';
import 'package:uuid/uuid.dart';

/// Provider for memorization features
class MemorizationProvider extends ChangeNotifier {
  List<MemorizationSession> _sessions = [];
  List<MemorizationGoal> _goals = [];
  MemorizationSession? _currentSession;
  
  final Uuid _uuid = const Uuid();

  List<MemorizationSession> get sessions => _sessions;
  List<MemorizationGoal> get goals => _goals;
  MemorizationSession? get currentSession => _currentSession;
  bool get hasActiveSession => _currentSession != null;

  MemorizationProvider() {
    _loadData();
  }

  /// Start new memorization session
  Future<void> startSession({
    required int surahNumber,
    required int startAyah,
    required int endAyah,
  }) async {
    _currentSession = MemorizationSession(
      id: _uuid.v4(),
      surahNumber: surahNumber,
      startAyah: startAyah,
      endAyah: endAyah,
      startTime: DateTime.now(),
    );
    
    notifyListeners();
  }

  /// End current session
  Future<void> endSession({
    int repetitionCount = 0,
    List<int> mistakeAyahs = const [],
    double confidenceScore = 0.0,
    String? audioRecordingPath,
  }) async {
    if (_currentSession != null) {
      final completedSession = _currentSession!.copyWith(
        endTime: DateTime.now(),
        repetitionCount: repetitionCount,
        mistakeAyahs: mistakeAyahs,
        confidenceScore: confidenceScore,
        audioRecordingPath: audioRecordingPath,
      );
      
      _sessions.add(completedSession);
      _currentSession = null;
      
      await _saveData();
      notifyListeners();
    }
  }

  /// Update current session
  Future<void> updateSession({
    int? repetitionCount,
    List<int>? mistakeAyahs,
    double? confidenceScore,
  }) async {
    if (_currentSession != null) {
      _currentSession = _currentSession!.copyWith(
        repetitionCount: repetitionCount,
        mistakeAyahs: mistakeAyahs,
        confidenceScore: confidenceScore,
      );
      notifyListeners();
    }
  }

  /// Create memorization goal
  Future<void> createGoal({
    required String title,
    required int targetSurahNumber,
    required int startAyah,
    required int endAyah,
    required DateTime targetDate,
    required int dailyAyahTarget,
  }) async {
    final goal = MemorizationGoal(
      id: _uuid.v4(),
      title: title,
      targetSurahNumber: targetSurahNumber,
      startAyah: startAyah,
      endAyah: endAyah,
      targetDate: targetDate,
      dailyAyahTarget: dailyAyahTarget,
    );
    
    _goals.add(goal);
    await _saveData();
    notifyListeners();
  }

  /// Update goal progress
  Future<void> updateGoalProgress(String goalId, String sessionId) async {
    final goalIndex = _goals.indexWhere((g) => g.id == goalId);
    if (goalIndex != -1) {
      final goal = _goals[goalIndex];
      final updatedSessions = List<String>.from(goal.completedSessionIds)
        ..add(sessionId);
      
      _goals[goalIndex] = MemorizationGoal(
        id: goal.id,
        title: goal.title,
        targetSurahNumber: goal.targetSurahNumber,
        startAyah: goal.startAyah,
        endAyah: goal.endAyah,
        targetDate: goal.targetDate,
        dailyAyahTarget: goal.dailyAyahTarget,
        completedSessionIds: updatedSessions,
        isCompleted: updatedSessions.length >= goal.totalAyahs,
      );
      
      await _saveData();
      notifyListeners();
    }
  }

  /// Get sessions for specific Surah
  List<MemorizationSession> getSessionsForSurah(int surahNumber) {
    return _sessions.where((s) => s.surahNumber == surahNumber).toList();
  }

  /// Get total memorization time
  Duration getTotalMemorizationTime() {
    return _sessions.fold(
      Duration.zero,
      (total, session) => total + session.duration,
    );
  }

  /// Get weak ayahs (ayahs with most mistakes)
  Map<String, int> getWeakAyahs() {
    final weakAyahs = <String, int>{};
    
    for (final session in _sessions) {
      for (final ayahNumber in session.mistakeAyahs) {
        final key = '${session.surahNumber}:$ayahNumber';
        weakAyahs[key] = (weakAyahs[key] ?? 0) + 1;
      }
    }
    
    return Map.fromEntries(
      weakAyahs.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );
  }

  /// Get memorization statistics
  Map<String, dynamic> getStatistics() {
    final totalSessions = _sessions.length;
    final totalTime = getTotalMemorizationTime();
    final averageConfidence = _sessions.isEmpty
        ? 0.0
        : _sessions.map((s) => s.confidenceScore).reduce((a, b) => a + b) /
            totalSessions;
    
    final totalMistakes = _sessions.fold<int>(
      0,
      (sum, session) => sum + session.mistakeAyahs.length,
    );
    
    return {
      'totalSessions': totalSessions,
      'totalTime': totalTime.inMinutes,
      'averageConfidence': averageConfidence,
      'totalMistakes': totalMistakes,
      'activeGoals': _goals.where((g) => !g.isCompleted).length,
      'completedGoals': _goals.where((g) => g.isCompleted).length,
    };
  }

  /// Delete goal
  Future<void> deleteGoal(String goalId) async {
    _goals.removeWhere((g) => g.id == goalId);
    await _saveData();
    notifyListeners();
  }

  /// Delete session
  Future<void> deleteSession(String sessionId) async {
    _sessions.removeWhere((s) => s.id == sessionId);
    await _saveData();
    notifyListeners();
  }

  // Private methods

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load sessions
    final sessionsData = prefs.getString('memorization_sessions');
    if (sessionsData != null) {
      final List<dynamic> sessionsList = json.decode(sessionsData);
      _sessions = sessionsList
          .map((json) => MemorizationSession.fromJson(json))
          .toList();
    }
    
    // Load goals
    final goalsData = prefs.getString('memorization_goals');
    if (goalsData != null) {
      final List<dynamic> goalsList = json.decode(goalsData);
      _goals = goalsList
          .map((json) => MemorizationGoal.fromJson(json))
          .toList();
    }
    
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Save sessions
    await prefs.setString(
      'memorization_sessions',
      json.encode(_sessions.map((s) => s.toJson()).toList()),
    );
    
    // Save goals
    await prefs.setString(
      'memorization_goals',
      json.encode(_goals.map((g) => g.toJson()).toList()),
    );
  }
}
