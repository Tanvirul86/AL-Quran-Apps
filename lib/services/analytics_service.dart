import 'package:firebase_analytics/firebase_analytics.dart';

/// Analytics service for tracking user behavior
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  FirebaseAnalytics? _analytics;
  FirebaseAnalyticsObserver? _observer;

  void initialize(FirebaseAnalytics analytics) {
    _analytics = analytics;
    _observer = FirebaseAnalyticsObserver(analytics: analytics);
  }

  FirebaseAnalyticsObserver? get observer => _observer;

  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    await _analytics?.logEvent(
      name: name,
      parameters: parameters,
    );
  }

  Future<void> logScreenView(String screenName) async {
    await _analytics?.logScreenView(screenName: screenName);
  }

  Future<void> logSurahRead(int surahNumber) async {
    await logEvent('surah_read', {'surah_number': surahNumber});
  }

  Future<void> logAyahRead(int surahNumber, int ayahNumber) async {
    await logEvent('ayah_read', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
    });
  }

  Future<void> logBookmarkAdded(int surahNumber, int ayahNumber) async {
    await logEvent('bookmark_added', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
    });
  }

  Future<void> logAudioPlayed(int surahNumber, int ayahNumber) async {
    await logEvent('audio_played', {
      'surah_number': surahNumber,
      'ayah_number': ayahNumber,
    });
  }

  Future<void> logSearchPerformed(String query) async {
    await logEvent('search_performed', {'query': query});
  }
}
