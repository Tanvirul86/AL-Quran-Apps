/// Achievement/Badge model for gamification
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconName;
  final AchievementType type;
  final int targetValue;
  final int currentValue;
  final DateTime? unlockedDate;
  final bool isUnlocked;
  final int points;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconName,
    required this.type,
    required this.targetValue,
    this.currentValue = 0,
    this.unlockedDate,
    this.isUnlocked = false,
    required this.points,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconName: json['iconName'] as String,
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.reading,
      ),
      targetValue: json['targetValue'] as int,
      currentValue: json['currentValue'] as int? ?? 0,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'] as String)
          : null,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      points: json['points'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconName': iconName,
      'type': type.toString(),
      'targetValue': targetValue,
      'currentValue': currentValue,
      'unlockedDate': unlockedDate?.toIso8601String(),
      'isUnlocked': isUnlocked,
      'points': points,
    };
  }

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconName,
    AchievementType? type,
    int? targetValue,
    int? currentValue,
    DateTime? unlockedDate,
    bool? isUnlocked,
    int? points,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      type: type ?? this.type,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unlockedDate: unlockedDate ?? this.unlockedDate,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      points: points ?? this.points,
    );
  }

  double get progress => currentValue / targetValue;
}

enum AchievementType {
  reading,
  memorization,
  streak,
  completion,
  social,
  special,
}
