/// Notification model for scheduled notifications
class QuranNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime scheduledTime;
  final bool isRepeating;
  final String? repeatIntervalType; // 'daily', 'weekly', 'monthly'
  final Map<String, dynamic>? payload;
  final bool isEnabled;

  QuranNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.scheduledTime,
    this.isRepeating = false,
    this.repeatIntervalType,
    this.payload,
    this.isEnabled = true,
  });

  factory QuranNotification.fromJson(Map<String, dynamic> json) {
    return QuranNotification(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => NotificationType.general,
      ),
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isRepeating: json['isRepeating'] as bool? ?? false,
      repeatIntervalType: json['repeatIntervalType'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.toString(),
      'scheduledTime': scheduledTime.toIso8601String(),
      'isRepeating': isRepeating,
      'repeatIntervalType': repeatIntervalType,
      'payload': payload,
      'isEnabled': isEnabled,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuranNotification &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  /// Returns a unique integer ID derived from the string ID for local notifications.
  int get uniqueIntId {
    // Generate a consistent 32-bit integer from the string ID
    return id.split('').fold<int>(0, (prev, char) => (prev * 31 + char.codeUnitAt(0)) & 0x7FFFFFFF);
  }

  QuranNotification copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    DateTime? scheduledTime,
    bool? isRepeating,
    String? repeatIntervalType,
    Map<String, dynamic>? payload,
    bool? isEnabled,
  }) {
    return QuranNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isRepeating: isRepeating ?? this.isRepeating,
      repeatIntervalType: repeatIntervalType ?? this.repeatIntervalType,
      payload: payload ?? this.payload,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}

enum NotificationType {
  ayahOfTheDay,
  readingReminder,
  prayerReminder,
  memorizationReminder,
  streakReminder,
  general,
}
