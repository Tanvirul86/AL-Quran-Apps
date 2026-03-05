/// Tafsir source model for downloadable tafsirs
class TafsirSource {
  final String id;
  final String name;
  final String language; // "en", "bn", "hi", "ur", "ar"
  final String author;
  final String description;
  final String downloadUrl;
  final int fileSize; // in bytes
  final bool isDownloaded;
  final String? localPath;
  final bool isPremium;

  TafsirSource({
    required this.id,
    required this.name,
    required this.language,
    required this.author,
    required this.description,
    required this.downloadUrl,
    required this.fileSize,
    this.isDownloaded = false,
    this.localPath,
    this.isPremium = false,
  });

  factory TafsirSource.fromJson(Map<String, dynamic> json) {
    return TafsirSource(
      id: json['id'] as String,
      name: json['name'] as String,
      language: json['language'] as String,
      author: json['author'] as String,
      description: json['description'] as String? ?? '',
      downloadUrl: json['downloadUrl'] as String,
      fileSize: json['fileSize'] as int,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'author': author,
      'description': description,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
      'isPremium': isPremium,
    };
  }

  TafsirSource copyWith({
    String? id,
    String? name,
    String? language,
    String? author,
    String? description,
    String? downloadUrl,
    int? fileSize,
    bool? isDownloaded,
    String? localPath,
    bool? isPremium,
  }) {
    return TafsirSource(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      author: author ?? this.author,
      description: description ?? this.description,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileSize: fileSize ?? this.fileSize,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  String get displayName => '$name ($author)';
  
  String get fileSizeFormatted {
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }
}
