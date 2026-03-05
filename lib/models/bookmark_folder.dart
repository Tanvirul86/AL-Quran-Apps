/// Bookmark folder model for organizing bookmarks
class BookmarkFolder {
  final int? id;
  final String name;
  final String? description;
  final int colorValue; // Color as integer value
  final DateTime createdAt;
  final DateTime updatedAt;

  BookmarkFolder({
    this.id,
    required this.name,
    this.description,
    required this.colorValue,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookmarkFolder.fromJson(Map<String, dynamic> json) {
    return BookmarkFolder(
      id: json['id'] as int?,
      name: json['name'] as String,
      description: json['description'] as String?,
      colorValue: json['colorValue'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  BookmarkFolder copyWith({
    int? id,
    String? name,
    String? description,
    int? colorValue,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BookmarkFolder(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
