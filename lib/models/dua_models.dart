class DuaCategory {
  final String id;
  final String nameAr;
  final String nameEn;
  final String nameBn;
  final String descriptionAr;
  final String descriptionEn;
  final String descriptionBn;
  final String iconPath;
  final List<Dua> duas;

  DuaCategory({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.nameBn,
    required this.descriptionAr,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.iconPath,
    required this.duas,
  });
}

class Dua {
  final String id;
  final String type; // 'daily', 'important', 'occasion'
  final String titleAr;
  final String titleEn;
  final String titleBn;
  final String textAr;
  final String textEn;
  final String textBn;
  final String? transliteration;
  final String reference;
  final String source; // 'Quran', 'Hadith'
  final String? occasion; // when to recite
  final String? benefit;

  Dua({
    required this.id,
    required this.type,
    required this.titleAr,
    required this.titleEn,
    required this.titleBn,
    required this.textAr,
    required this.textEn,
    required this.textBn,
    this.transliteration,
    required this.reference,
    required this.source,
    this.occasion,
    this.benefit,
  });
}

enum DuaType { daily, important, occasion }
enum Language { arabic, english, bangla }