/// Surah model representing a chapter of the Qur'an
class Surah {
  final int number;
  final String arabicName;
  final String englishName;
  final String banglaName;
  final String revelationType; // Meccan or Medinan
  final int totalAyahs;
  final int startAyahNumber; // Global ayah number where this surah starts

  Surah({
    required this.number,
    required this.arabicName,
    required this.englishName,
    required this.banglaName,
    required this.revelationType,
    required this.totalAyahs,
    required this.startAyahNumber,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      number: json['number'] as int,
      arabicName: json['arabicName'] as String,
      englishName: json['englishName'] as String,
      banglaName: json['banglaName'] as String,
      revelationType: json['revelationType'] as String,
      totalAyahs: json['totalAyahs'] as int,
      startAyahNumber: json['startAyahNumber'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'arabicName': arabicName,
      'englishName': englishName,
      'banglaName': banglaName,
      'revelationType': revelationType,
      'totalAyahs': totalAyahs,
      'startAyahNumber': startAyahNumber,
    };
  }
}
