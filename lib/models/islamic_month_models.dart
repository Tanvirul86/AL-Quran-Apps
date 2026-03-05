class IslamicMonth {
  final int number;
  final String nameAr;
  final String nameEn;
  final String nameBn;
  final String significance;
  final String significanceBn;
  final List<ImportantEvent> events;

  IslamicMonth({
    required this.number,
    required this.nameAr,
    required this.nameEn,
    required this.nameBn,
    required this.significance,
    required this.significanceBn,
    required this.events,
  });
}

class ImportantEvent {
  final int day;
  final String titleEn;
  final String titleBn;
  final String descriptionEn;
  final String descriptionBn;

  ImportantEvent({
    required this.day,
    required this.titleEn,
    required this.titleBn,
    required this.descriptionEn,
    required this.descriptionBn,
  });
}
