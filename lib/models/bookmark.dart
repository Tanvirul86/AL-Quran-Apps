/// Bookmark model for saving favorite ayahs
class Bookmark {
  final int id;
  final int surahNumber;
  final int ayahNumber;
  final DateTime createdAt;
  final String? note;

  Bookmark({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.createdAt,
    this.note,
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] as int,
      surahNumber: json['surahNumber'] as int,
      ayahNumber: json['ayahNumber'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
    };
  }

  Bookmark copyWith({
    int? id,
    int? surahNumber,
    int? ayahNumber,
    DateTime? createdAt,
    String? note,
  }) {
    return Bookmark(
      id: id ?? this.id,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
    );
  }
}
