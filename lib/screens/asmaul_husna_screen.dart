import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/settings_provider.dart';

class AsmaulHusnaScreen extends StatefulWidget {
  const AsmaulHusnaScreen({super.key});

  @override
  State<AsmaulHusnaScreen> createState() => _AsmaulHusnaScreenState();
}

class _AsmaulHusnaScreenState extends State<AsmaulHusnaScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, String>> _names = [
    {
      'number': '1',
      'arabic': 'ٱللَّه',
      'transliteration': 'Allah',
      'meaning': 'The One God',
      'benefit': 'The greatest name of God — the source of all existence and worship.',
    },
    {
      'number': '2',
      'arabic': 'ٱلرَّحْمَٰن',
      'transliteration': 'Ar-Rahman',
      'meaning': 'The Most Gracious',
      'benefit': 'His mercy encompasses all creation without exception.',
    },
    {
      'number': '3',
      'arabic': 'ٱلرَّحِيم',
      'transliteration': 'Ar-Raheem',
      'meaning': 'The Most Merciful',
      'benefit': 'His special mercy is bestowed upon believers in the Hereafter.',
    },
    {
      'number': '4',
      'arabic': 'ٱلْمَلِك',
      'transliteration': 'Al-Malik',
      'meaning': 'The King',
      'benefit': 'He is the absolute sovereign King of all creation.',
    },
    {
      'number': '5',
      'arabic': 'ٱلْقُدُّوس',
      'transliteration': 'Al-Quddus',
      'meaning': 'The Most Holy',
      'benefit': 'He is free from all imperfection, defect, and shortcoming.',
    },
    {
      'number': '6',
      'arabic': 'ٱلسَّلَام',
      'transliteration': 'As-Salam',
      'meaning': 'The Source of Peace',
      'benefit': 'He is the source of all peace and security.',
    },
    {
      'number': '7',
      'arabic': 'ٱلْمُؤْمِن',
      'transliteration': 'Al-Mu\'min',
      'meaning': 'The Guardian of Faith',
      'benefit': 'He grants safety and security to His believers.',
    },
    {
      'number': '8',
      'arabic': 'ٱلْمُهَيْمِن',
      'transliteration': 'Al-Muhaymin',
      'meaning': 'The Overseer',
      'benefit': 'He watches over and protects all of His creation.',
    },
    {
      'number': '9',
      'arabic': 'ٱلْعَزِيز',
      'transliteration': 'Al-Aziz',
      'meaning': 'The Almighty',
      'benefit': 'He is the invincible and unbeatable in power and might.',
    },
    {
      'number': '10',
      'arabic': 'ٱلْجَبَّار',
      'transliteration': 'Al-Jabbar',
      'meaning': 'The Compeller',
      'benefit': 'He repairs and restores what is broken; His will is irresistible.',
    },
    {
      'number': '11',
      'arabic': 'ٱلْمُتَكَبِّر',
      'transliteration': 'Al-Mutakabbir',
      'meaning': 'The Supreme',
      'benefit': 'He alone is deserving of all greatness and pride.',
    },
    {
      'number': '12',
      'arabic': 'ٱلْخَالِق',
      'transliteration': 'Al-Khaliq',
      'meaning': 'The Creator',
      'benefit': 'He brings everything into existence from nothingness.',
    },
    {
      'number': '13',
      'arabic': 'ٱلْبَارِئ',
      'transliteration': 'Al-Bari\'',
      'meaning': 'The Originator',
      'benefit': 'He creates without any prior model or example.',
    },
    {
      'number': '14',
      'arabic': 'ٱلْمُصَوِّر',
      'transliteration': 'Al-Musawwir',
      'meaning': 'The Fashioner',
      'benefit': 'He shapes everything into its perfect and unique form.',
    },
    {
      'number': '15',
      'arabic': 'ٱلْغَفَّار',
      'transliteration': 'Al-Ghaffar',
      'meaning': 'The Ever-Forgiving',
      'benefit': 'He repeatedly forgives sins of His servants who repent.',
    },
    {
      'number': '16',
      'arabic': 'ٱلْقَهَّار',
      'transliteration': 'Al-Qahhar',
      'meaning': 'The Subduer',
      'benefit': 'He dominates and subdues everything in existence.',
    },
    {
      'number': '17',
      'arabic': 'ٱلْوَهَّاب',
      'transliteration': 'Al-Wahhab',
      'meaning': 'The Bestower',
      'benefit': 'He gives freely and bountifully without any expectation.',
    },
    {
      'number': '18',
      'arabic': 'ٱلرَّزَّاق',
      'transliteration': 'Ar-Razzaq',
      'meaning': 'The Provider',
      'benefit': 'He provides sustenance for all of creation without limit.',
    },
    {
      'number': '19',
      'arabic': 'ٱلْفَتَّاح',
      'transliteration': 'Al-Fattah',
      'meaning': 'The Opener',
      'benefit': 'He opens hearts, doors of mercy, and resolves all difficulties.',
    },
    {
      'number': '20',
      'arabic': 'ٱلْعَلِيم',
      'transliteration': 'Al-\'Alim',
      'meaning': 'The All-Knowing',
      'benefit': 'His knowledge encompasses everything — past, present, and future.',
    },
    {
      'number': '21',
      'arabic': 'ٱلْقَابِض',
      'transliteration': 'Al-Qabid',
      'meaning': 'The Withholder',
      'benefit': 'He withholds sustenance and mercy as a test and wisdom.',
    },
    {
      'number': '22',
      'arabic': 'ٱلْبَاسِط',
      'transliteration': 'Al-Basit',
      'meaning': 'The Extender',
      'benefit': 'He extends provision and mercy to whom He wills.',
    },
    {
      'number': '23',
      'arabic': 'ٱلْخَافِض',
      'transliteration': 'Al-Khafid',
      'meaning': 'The Abaser',
      'benefit': 'He lowers the arrogant and the oppressive.',
    },
    {
      'number': '24',
      'arabic': 'ٱلرَّافِع',
      'transliteration': 'Ar-Rafi\'',
      'meaning': 'The Exalter',
      'benefit': 'He elevates the righteous in status and honor.',
    },
    {
      'number': '25',
      'arabic': 'ٱلْمُعِزّ',
      'transliteration': 'Al-Mu\'izz',
      'meaning': 'The Honorer',
      'benefit': 'He bestows honor and dignity to whom He wills.',
    },
    {
      'number': '26',
      'arabic': 'ٱلْمُذِلّ',
      'transliteration': 'Al-Mudhill',
      'meaning': 'The Dishonorer',
      'benefit': 'He humiliates those who disobey and are arrogant.',
    },
    {
      'number': '27',
      'arabic': 'ٱلسَّمِيع',
      'transliteration': 'As-Sami\'',
      'meaning': 'The All-Hearing',
      'benefit': 'He hears every word, whisper, and prayer of His servants.',
    },
    {
      'number': '28',
      'arabic': 'ٱلْبَصِير',
      'transliteration': 'Al-Basir',
      'meaning': 'The All-Seeing',
      'benefit': 'He sees everything — apparent and hidden — in all creation.',
    },
    {
      'number': '29',
      'arabic': 'ٱلْحَكَم',
      'transliteration': 'Al-Hakam',
      'meaning': 'The Judge',
      'benefit': 'He is the ultimate arbiter and descider of all matters.',
    },
    {
      'number': '30',
      'arabic': 'ٱلْعَدْل',
      'transliteration': 'Al-\'Adl',
      'meaning': 'The Just',
      'benefit': 'He is perfectly just and fair in all His decrees.',
    },
    {
      'number': '31',
      'arabic': 'ٱللَّطِيف',
      'transliteration': 'Al-Latif',
      'meaning': 'The Subtle',
      'benefit': 'He is aware of the finest details and is gentle with His servants.',
    },
    {
      'number': '32',
      'arabic': 'ٱلْخَبِير',
      'transliteration': 'Al-Khabir',
      'meaning': 'The Acquainted',
      'benefit': 'He is fully aware of every secret and subtle matter.',
    },
    {
      'number': '33',
      'arabic': 'ٱلْحَلِيم',
      'transliteration': 'Al-Halim',
      'meaning': 'The Forbearing',
      'benefit': 'He delays punishment out of patience and wisdom.',
    },
    {
      'number': '34',
      'arabic': 'ٱلْعَظِيم',
      'transliteration': 'Al-\'Azim',
      'meaning': 'The Magnificent',
      'benefit': 'He possesses the highest degree of greatness and majesty.',
    },
    {
      'number': '35',
      'arabic': 'ٱلْغَفُور',
      'transliteration': 'Al-Ghafur',
      'meaning': 'The Forgiving',
      'benefit': 'He forgives all sins, no matter how great, for those who repent.',
    },
    {
      'number': '36',
      'arabic': 'ٱلشَّكُور',
      'transliteration': 'Ash-Shakur',
      'meaning': 'The Appreciative',
      'benefit': 'He rewards even the smallest of good deeds abundantly.',
    },
    {
      'number': '37',
      'arabic': 'ٱلْعَلِيّ',
      'transliteration': 'Al-\'Ali',
      'meaning': 'The Most High',
      'benefit': 'He is the highest in position, status, and power.',
    },
    {
      'number': '38',
      'arabic': 'ٱلْكَبِير',
      'transliteration': 'Al-Kabir',
      'meaning': 'The Greatest',
      'benefit': 'He is greater than everything that can be conceived.',
    },
    {
      'number': '39',
      'arabic': 'ٱلْحَفِيظ',
      'transliteration': 'Al-Hafiz',
      'meaning': 'The Preserver',
      'benefit': 'He protects and preserves all things from harm and loss.',
    },
    {
      'number': '40',
      'arabic': 'ٱلْمُقِيت',
      'transliteration': 'Al-Muqit',
      'meaning': 'The Sustainer',
      'benefit': 'He provides nourishment and maintains all of creation.',
    },
    {
      'number': '41',
      'arabic': 'ٱلْحَسِيب',
      'transliteration': 'Al-Hasib',
      'meaning': 'The Reckoner',
      'benefit': 'He takes account of all deeds and is sufficient as a witness.',
    },
    {
      'number': '42',
      'arabic': 'ٱلْجَلِيل',
      'transliteration': 'Al-Jalil',
      'meaning': 'The Majestic',
      'benefit': 'He is majestic and sublime in His attributes.',
    },
    {
      'number': '43',
      'arabic': 'ٱلْكَرِيم',
      'transliteration': 'Al-Karim',
      'meaning': 'The Generous',
      'benefit': 'He is generous beyond measure and never lets good deeds go unrewarded.',
    },
    {
      'number': '44',
      'arabic': 'ٱلرَّقِيب',
      'transliteration': 'Ar-Raqib',
      'meaning': 'The Watchful',
      'benefit': 'He is ever-watchful over all actions and intentions.',
    },
    {
      'number': '45',
      'arabic': 'ٱلْمُجِيب',
      'transliteration': 'Al-Mujib',
      'meaning': 'The Responsive',
      'benefit': 'He answers and responds to the prayers of those who call upon Him.',
    },
    {
      'number': '46',
      'arabic': 'ٱلْوَاسِع',
      'transliteration': 'Al-Wasi\'',
      'meaning': 'The All-Encompassing',
      'benefit': 'His mercy, knowledge, and power are unlimited and all-encompassing.',
    },
    {
      'number': '47',
      'arabic': 'ٱلْحَكِيم',
      'transliteration': 'Al-Hakim',
      'meaning': 'The Wise',
      'benefit': 'All His actions and decrees are based on perfect wisdom.',
    },
    {
      'number': '48',
      'arabic': 'ٱلْوَدُود',
      'transliteration': 'Al-Wadud',
      'meaning': 'The Loving',
      'benefit': 'He is the source of pure love and affection for His righteous servants.',
    },
    {
      'number': '49',
      'arabic': 'ٱلْمَجِيد',
      'transliteration': 'Al-Majid',
      'meaning': 'The Glorious',
      'benefit': 'He is glorious in His essence and His actions.',
    },
    {
      'number': '50',
      'arabic': 'ٱلْبَاعِث',
      'transliteration': 'Al-Ba\'ith',
      'meaning': 'The Resurrector',
      'benefit': 'He will resurrect all beings on the Day of Judgment.',
    },
    {
      'number': '51',
      'arabic': 'ٱلشَّهِيد',
      'transliteration': 'Ash-Shahid',
      'meaning': 'The Witness',
      'benefit': 'He is the witness to all things at all times.',
    },
    {
      'number': '52',
      'arabic': 'ٱلْحَقّ',
      'transliteration': 'Al-Haqq',
      'meaning': 'The Truth',
      'benefit': 'He is the absolute and ultimate truth and reality.',
    },
    {
      'number': '53',
      'arabic': 'ٱلْوَكِيل',
      'transliteration': 'Al-Wakil',
      'meaning': 'The Trustee',
      'benefit': 'He is the best guardian and disposer of all affairs.',
    },
    {
      'number': '54',
      'arabic': 'ٱلْقَوِيّ',
      'transliteration': 'Al-Qawiyy',
      'meaning': 'The Powerful',
      'benefit': 'He has ultimate and inexhaustible strength and power.',
    },
    {
      'number': '55',
      'arabic': 'ٱلْمَتِين',
      'transliteration': 'Al-Matin',
      'meaning': 'The Firm',
      'benefit': 'He is firm and steadfast; His strength is never weakened.',
    },
    {
      'number': '56',
      'arabic': 'ٱلْوَلِيّ',
      'transliteration': 'Al-Waliyy',
      'meaning': 'The Protecting Friend',
      'benefit': 'He is the protector and helper of the believers.',
    },
    {
      'number': '57',
      'arabic': 'ٱلْحَمِيد',
      'transliteration': 'Al-Hamid',
      'meaning': 'The Praiseworthy',
      'benefit': 'He is deserving of all praise in every circumstance.',
    },
    {
      'number': '58',
      'arabic': 'ٱلْمُحْصِي',
      'transliteration': 'Al-Muhsi',
      'meaning': 'The Counter',
      'benefit': 'He has counted and recorded everything in precise detail.',
    },
    {
      'number': '59',
      'arabic': 'ٱلْمُبْدِئ',
      'transliteration': 'Al-Mubdi\'',
      'meaning': 'The Originator',
      'benefit': 'He is the one who begins creation from nothing.',
    },
    {
      'number': '60',
      'arabic': 'ٱلْمُعِيد',
      'transliteration': 'Al-Mu\'id',
      'meaning': 'The Restorer',
      'benefit': 'He brings creation back after death and annihilation.',
    },
    {
      'number': '61',
      'arabic': 'ٱلْمُحْيِي',
      'transliteration': 'Al-Muhyi',
      'meaning': 'The Giver of Life',
      'benefit': 'He grants life to all living beings at His will.',
    },
    {
      'number': '62',
      'arabic': 'ٱلْمُمِيت',
      'transliteration': 'Al-Mumit',
      'meaning': 'The Taker of Life',
      'benefit': 'He takes away life when He wills, as decreed.',
    },
    {
      'number': '63',
      'arabic': 'ٱلْحَيّ',
      'transliteration': 'Al-Hayy',
      'meaning': 'The Ever-Living',
      'benefit': 'He is eternally alive and never subject to death.',
    },
    {
      'number': '64',
      'arabic': 'ٱلْقَيُّوم',
      'transliteration': 'Al-Qayyum',
      'meaning': 'The Self-Subsisting',
      'benefit': 'He is self-sustaining and sustains all of creation.',
    },
    {
      'number': '65',
      'arabic': 'ٱلْوَاجِد',
      'transliteration': 'Al-Wajid',
      'meaning': 'The Finder',
      'benefit': 'He finds and obtains whatever He wills effortlessly.',
    },
    {
      'number': '66',
      'arabic': 'ٱلْمَاجِد',
      'transliteration': 'Al-Majid',
      'meaning': 'The Illustrious',
      'benefit': 'He is illustrious and honored in His glory.',
    },
    {
      'number': '67',
      'arabic': 'ٱلْوَاحِد',
      'transliteration': 'Al-Wahid',
      'meaning': 'The One',
      'benefit': 'He is uniquely one — without partner, parent, or child.',
    },
    {
      'number': '68',
      'arabic': 'ٱلْأَحَد',
      'transliteration': 'Al-Ahad',
      'meaning': 'The Unique',
      'benefit': 'He is the absolutely unique — there is nothing like Him.',
    },
    {
      'number': '69',
      'arabic': 'ٱلصَّمَد',
      'transliteration': 'As-Samad',
      'meaning': 'The Eternal',
      'benefit': 'He is the self-sufficient master on whom all creation depends.',
    },
    {
      'number': '70',
      'arabic': 'ٱلْقَادِر',
      'transliteration': 'Al-Qadir',
      'meaning': 'The Capable',
      'benefit': 'He has power over all things without any limitation.',
    },
    {
      'number': '71',
      'arabic': 'ٱلْمُقْتَدِر',
      'transliteration': 'Al-Muqtadir',
      'meaning': 'The Dominant',
      'benefit': 'He is the all-powerful who prevails over everything.',
    },
    {
      'number': '72',
      'arabic': 'ٱلْمُقَدِّم',
      'transliteration': 'Al-Muqaddim',
      'meaning': 'The Expediter',
      'benefit': 'He puts things in proper order and brings forward what He wills.',
    },
    {
      'number': '73',
      'arabic': 'ٱلْمُؤَخِّر',
      'transliteration': 'Al-Mu\'akhkhir',
      'meaning': 'The Delayer',
      'benefit': 'He delays and postpones things according to His wisdom.',
    },
    {
      'number': '74',
      'arabic': 'ٱلْأَوَّل',
      'transliteration': 'Al-Awwal',
      'meaning': 'The First',
      'benefit': 'He existed before all things and has no beginning.',
    },
    {
      'number': '75',
      'arabic': 'ٱلْآخِر',
      'transliteration': 'Al-Akhir',
      'meaning': 'The Last',
      'benefit': 'He will remain after all things cease to exist.',
    },
    {
      'number': '76',
      'arabic': 'ٱلظَّاهِر',
      'transliteration': 'Az-Zahir',
      'meaning': 'The Evident',
      'benefit': 'He is manifest through His signs in all of creation.',
    },
    {
      'number': '77',
      'arabic': 'ٱلْبَاطِن',
      'transliteration': 'Al-Batin',
      'meaning': 'The Hidden',
      'benefit': 'He is hidden from our sight yet closer to us than anything.',
    },
    {
      'number': '78',
      'arabic': 'ٱلْوَالِي',
      'transliteration': 'Al-Wali',
      'meaning': 'The Governor',
      'benefit': 'He manages and governs all affairs of the universe.',
    },
    {
      'number': '79',
      'arabic': 'ٱلْمُتَعَالِي',
      'transliteration': 'Al-Muta\'ali',
      'meaning': 'The Most Exalted',
      'benefit': 'He is far above any imperfection that anyone could ascribe to Him.',
    },
    {
      'number': '80',
      'arabic': 'ٱلْبَرّ',
      'transliteration': 'Al-Barr',
      'meaning': 'The Doer of Good',
      'benefit': 'He is the source of all goodness and kindness.',
    },
    {
      'number': '81',
      'arabic': 'ٱلتَّوَّاب',
      'transliteration': 'At-Tawwab',
      'meaning': 'The Acceptor of Repentance',
      'benefit': 'He continuously accepts repentance from those who sincerely return to Him.',
    },
    {
      'number': '82',
      'arabic': 'ٱلْمُنْتَقِم',
      'transliteration': 'Al-Muntaqim',
      'meaning': 'The Avenger',
      'benefit': 'He takes just retribution from those who persist in oppression.',
    },
    {
      'number': '83',
      'arabic': 'ٱلْعَفُوّ',
      'transliteration': 'Al-\'Afuww',
      'meaning': 'The Pardoner',
      'benefit': 'He completely erases sins as if they never existed.',
    },
    {
      'number': '84',
      'arabic': 'ٱلرَّءُوف',
      'transliteration': 'Ar-Ra\'uf',
      'meaning': 'The Compassionate',
      'benefit': 'He shows intense compassion and tenderness to His servants.',
    },
    {
      'number': '85',
      'arabic': 'مَالِكُ ٱلْمُلْك',
      'transliteration': 'Malik-ul-Mulk',
      'meaning': 'Owner of Sovereignty',
      'benefit': 'He owns and governs all kingdoms in both worlds.',
    },
    {
      'number': '86',
      'arabic': 'ذُو ٱلْجَلَالِ وَٱلْإِكْرَام',
      'transliteration': 'Dhul-Jalali Wal-Ikram',
      'meaning': 'Lord of Majesty and Bounty',
      'benefit': 'He is the possessor of all majesty, glory, and honor.',
    },
    {
      'number': '87',
      'arabic': 'ٱلْمُقْسِط',
      'transliteration': 'Al-Muqsit',
      'meaning': 'The Equitable',
      'benefit': 'He is the one who acts with perfect equity and fairness.',
    },
    {
      'number': '88',
      'arabic': 'ٱلْجَامِع',
      'transliteration': 'Al-Jami\'',
      'meaning': 'The Gatherer',
      'benefit': 'He will gather all of humanity on the Day of Judgment.',
    },
    {
      'number': '89',
      'arabic': 'ٱلْغَنِيّ',
      'transliteration': 'Al-Ghani',
      'meaning': 'The Self-Sufficient',
      'benefit': 'He is completely independent and free of all needs.',
    },
    {
      'number': '90',
      'arabic': 'ٱلْمُغْنِي',
      'transliteration': 'Al-Mughni',
      'meaning': 'The Enricher',
      'benefit': 'He enriches whom He wills from His infinite bounty.',
    },
    {
      'number': '91',
      'arabic': 'ٱلْمَانِع',
      'transliteration': 'Al-Mani\'',
      'meaning': 'The Withholder',
      'benefit': 'He withholds what would harm His servants, out of wisdom.',
    },
    {
      'number': '92',
      'arabic': 'ٱلضَّارّ',
      'transliteration': 'Ad-Darr',
      'meaning': 'The Distresser',
      'benefit': 'He alone can cause harm as a test and decree, in His wisdom.',
    },
    {
      'number': '93',
      'arabic': 'ٱلنَّافِع',
      'transliteration': 'An-Nafi\'',
      'meaning': 'The Benefiter',
      'benefit': 'He alone grants true benefit to His creation.',
    },
    {
      'number': '94',
      'arabic': 'ٱلنُّور',
      'transliteration': 'An-Nur',
      'meaning': 'The Light',
      'benefit': 'He is the light of the heavens and the earth.',
    },
    {
      'number': '95',
      'arabic': 'ٱلْهَادِي',
      'transliteration': 'Al-Hadi',
      'meaning': 'The Guide',
      'benefit': 'He guides whom He wills to the right path.',
    },
    {
      'number': '96',
      'arabic': 'ٱلْبَدِيع',
      'transliteration': 'Al-Badi\'',
      'meaning': 'The Incomparable',
      'benefit': 'He creates things in the most wonderful and unique way.',
    },
    {
      'number': '97',
      'arabic': 'ٱلْبَاقِي',
      'transliteration': 'Al-Baqi',
      'meaning': 'The Everlasting',
      'benefit': 'He endures forever while all else perishes.',
    },
    {
      'number': '98',
      'arabic': 'ٱلْوَارِث',
      'transliteration': 'Al-Warith',
      'meaning': 'The Inheritor',
      'benefit': 'He inherits all that exists after everything else has perished.',
    },
    {
      'number': '99',
      'arabic': 'ٱلرَّشِيد',
      'transliteration': 'Ar-Rashid',
      'meaning': 'The Guide to the Right Path',
      'benefit': 'He directs all affairs with perfect wisdom and right direction.',
    },
  ];

  List<Map<String, String>> get _filteredNames {
    if (_searchQuery.isEmpty) return _names;
    final q = _searchQuery.toLowerCase();
    return _names.where((n) {
      return n['transliteration']!.toLowerCase().contains(q) ||
          n['meaning']!.toLowerCase().contains(q) ||
          n['arabic']!.contains(_searchQuery) ||
          n['number']!.contains(_searchQuery);
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showNameDetail(Map<String, String> name) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scrollController) {
          final primaryColor = Theme.of(context).primaryColor;
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primaryColor, primaryColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      name['number']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  name['arabic']!,
                  style: TextStyle(
                    fontFamily: Provider.of<SettingsProvider>(context, listen: false).arabicFontFamily,
                    fontSize: 48,
                    color: primaryColor,
                    height: 1.4,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  name['transliteration']!,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  name['meaning']!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.auto_awesome, color: primaryColor, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Significance',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        name['benefit']!,
                        style: const TextStyle(fontSize: 15, height: 1.6),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final filtered = _filteredNames;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Asma ul Husna'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Search by name or meaning...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                filled: true,
                fillColor: Colors.white.withOpacity(0.15),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Header count strip
          Container(
            color: primaryColor.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Icon(Icons.format_list_numbered, size: 16, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  '${filtered.length} of 99 Names',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                const Spacer(),
                Text(
                  'Tap a name for details',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: 12),
                        Text(
                          'No names match "$_searchQuery"',
                          style: TextStyle(color: Colors.grey[500], fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final name = filtered[index];
                      return _buildNameCard(name, primaryColor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameCard(Map<String, String> name, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _showNameDetail(name),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              // Number badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryColor, primaryColor.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name['number']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name['transliteration']!,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      name['meaning']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Arabic name
              Text(
                name['arabic']!,
                style: TextStyle(
                  fontFamily: Provider.of<SettingsProvider>(context, listen: false).arabicFontFamily,
                  fontSize: 22,
                  color: primaryColor,
                  height: 1.5,
                ),
                textDirection: TextDirection.rtl,
              ),
              const SizedBox(width: 6),
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
