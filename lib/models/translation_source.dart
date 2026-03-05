/// Translation source model for multiple translations
class TranslationSource {
  final String id;
  final String name;
  final String language; // "en", "bn", "hi", "ur", etc.
  final String translator;
  final String downloadUrl;
  final int fileSize; // in bytes
  final bool isDownloaded;
  final String? localPath;

  TranslationSource({
    required this.id,
    required this.name,
    required this.language,
    required this.translator,
    required this.downloadUrl,
    required this.fileSize,
    this.isDownloaded = false,
    this.localPath,
  });

  factory TranslationSource.fromJson(Map<String, dynamic> json) {
    return TranslationSource(
      id: json['id'] as String,
      name: json['name'] as String,
      language: json['language'] as String,
      translator: json['translator'] as String,
      downloadUrl: json['downloadUrl'] as String,
      fileSize: json['fileSize'] as int,
      isDownloaded: json['isDownloaded'] as bool? ?? false,
      localPath: json['localPath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'language': language,
      'translator': translator,
      'downloadUrl': downloadUrl,
      'fileSize': fileSize,
      'isDownloaded': isDownloaded,
      'localPath': localPath,
    };
  }

  TranslationSource copyWith({
    String? id,
    String? name,
    String? language,
    String? translator,
    String? downloadUrl,
    int? fileSize,
    bool? isDownloaded,
    String? localPath,
  }) {
    return TranslationSource(
      id: id ?? this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      translator: translator ?? this.translator,
      downloadUrl: downloadUrl ?? this.downloadUrl,
      fileSize: fileSize ?? this.fileSize,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      localPath: localPath ?? this.localPath,
    );
  }
}
