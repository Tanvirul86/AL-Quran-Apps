class Biography {
  final String name;
  final String arabicName;
  final String title;
  final String birthYear;
  final String deathYear;
  final String birthPlace;
  final String summary;
  final String earlyLife;
  final List<String> contributions;
  final String legacy;
  final List<String> sources;

  Biography({
    required this.name,
    required this.arabicName,
    required this.title,
    required this.birthYear,
    required this.deathYear,
    required this.birthPlace,
    required this.summary,
    required this.earlyLife,
    required this.contributions,
    required this.legacy,
    required this.sources,
  });
}

class BiographyCategory {
  final String name;
  final String icon;
  final List<Biography> people;

  BiographyCategory({
    required this.name,
    required this.icon,
    required this.people,
  });
}
