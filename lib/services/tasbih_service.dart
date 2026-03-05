import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Tasbih (Digital Counter) Service with haptic feedback
class TasbihService {
  static final TasbihService _instance = TasbihService._internal();
  factory TasbihService() => _instance;
  TasbihService._internal();

  // Current session data
  Map<String, int> _dhikrCounts = {}; // Separate counter for each dhikr
  String _currentDhikr = 'SubhanAllah';
  List<TasbihSession> _sessions = [];
  bool _hapticEnabled = true;
  List<String> _predefinedDhikr = [
    'SubhanAllah',
    'Alhamdulillah', 
    'Allahu Akbar',
    'La ilaha illa Allah',
    'Astaghfirullah',
    'La hawla wa la quwwata illa billah',
    'Bismillah',
    'Hasbi Allah',
    'Rabb ishurni',
    'Custom Dhikr',
  ];

  // Getters
  int get currentCount => _dhikrCounts[_currentDhikr] ?? 0;
  String get currentDhikr => _currentDhikr;
  List<TasbihSession> get sessions => List.unmodifiable(_sessions);
  List<String> get predefinedDhikr => List.unmodifiable(_predefinedDhikr);
  bool get hapticEnabled => _hapticEnabled;
  Map<String, int> get dhikrCounts => Map.unmodifiable(_dhikrCounts);

  /// Initialize the service
  Future<void> initialize() async {
    await _loadSettings();
    await _loadSessions();
  }

  /// Load settings from storage
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _currentDhikr = prefs.getString('tasbih_current_dhikr') ?? 'SubhanAllah';
    _hapticEnabled = prefs.getBool('tasbih_haptic_enabled') ?? true;
    
