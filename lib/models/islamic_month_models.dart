class IslamicMonth {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameBn;

  /// English meaning of the month's name
  final String meaning;
  final String meaningBn;

  final String significance;
  final String significanceBn;

  final bool isSacredMonth;

  /// Estimated days (always 29–30 for lunar calendar)
  final String daysInfo;

  // ── Quranic reference ──────────────────────────────────────────────────────
  final String? quranRef;        // e.g. "Al-Baqarah 2:185"
  final String? quranAyahAr;    // Arabic text of the ayah
  final String? quranAyahEn;    // English translation

  // ── Key Hadith ─────────────────────────────────────────────────────────────
  final String? keyHadith;       // English narration
  final String? keyHadithRef;    // e.g. "Sahih Muslim 1163"

  // ── Recommended Deeds ──────────────────────────────────────────────────────
  final List<String> recommendedDeeds;
  final List<String> recommendedDeedsBn;

  // ── Fasting info ───────────────────────────────────────────────────────────
  final String? fastingInfo;
  final String? fastingInfoBn;

  // ── Key Du'a ──────────────────────────────────────────────────────────────
  final String? keyDuaAr;
  final String? keyDuaEn;
  final String? keyDuaSource;

  final List<ImportantEvent> events;

  IslamicMonth({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameBn,
    this.meaning = '',
    this.meaningBn = '',
    required this.significance,
    required this.significanceBn,
    this.isSacredMonth = false,
    this.daysInfo = '29–30 days',
    this.quranRef,
    this.quranAyahAr,
    this.quranAyahEn,
    this.keyHadith,
    this.keyHadithRef,
    this.recommendedDeeds = const [],
    this.recommendedDeedsBn = const [],
    this.fastingInfo,
    this.fastingInfoBn,
    this.keyDuaAr,
    this.keyDuaEn,
    this.keyDuaSource,
    required this.events,
  });
}

enum EvidenceTier {
  quran,
  sahihHadith,
  hasanHadith,
  historical,
  scholarly,
}

class ImportantEvent {
  final int day;
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;

  /// Optional Quran verse directly related to this event
  final String? quranRef;

  /// Optional hadith citation for this event
  final String? hadithRef;

  /// High-importance events are rendered with a star highlight
  final bool isHighImportance;

  /// Indicates the reliability/source category of this event note.
  final EvidenceTier evidenceTier;

  ImportantEvent({
    required this.day,
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
    this.quranRef,
    this.hadithRef,
    this.isHighImportance = false,
    this.evidenceTier = EvidenceTier.historical,
  });
}
