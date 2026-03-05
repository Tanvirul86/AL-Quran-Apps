import '../models/reciter.dart';

/// Service for managing audio reciters
class ReciterService {
  static final ReciterService _instance = ReciterService._internal();
  factory ReciterService() => _instance;
  ReciterService._internal();

  final List<Reciter> _reciters = [
    Reciter(
      id: 'abdul_basit',
      name: 'Abdul Basit Abdul Samad',
      nameArabic: 'عبد الباسط عبد الصمد',
      style: 'Murattal',
      country: 'Egypt',
      audioUrlPattern: 'https://cdn.islamic.network/quran/audio-surah/128/{surah}/{ayah}.mp3',
    ),
    Reciter(
      id: 'mishary_rashid',
      name: 'Mishary Rashid Alafasy',
      nameArabic: 'مشاري راشد العفاسي',
      style: 'Murattal',
      country: 'Kuwait',
      audioUrlPattern: 'https://server8.mp3quran.net/mishary/{surah}{ayah}.mp3',
    ),
    Reciter(
      id: 'saad_al_ghamdi',
      name: 'Saad Al Ghamdi',
      nameArabic: 'سعد الغامدي',
      style: 'Murattal',
      country: 'Saudi Arabia',
      audioUrlPattern: 'https://server8.mp3quran.net/saad/{surah}{ayah}.mp3',
    ),
    Reciter(
      id: 'abdullah_basfar',
      name: 'Abdullah Basfar',
      nameArabic: 'عبد الله بصفر',
      style: 'Murattal',
      country: 'Saudi Arabia',
      audioUrlPattern: 'https://server8.mp3quran.net/abd_basit/{surah}/{ayah}.mp3',
    ),
  ];

  List<Reciter> getReciters() => List.unmodifiable(_reciters);

  Reciter? getReciter(String id) {
    try {
      return _reciters.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  Reciter getDefaultReciter() => _reciters.first;
}