    // Load separate counts for each dhikr
    final countsJson = prefs.getString('tasbih_dhikr_counts');
    if (countsJson != null) {
      try {
        final decoded = json.decode(countsJson) as Map<String, dynamic>;
        _dhikrCounts = decoded.map((key, value) => MapEntry(key, value as int));
      } catch (e) {
        print('Error loading dhikr counts: $e');
        _dhikrCounts = {};
      }
    }
  }

  /// Load previous sessions from storage
  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsStr = prefs.getString('tasbih_sessions');
    if (sessionsStr != null) {
      try {
        final sessionsList = json.decode(sessionsStr) as List;
        _sessions = sessionsList.map((s) => TasbihSession.fromJson(s)).toList();
        // Keep only last 100 sessions to prevent excessive storage
        if (_sessions.length > 100) {
          _sessions = _sessions.sublist(_sessions.length - 100);
          await _saveSessions();
        }
      } catch (e) {
        print('Error loading tasbih sessions: $e');
        _sessions = [];
      }
    }
  }

  /// Save current state to storage
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasbih_current_dhikr', _currentDhikr);
    await prefs.setBool('tasbih_haptic_enabled', _hapticEnabled);
    
    // Save separate counts for each dhikr
    final countsJson = json.encode(_dhikrCounts);
    await prefs.setString('tasbih_dhikr_counts', countsJson);
  }

  /// Save sessions to storage
  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = json.encode(_sessions.map((s) => s.toJson()).toList());
    await prefs.setString('tasbih_sessions', sessionsJson);
  }

  /// Increment counter with haptic feedback
  Future<void> increment() async {
    _dhikrCounts[_currentDhikr] = (_dhikrCounts[_currentDhikr] ?? 0) + 1;
    await _saveSettings();
    
    final currentCount = _dhikrCounts[_currentDhikr]!;
    
    if (_hapticEnabled) {
      // Light haptic feedback for each count
      HapticFeedback.lightImpact();
      
      // Special feedback at milestones
      if (currentCount % 33 == 0) {
        HapticFeedback.mediumImpact();
      } else if (currentCount % 100 == 0) {
        HapticFeedback.heavyImpact();
      }
    }
  }

  /// Reset counter for current dhikr
  Future<void> reset() async {
    final currentCount = _dhikrCounts[_currentDhikr] ?? 0;
    
    if (currentCount > 0) {
      // Save completed session
      final session = TasbihSession(
        dhikr: _currentDhikr,
        count: currentCount,
        completedAt: DateTime.now(),
        durationMinutes: 0, // We could track this with a timer
      );
      
      _sessions.add(session);
      await _saveSessions();
      
      if (_hapticEnabled) {
        HapticFeedback.heavyImpact();
      }
    }
    
    _dhikrCounts[_currentDhikr] = 0;
    await _saveSettings();
  }

  /// Set current dhikr
  Future<void> setDhikr(String dhikr) async {
    _currentDhikr = dhikr;
    await _saveSettings();
  }

  /// Toggle haptic feedback
  Future<void> setHapticEnabled(bool enabled) async {
    _hapticEnabled = enabled;
    await _saveSettings();
  }

  /// Get total count across all sessions and current counts
  int getTotalCount() {
    final currentTotals = _dhikrCounts.values.fold(0, (sum, count) => sum + count);
    final sessionTotals = _sessions.fold(0, (sum, session) => sum + session.count);
    return currentTotals + sessionTotals;
  }

  /// Get count for specific dhikr
  int getCountForDhikr(String dhikr) {
    final sessionsForDhikr = _sessions.where((s) => s.dhikr == dhikr);
    return sessionsForDhikr.fold(0, (sum, session) => sum + session.count);
  }

  /// Get today's total count
  int getTodayCount() {
    final today = DateTime.now();
    final todaySessions = _sessions.where((s) => 
      s.completedAt.year == today.year &&
      s.completedAt.month == today.month &&
      s.completedAt.day == today.day
    );
    
    int todayTotal = todaySessions.fold(0, (sum, session) => sum + session.count);
    
    // Add current counts for all dhikr
    final currentTotals = _dhikrCounts.values.fold(0, (sum, count) => sum + count);
    return todayTotal + currentTotals;
  }

  /// Get session statistics
  Map<String, dynamic> getStatistics() {
    final totalSessions = _sessions.length;
    final totalCount = getTotalCount();
    final todayCount = getTodayCount();
    
    // Find most used dhikr
    final dhikrCounts = <String, int>{};
    for (final session in _sessions) {
      dhikrCounts[session.dhikr] = (dhikrCounts[session.dhikr] ?? 0) + session.count;
    }
    
    String mostUsedDhikr = 'None';
    int maxCount = 0;
    for (final entry in dhikrCounts.entries) {
      if (entry.value > maxCount) {
        maxCount = entry.value;
        mostUsedDhikr = entry.key;
      }
    }
    
    return {
      'totalSessions': totalSessions,
      'totalCount': totalCount,
      'todayCount': todayCount,
      'mostUsedDhikr': mostUsedDhikr,
      'averagePerSession': totalSessions > 0 ? (totalCount / totalSessions).round() : 0,
    };
  }

  /// Delete all sessions (reset everything)
  Future<void> clearAllData() async {
    _sessions.clear();
    _dhikrCounts.clear();
    await _saveSettings();
    await _saveSessions();
    
    if (_hapticEnabled) {
      HapticFeedback.heavyImpact();
    }
  }
}

/// Model for a completed Tasbih session
class TasbihSession {
  final String dhikr;
  final int count;
  final DateTime completedAt;
  final int durationMinutes;

  TasbihSession({
    required this.dhikr,
    required this.count,
    required this.completedAt,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() {
    return {
      'dhikr': dhikr,
      'count': count,
      'completedAt': completedAt.millisecondsSinceEpoch,
      'durationMinutes': durationMinutes,
    };
  }

  static TasbihSession fromJson(Map<String, dynamic> json) {
    return TasbihSession(
      dhikr: json['dhikr'],
      count: json['count'],
      completedAt: DateTime.fromMillisecondsSinceEpoch(json['completedAt']),
      durationMinutes: json['durationMinutes'] ?? 0,
    );
  }
}