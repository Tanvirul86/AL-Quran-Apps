/// Audio reciter model (enhanced with downloadable audio)
class Reciter {
  final String id;
  final String name;
  final String nameArabic;
  final String style; // e.g., "Murattal", "Mujawwad", "Tarteel"
  final String? country;
  final String audioUrlPattern; // URL pattern with {surah} and {ayah} placeholders
  final String? bio;
  final int? bitrate; // Audio quality: 32, 64, 128, 192
  final bool isDownloadable;
  final String? imageUrl;
  final RecitationStyle recitationStyle;

  Reciter({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.style,
    this.country,
    required this.audioUrlPattern,
    this.bio,
    this.bitrate,
    this.isDownloadable = true,
    this.imageUrl,
    this.recitationStyle = RecitationStyle.hafs,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: json['id'] as String,
      name: json['name'] as String,
      nameArabic: json['nameArabic'] as String,
      style: json['style'] as String,
      country: json['country'] as String?,
      audioUrlPattern: json['audioUrlPattern'] as String,
      bio: json['bio'] as String?,
      bitrate: json['bitrate'] as int?,
      isDownloadable: json['isDownloadable'] as bool? ?? true,
      imageUrl: json['imageUrl'] as String?,
      recitationStyle: json['recitationStyle'] != null
          ? RecitationStyle.values.firstWhere(
              (e) => e.toString() == json['recitationStyle'],
              orElse: () => RecitationStyle.hafs,
            )
          : RecitationStyle.hafs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'style': style,
      'country': country,
      'audioUrlPattern': audioUrlPattern,
      'bio': bio,
      'bitrate': bitrate,
      'isDownloadable': isDownloadable,
      'imageUrl': imageUrl,
      'recitationStyle': recitationStyle.toString(),
    };
  }

  String getAudioUrl(int surahNumber, int ayahNumber) {
    return audioUrlPattern
        .replaceAll('{surah}', surahNumber.toString().padLeft(3, '0'))
        .replaceAll('{ayah}', ayahNumber.toString().padLeft(3, '0'));
  }

  String getSurahAudioUrl(int surahNumber) {
    return audioUrlPattern
        .replaceAll('{surah}', surahNumber.toString().padLeft(3, '0'))
        .replaceAll('{ayah}', '000'); // Full surah
  }

  Reciter copyWith({
    String? id,
    String? name,
    String? nameArabic,
    String? style,
    String? country,
    String? audioUrlPattern,
    String? bio,
    int? bitrate,
    bool? isDownloadable,
    String? imageUrl,
    RecitationStyle? recitationStyle,
  }) {
    return Reciter(
      id: id ?? this.id,
      name: name ?? this.name,
      nameArabic: nameArabic ?? this.nameArabic,
      style: style ?? this.style,
      country: country ?? this.country,
      audioUrlPattern: audioUrlPattern ?? this.audioUrlPattern,
      bio: bio ?? this.bio,
      bitrate: bitrate ?? this.bitrate,
      isDownloadable: isDownloadable ?? this.isDownloadable,
      imageUrl: imageUrl ?? this.imageUrl,
      recitationStyle: recitationStyle ?? this.recitationStyle,
    );
  }
}

enum RecitationStyle {
  hafs, // Most common (Hafs 'an 'Asim)
  warsh, // Warsh 'an Nafi'
  qalun, // Qalun 'an Nafi'
  other,
}
