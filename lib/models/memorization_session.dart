/// Memorization session model
class MemorizationSession {
  final String id;
  final int surahNumber;
  final int startAyah;
  final int endAyah;
  final DateTime startTime;
  final DateTime? endTime;
  final int repetitionCount;
  final List<int> mistakeAyahs;
  final double confidenceScore; // 0-100
  final String? audioRecordingPath;

  MemorizationSession({
    required this.id,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.startTime,
    this.endTime,
    this.repetitionCount = 0,
    this.mistakeAyahs = const [],
    this.confidenceScore = 0.0,
    this.audioRecordingPath,
  });

  factory MemorizationSession.fromJson(Map<String, dynamic> json) {
    return MemorizationSession(
      id: json['id'] as String,
      surahNumber: json['surahNumber'] as int,
      startAyah: json['startAyah'] as int,
      endAyah: json['endAyah'] as int,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null 
          ? DateTime.parse(json['endTime'] as String) 
          : null,
      repetitionCount: json['repetitionCount'] as int? ?? 0,
      mistakeAyahs: (json['mistakeAyahs'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList() ?? [],
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
      audioRecordingPath: json['audioRecordingPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'startAyah': startAyah,
      'endAyah': endAyah,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'repetitionCount': repetitionCount,
      'mistakeAyahs': mistakeAyahs,
      'confidenceScore': confidenceScore,
      'audioRecordingPath': audioRecordingPath,
    };
  }

  MemorizationSession copyWith({
    String? id,
    int? surahNumber,
    int? startAyah,
    int? endAyah,
    DateTime? startTime,
    DateTime? endTime,
    int? repetitionCount,
    List<int>? mistakeAyahs,
    double? confidenceScore,
    String? audioRecordingPath,
  }) {
    return MemorizationSession(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      startAyah: startAyah ?? this.startAyah,
      endAyah: endAyah ?? this.endAyah,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      mistakeAyahs: mistakeAyahs ?? this.mistakeAyahs,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      audioRecordingPath: audioRecordingPath ?? this.audioRecordingPath,
    );
  }

  Duration get duration => (endTime ?? DateTime.now()).difference(startTime);
}

/// Memorization goal model
class MemorizationGoal {
  final String id;
  final String title;
  final int targetSurahNumber;
  final int startAyah;
  final int endAyah;
  final DateTime targetDate;
  final int dailyAyahTarget;
  final List<String> completedSessionIds;
  final bool isCompleted;

  MemorizationGoal({
    required this.id,
    required this.title,
    required this.targetSurahNumber,
    required this.startAyah,
    required this.endAyah,
    required this.targetDate,
    required this.dailyAyahTarget,
    this.completedSessionIds = const [],
    this.isCompleted = false,
  });

  factory MemorizationGoal.fromJson(Map<String, dynamic> json) {
    return MemorizationGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      targetSurahNumber: json['targetSurahNumber'] as int,
      startAyah: json['startAyah'] as int,
      endAyah: json['endAyah'] as int,
      targetDate: DateTime.parse(json['targetDate'] as String),
      dailyAyahTarget: json['dailyAyahTarget'] as int,
      completedSessionIds: (json['completedSessionIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ?? [],
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetSurahNumber': targetSurahNumber,
      'startAyah': startAyah,
      'endAyah': endAyah,
      'targetDate': targetDate.toIso8601String(),
      'dailyAyahTarget': dailyAyahTarget,
      'completedSessionIds': completedSessionIds,
      'isCompleted': isCompleted,
    };
  }

  int get totalAyahs => endAyah - startAyah + 1;
  double get progress => completedSessionIds.length / totalAyahs;
}
