class InspirationCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nameBn;
  final String descriptionAr;
  final String descriptionEn;
  final String descriptionBn;
  final String iconPath;
  final List<InspirationContent> contents;

  InspirationCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameBn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.iconPath,
    required this.contents,
  });
}

class InspirationContent {
  final String type; // 'verse' or 'hadith'
  final String textAr;
  final String textEn;
  final String textBn;
  final String reference;
  final String source; // For hadith: Bukhari, Muslim, etc.
  final String? transliteration;

  InspirationContent({
    required this.type,
    required this.textAr,
    required this.textEn,
    required this.textBn,
    required this.reference,
    required this.source,
    this.transliteration,
  });
}

enum Language { arabic, english, bangla }