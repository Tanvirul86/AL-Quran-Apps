/// Reading progress and streak tracking
class ReadingProgress {
  final int surahNumber;
  final int ayahNumber;
  final DateTime lastReadAt;
  final int totalAyahsRead;
  final int currentStreak; // Days in a row
  final DateTime? streakStartDate;
  final Map<int, int> surahProgress; // surahNumber -> ayahs read

  ReadingProgress({
    required this.surahNumber,
    required this.ayahNumber,
    required this.lastReadAt,
    required this.totalAyahsRead,
    required this.currentStreak,
    this.streakStartDate,
    required this.surahProgress,
  });

  factory ReadingProgress.fromJson(Map<String, dynamic> json) {
    return ReadingProgress(
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      lastReadAt: DateTime.parse(json['lastReadAt'] as String),
      totalAyahsRead: json['totalAyahsRead'] as int,
      currentStreak: json['currentStreak'] as int,
      streakStartDate: json['streakStartDate'] != null
          ? DateTime.parse(json['streakStartDate'] as String)
          : null,
      surahProgress: Map<int, int>.from(
        (json['surahProgress'] as Map).map(
          (k, v) => MapEntry(int.parse(k.toString()), v as int),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'lastReadAt': lastReadAt.toIso8601String(),
      'totalAyahsRead': totalAyahsRead,
      'currentStreak': currentStreak,
      'streakStartDate': streakStartDate?.toIso8601String(),
      'surahProgress': surahProgress.map((k, v) => MapEntry(k.toString(), v)),
    };
  }

  double getProgressPercentage(int totalAyahs) {
    if (totalAyahs == 0) return 0.0;
    return (totalAyahsRead / totalAyahs) * 100;
  }
}
