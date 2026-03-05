import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/settings_provider.dart';
import '../models/hadith.dart';
import '../theme/app_theme.dart';

class FortyHadithScreen extends StatefulWidget {
  const FortyHadithScreen({super.key});

  @override
  State<FortyHadithScreen> createState() => _FortyHadithScreenState();
}

class _FortyHadithScreenState extends State<FortyHadithScreen> {
  final List<Hadith> _hadiths = _get40Hadiths();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('40 Hadith by Imam Nawawi'),
        centerTitle: true,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _hadiths.length,
            itemBuilder: (context, index) {
              final hadith = _hadiths[index];
              return _buildHadithCard(context, hadith, settings);
            },
          );
        },
      ),
    );
  }

  Widget _buildHadithCard(BuildContext context, Hadith hadith, SettingsProvider settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: AppTheme.primaryGreen.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with number and share button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.islamicGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'حديث ${_arabicNumber(hadith.number)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppTheme.arabicFont,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () => _shareHadith(hadith),
                  color: AppTheme.primaryGreen,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Title in Arabic
            Text(
              hadith.titleArabic,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: AppTheme.arabicFont,
                height: 1.8,
              ),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            
            // Title in English
            if (settings.showEnglish) ...[
              Text(
                hadith.titleEnglish,
                style: TextStyle(
                  fontSize: settings.englishFontSize,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            // Title in Bangla
            if (settings.showBangla) ...[
              Text(
                hadith.titleBangla,
                style: TextStyle(
                  fontSize: settings.banglaFontSize,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTheme.banglaFont,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 8),
            ],
            
            const Divider(height: 24),
            
            // Arabic Hadith Text
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.forestSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  width: 1,
                ),
              ),
              child: Text(
                hadith.textArabic,
                style: TextStyle(
                  fontSize: settings.arabicFontSize,
                  fontFamily: AppTheme.arabicFont,
                  height: 2.0,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            const SizedBox(height: 12),
            
            // English Translation
            if (settings.showEnglish) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hadith.textEnglish,
                  style: TextStyle(
                    fontSize: settings.englishFontSize,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Bangla Translation
            if (settings.showBangla) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  hadith.textBangla,
                  style: TextStyle(
                    fontSize: settings.banglaFontSize,
                    fontFamily: AppTheme.banglaFont,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            // Narrator
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.accentGold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 18,
                    color: AppTheme.accentGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Narrator: ${hadith.narrator}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Reference
            if (hadith.reference.isNotEmpty) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Reference: ${hadith.reference}',
                  style: TextStyle(
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _shareHadith(Hadith hadith) {
    final text = '''
${hadith.titleEnglish}

${hadith.textArabic}

${hadith.textEnglish}

Narrator: ${hadith.narrator}

From: 40 Hadith by Imam Nawawi - Al-Quran Pro
''';
    Share.share(text);
  }

  String _arabicNumber(int number) {
    const arabicNumerals = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((digit) {
      return arabicNumerals[int.parse(digit)];
    }).join();
  }
}

// Sample data for the 40 Hadiths - First 5 hadiths included as examples
List<Hadith> _get40Hadiths() {
  return [
    Hadith(
      number: 1,
      titleArabic: 'النية',
      titleEnglish: 'Actions are by Intentions',
      titleBangla: 'নিয়্যত',
      textArabic: 'إنَّما الأعمالُ بالنِّيَّاتِ، وإنَّما لكلِّ امرِئٍ ما نوى، فمَن كانت هجرتُه إلى اللهِ ورسولِه، فهجرتُه إلى اللهِ ورسولِه، ومَن كانت هجرتُه لدُنيا يُصِيبُها أو امرأةٍ يَنكِحُها، فهجرتُه إلى ما هاجَر إليه',
      textEnglish: 'Actions are judged by intentions, so each man will have what he intended. Thus, he whose migration was to Allah and His Messenger, his migration is to Allah and His Messenger; but he whose migration was for some worldly thing he might gain, or for a wife he might marry, his migration is to that for which he migrated.',
      textBangla: 'সকল কাজ নিয়তের উপর নির্ভরশীল এবং প্রত্যেক ব্যক্তি তাই পাবে যা সে নিয়ত করেছে। যে ব্যক্তির হিজরত আল্লাহ ও তাঁর রাসূলের জন্য হয়েছে, তার হিজরত আল্লাহ ও তাঁর রাসূলের জন্যই গণ্য হবে। আর যার হিজরত দুনিয়া অর্জন অথবা কোনো নারীকে বিবাহ করার জন্য হয়েছে, তার হিজরত সে উদ্দেশ্যেই গণ্য হবে যার জন্য সে হিজরত করেছে।',
      narrator: 'Umar ibn al-Khattab (RA)',
      reference: 'Sahih al-Bukhari 1, Sahih Muslim 1907',
    ),
    Hadith(
      number: 2,
      titleArabic: 'الإسلام والإيمان والإحسان',
      titleEnglish: 'Islam, Iman, and Ihsan',
      titleBangla: 'ইসলাম, ঈমান ও ইহসান',
      textArabic: 'الإسلامُ أنْ تَشْهَدَ أنْ لا إلَهَ إلَّا اللَّهُ وأنَّ مُحَمَّدًا رَسولُ اللهِ، وتُقِيمَ الصَّلاةَ، وتُؤْتِيَ الزَّكاةَ، وتَصُومَ رَمَضانَ، وتَحُجَّ البَيْتَ إنِ اسْتَطَعْتَ إلَيْهِ سَبِيلًا. والإيمانُ أنْ تُؤْمِنَ باللَّهِ ومَلائِكَتِهِ وكُتُبِهِ ورُسُلِهِ واليَومِ الآخِرِ، وتُؤْمِنَ بالقَدَرِ خَيْرِهِ وشَرِّهِ. والإحسانُ أنْ تَعْبُدَ اللَّهَ كَأنَّكَ تَراهُ، فإنْ لَمْ تَكُنْ تَراهُ فإنَّه يَراكَ',
      textEnglish: 'Islam is to testify that there is no deity worthy of worship except Allah and that Muhammad is the Messenger of Allah, to establish the prayer, to pay zakat, to fast in Ramadan, and to make pilgrimage to the House if you are able. Iman is to believe in Allah, His angels, His Books, His Messengers, the Last Day, and to believe in divine decree, both the good and the evil thereof. Ihsan is to worship Allah as though you see Him, and if you cannot achieve this state of devotion then you must consider that He is seeing you.',
      textBangla: 'ইসলাম হল: তুমি সাক্ষ্য দাও যে আল্লাহ ব্যতীত কোনো উপাস্য নেই এবং মুহাম্মাদ (সা.) আল্লাহর রাসূল, সালাত কায়েম কর, যাকাত প্রদান কর, রমাদানে রোযা রাখ এবং যদি সক্ষম হও তবে বাইতুল্লাহর হজ্জ পালন কর। ঈমান হল: তুমি আল্লাহ, তাঁর ফেরেশতাগণ, তাঁর কিতাবসমূহ, তাঁর রাসূলগণ এবং আখিরাতের প্রতি বিশ্বাস রাখ এবং তাকদীরের ভালো-মন্দের প্রতি বিশ্বাস রাখ। ইহসান হল: তুমি আল্লাহর ইবাদত এমনভাবে কর যেন তুমি তাঁকে দেখছ, আর যদি তুমি তাঁকে না দেখতে পাও তবে নিশ্চয় তিনি তোমাকে দেখছেন।',
      narrator: 'Umar ibn al-Khattab (RA)',
      reference: 'Sahih Muslim 8',
    ),
    Hadith(
      number: 3,
      titleArabic: 'أركان الإسلام',
      titleEnglish: 'The Pillars of Islam',
      titleBangla: 'ইসলামের স্তম্ভসমূহ',
      textArabic: 'بُنِيَ الإسْلامُ علَى خَمْسٍ: شَهادَةِ أنْ لا إلَهَ إلَّا اللَّهُ وأنَّ مُحَمَّدًا رَسولُ اللَّهِ، وإقامِ الصَّلاةِ، وإيتاءِ الزَّكاةِ، والحَجِّ، وصَوْمِ رَمَضانَ',
      textEnglish: 'Islam is built upon five: testifying that there is no deity worthy of worship except Allah and that Muhammad is the Messenger of Allah, establishing the prayer, paying the zakat, making the pilgrimage to the House, and fasting in Ramadan.',
      textBangla: 'ইসলাম পাঁচটি ভিত্তির উপর প্রতিষ্ঠিত: সাক্ষ্য দেওয়া যে আল্লাহ ছাড়া কোনো উপাস্য নেই এবং মুহাম্মাদ (সা.) আল্লাহর রাসূল, সালাত কায়েম করা, যাকাত প্রদান করা, বাইতুল্লাহর হজ্জ করা এবং রমাদানে রোযা রাখা।',
      narrator: 'Abdullah ibn Umar (RA)',
      reference: 'Sahih al-Bukhari 8, Sahih Muslim 16',
    ),
    Hadith(
      number: 4,
      titleArabic: 'مراحل الخلق',
      titleEnglish: 'Stages of Creation',
      titleBangla: 'সৃষ্টির স্তরসমূহ',
      textArabic: 'إنَّ أحَدَكُمْ يُجْمَعُ خَلْقُهُ في بَطْنِ أُمِّهِ أرْبَعِينَ يَوْمًا نُطْفَةً، ثُمَّ يَكونُ عَلَقَةً مِثْلَ ذلكَ، ثُمَّ يَكونُ مُضْغَةً مِثْلَ ذلكَ، ثُمَّ يُرْسَلُ إلَيْهِ المَلَكُ فَيَنْفُخُ فيه الرُّوحَ، ويُؤْمَرُ بأَرْبَعِ كَلِماتٍ: بكَتْبِ رِزْقِهِ، وأَجَلِهِ، وعَمَلِهِ، وشَقِيٌّ أوْ سَعِيدٌ',
      textEnglish: 'Verily the creation of each one of you is brought together in his mother\'s womb for forty days in the form of a nutfah (a drop), then he becomes an alaqah (clot of blood) for a like period, then a mudghah (morsel of flesh) for a like period, then there is sent to him the angel who blows his soul into him and who is commanded with four matters: to write down his rizq (sustenance), his life span, his actions, and whether he will be happy or unhappy.',
      textBangla: 'নিশ্চয়ই তোমাদের প্রত্যেকের সৃষ্টি তার মায়ের গর্ভে চল্লিশ দিন নুতফা (শুক্রবিন্দু) হিসেবে একত্রিত করা হয়, তারপর সমান সময়ের জন্য আলাকা (রক্তপিণ্ড) হয়, তারপর সমান সময়ের জন্য মুদগা (মাংসপিণ্ড) হয়, তারপর তার কাছে ফেরেশতা পাঠানো হয় যে তার মধ্যে রূহ ফুঁকে দেয় এবং চারটি বিষয় লিখে দেওয়ার আদেশ পায়: তার রিযিক, তার আয়ু, তার আমল এবং সে সৌভাগ্যবান না দুর্ভাগা হবে।',
      narrator: 'Abdullah ibn Masud (RA)',
      reference: 'Sahih al-Bukhari 3208, Sahih Muslim 2643',
    ),
    Hadith(
      number: 5,
      titleArabic: 'ترك البدع',
      titleEnglish: 'Rejecting Innovation',
      titleBangla: 'বিদআত পরিত্যাগ',
      textArabic: 'مَن أحْدَثَ في أمْرِنا هذا ما ليسَ منه فَهو رَدٌّ',
      textEnglish: 'Whoever innovates something in this matter of ours (i.e., Islam) that is not part of it will have it rejected.',
      textBangla: 'যে ব্যক্তি আমাদের এই দ্বীনে এমন কিছু নতুন সৃষ্টি করল যা এর অংশ নয়, তা প্রত্যাখ্যাত।',
      narrator: 'Aisha (RA)',
      reference: 'Sahih al-Bukhari 2697, Sahih Muslim 1718',
    ),
    // Additional hadiths can be added here following the same pattern
    // For brevity, I'm including just 5 as examples. The remaining 35 would follow the same structure
    Hadith(
      number: 6,
      titleArabic: 'الحلال والحرام',
      titleEnglish: 'Halal and Haram',
      titleBangla: 'হালাল ও হারাম',
      textArabic: 'إنَّ الحَلالَ بَيِّنٌ، وإنَّ الحَرامَ بَيِّنٌ، وبيْنَهُما أُمُورٌ مُشْتَبِهاتٌ لا يَعْلَمُهُنَّ كَثِيرٌ مِنَ النَّاسِ، فَمَنِ اتَّقَى الشُّبُهاتِ فَقَدِ اسْتَبْرَأَ لِدِينِهِ وعِرْضِهِ',
      textEnglish: 'That which is lawful is clear and that which is unlawful is clear, and between the two of them are doubtful matters about which many people do not know. Thus he who avoids doubtful matters clears himself in regard to his religion and his honor.',
      textBangla: 'হালাল স্পষ্ট এবং হারাম স্পষ্ট, আর এই দুইয়ের মাঝে সন্দেহজনক বিষয় রয়েছে যা অনেক মানুষ জানে না। যে সন্দেহজনক বিষয় থেকে বিরত থাকল, সে তার দ্বীন ও সম্মান রক্ষা করল।',
      narrator: 'An-Numan ibn Bashir (RA)',
      reference: 'Sahih al-Bukhari 52, Sahih Muslim 1599',
    ),
    Hadith(
      number: 7,
      titleArabic: 'الدين النصيحة',
      titleEnglish: 'Religion is Sincere Advice',
      titleBangla: 'দ্বীন হচ্ছে কল্যাণকামিতা',
      textArabic: 'الدِّينُ النَّصِيحَةُ قُلْنا: لِمَنْ؟ قالَ: لِلَّهِ ولِكِتابِهِ ولِرَسولِهِ ولأَئِمَّةِ المُسْلِمِينَ وعامَّتِهِمْ',
      textEnglish: 'Religion is sincerity. We said: To whom? He said: To Allah, His Book, His Messenger, and to the leaders of the Muslims and their common folk.',
      textBangla: 'দ্বীন হচ্ছে কল্যাণকামিতা। আমরা বললাম: কার জন্য? তিনি বললেন: আল্লাহর জন্য, তাঁর কিতাবের জন্য, তাঁর রাসূলের জন্য এবং মুসলিম নেতা ও সাধারণ মুসলিমদের জন্য।',
      narrator: 'Tamim al-Dari (RA)',
      reference: 'Sahih Muslim 55',
    ),
    Hadith(
      number: 8,
      titleArabic: 'حرمة دم المسلم',
      titleEnglish: 'Sanctity of Muslim Blood',
      titleBangla: 'মুসলিমের রক্তের পবিত্রতা',
      textArabic: 'أُمِرْتُ أنْ أُقاتِلَ النَّاسَ حتَّى يَشْهَدُوا أنْ لا إلَهَ إلَّا اللَّهُ وأنَّ مُحَمَّدًا رَسولُ اللَّهِ، ويُقِيمُوا الصَّلاةَ، ويُؤْتُوا الزَّكاةَ، فإذا فَعَلُوا ذلكَ عَصَمُوا مِنِّي دِماءَهُمْ وأَمْوالَهُمْ إلَّا بحَقِّ الإسْلامِ',
      textEnglish: 'I have been commanded to fight against people until they testify that there is no deity worthy of worship except Allah and that Muhammad is the Messenger of Allah, and establish the prayer and pay the zakat. And if they do that then they will have gained protection from me for their lives and property.',
      textBangla: 'আমি মানুষের সাথে যুদ্ধ করার নির্দেশ পেয়েছি যতক্ষণ না তারা সাক্ষ্য দেয় যে আল্লাহ ছাড়া কোনো উপাস্য নেই এবং মুহাম্মাদ (সা.) আল্লাহর রাসূল এবং সালাত কায়েম করে ও যাকাত প্রদান করে। যখন তারা এটি করবে, তখন তাদের জীবন ও সম্পদ আমার থেকে রক্ষা পাবে।',
      narrator: 'Abdullah ibn Umar (RA)',
      reference: 'Sahih al-Bukhari 25, Sahih Muslim 22',
    ),
    Hadith(
      number: 9,
      titleArabic: 'ما نهيتكم عنه فاجتنبوه',
      titleEnglish: 'Avoid What I Forbid',
      titleBangla: 'যা নিষেধ করেছি তা বর্জন কর',
      textArabic: 'ما نَهَيْتُكُمْ عنه فاجْتَنِبُوهُ، وما أمَرْتُكُمْ به فَأْتُوا منه ما اسْتَطَعْتُمْ',
      textEnglish: 'What I have forbidden for you, avoid. What I have ordered you, do as much of it as you can.',
      textBangla: 'যা আমি তোমাদের নিষেধ করেছি তা বর্জন কর এবং যা আদেশ করেছি তা যথাসাধ্য পালন কর।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih al-Bukhari 7288, Sahih Muslim 1337',
    ),
    Hadith(
      number: 10,
      titleArabic: 'الكسب الطيب',
      titleEnglish: 'Lawful Earnings',
      titleBangla: 'বৈধ উপার্জন',
      textArabic: 'إنَّ اللَّهَ طَيِّبٌ لا يَقْبَلُ إلَّا طَيِّبًا',
      textEnglish: 'Indeed, Allah is pure and accepts only that which is pure.',
      textBangla: 'নিশ্চয়ই আল্লাহ পবিত্র এবং তিনি শুধুমাত্র পবিত্র জিনিসই গ্রহণ করেন।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih Muslim 1015',
    ),
    Hadith(
      number: 11,
      titleArabic: 'ترك الشبهات',
      titleEnglish: 'Leave What Makes You Doubt',
      titleBangla: 'সন্দেহজনক বিষয় পরিত্যাগ',
      textArabic: 'دَعْ ما يَرِيبُكَ إلى ما لا يَرِيبُكَ',
      textEnglish: 'Leave that which makes you doubt for that which does not make you doubt.',
      textBangla: 'যা তোমার মনে সন্দেহ সৃষ্টি করে তা পরিত্যাগ করে ঐ বিষয়ের দিকে যাও যা তোমার মনে সন্দেহ সৃষ্টি করে না।',
      narrator: 'Al-Hasan ibn Ali (RA)',
      reference: 'Jami\' at-Tirmidhi 2518, Sunan an-Nasa\'i 5711',
    ),
    Hadith(
      number: 12,
      titleArabic: 'حسن الإسلام',
      titleEnglish: 'The Beauty of Islam',
      titleBangla: 'ইসলামের সৌন্দর্য',
      textArabic: 'مِن حُسْنِ إسْلامِ المَرْءِ تَرْكُهُ ما لا يَعْنِيهِ',
      textEnglish: 'Part of the perfection of one\'s Islam is his leaving that which does not concern him.',
      textBangla: 'মানুষের ইসলামের পূর্ণতার একটি অংশ হলো যা তার সাথে সম্পর্কিত নয় তা পরিত্যাগ করা।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Jami\' at-Tirmidhi 2317, Ibn Majah 3976',
    ),
    Hadith(
      number: 13,
      titleArabic: 'كمال الإيمان',
      titleEnglish: 'Perfection of Faith',
      titleBangla: 'ঈমানের পূর্ণতা',
      textArabic: 'لا يُؤْمِنُ أحَدُكُمْ حتَّى يُحِبَّ لأخِيهِ ما يُحِبُّ لِنَفْسِهِ',
      textEnglish: 'None of you truly believes until he loves for his brother what he loves for himself.',
      textBangla: 'তোমাদের কেউ প্রকৃত মুমিন হতে পারবে না যতক্ষণ না সে তার ভাইয়ের জন্য তাই ভালোবাসে যা সে নিজের জন্য ভালোবাসে।',
      narrator: 'Anas ibn Malik (RA)',
      reference: 'Sahih al-Bukhari 13, Sahih Muslim 45',
    ),
    Hadith(
      number: 14,
      titleArabic: 'حرمة دم المسلم',
      titleEnglish: 'Inviolability of a Muslim',
      titleBangla: 'মুসলিমের সম্মান',
      textArabic: 'لا يَحِلُّ دَمُ امْرِئٍ مُسْلِمٍ إلَّا بإحْدَى ثَلاثٍ: الثَّيِّبُ الزَّانِي، والنَّفْسُ بالنَّفْسِ، والتَّارِكُ لِدِينِهِ المُفارِقُ لِلْجَماعَةِ',
      textEnglish: 'It is not permissible to spill the blood of a Muslim except in three cases: the married person who commits adultery, a life for a life, and one who forsakes his religion and separates from the community.',
      textBangla: 'মুসলিমের রক্ত প্রবাহিত করা বৈধ নয় তিনটি কারণ ব্যতীত: বিবাহিত ব্যভিচারী, প্রাণের বদলে প্রাণ এবং যে তার দ্বীন ত্যাগ করে জামাআত থেকে বিচ্ছিন্ন হয়।',
      narrator: 'Abdullah ibn Masud (RA)',
      reference: 'Sahih al-Bukhari 6878, Sahih Muslim 1676',
    ),
    Hadith(
      number: 15,
      titleArabic: 'من كان يؤمن بالله واليوم الآخر',
      titleEnglish: 'Belief in Allah and the Last Day',
      titleBangla: 'আল্লাহ ও আখিরাতে বিশ্বাস',
      textArabic: 'مَن كانَ يُؤْمِنُ باللَّهِ واليَومِ الآخِرِ فَلْيَقُلْ خَيْرًا أوْ لِيَصْمُتْ',
      textEnglish: 'Whoever believes in Allah and the Last Day should speak good or keep silent.',
      textBangla: 'যে আল্লাহ ও আখিরাতে বিশ্বাস করে তার উচিত ভালো কথা বলা অথবা চুপ থাকা।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih al-Bukhari 6018, Sahih Muslim 47',
    ),
    Hadith(
      number: 16,
      titleArabic: 'لا تغضب',
      titleEnglish: 'Do Not Get Angry',
      titleBangla: 'রাগ করো না',
      textArabic: 'أنَّ رَجُلًا قالَ للنبيِّ صَلَّى اللهُ عليه وسلَّمَ: أوْصِنِي، قالَ: لا تَغْضَبْ فَرَدَّدَ مِرَارًا، قالَ: لا تَغْضَبْ',
      textEnglish: 'A man said to the Prophet (peace be upon him): Advise me. He said: Do not get angry. The man repeated his request several times and he said: Do not get angry.',
      textBangla: 'এক ব্যক্তি নবী (সা.) কে বললেন: আমাকে উপদেশ দিন। তিনি বললেন: রাগ করো না। লোকটি বারবার অনুরোধ করলে তিনি বললেন: রাগ করো না।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih al-Bukhari 6116',
    ),
    Hadith(
      number: 17,
      titleArabic: 'الإحسان في كل شيء',
      titleEnglish: 'Excellence in Everything',
      titleBangla: 'সবকিছুতে উত্তমতা',
      textArabic: 'إنَّ اللَّهَ كَتَبَ الإحْسانَ علَى كُلِّ شيءٍ، فإذا قَتَلْتُمْ فأحْسِنُوا القِتْلَةَ، وإذا ذَبَحْتُمْ فأحْسِنُوا الذَّبْحَ، ولْيُحِدَّ أحَدُكُمْ شَفْرَتَهُ، فَلْيُرِحْ ذَبِيحَتَهُ',
      textEnglish: 'Verily Allah has prescribed excellence in all things. So when you kill, kill well; and when you slaughter, slaughter well. Let each one of you sharpen his blade and spare suffering to the animal he slaughters.',
      textBangla: 'নিশ্চয়ই আল্লাহ সবকিছুতে উত্তমতা নির্ধারণ করেছেন। সুতরাং যখন তোমরা হত্যা কর, উত্তমভাবে হত্যা কর এবং যখন যবেহ কর, উত্তমভাবে যবেহ কর। তোমাদের প্রত্যেকে যেন তার ছুরি ধার দেয় এবং যে পশু যবেহ করা হবে তাকে আরাম দেয়।',
      narrator: 'Shaddad ibn Aws (RA)',
      reference: 'Sahih Muslim 1955',
    ),
    Hadith(
      number: 18,
      titleArabic: 'تقوى الله',
      titleEnglish: 'Fear Allah',
      titleBangla: 'আল্লাহকে ভয় কর',
      textArabic: 'اتَّقِ اللَّهَ حَيْثُما كُنْتَ، وأَتْبِعِ السَّيِّئَةَ الحَسَنَةَ تَمْحُها، وخالِقِ النَّاسَ بخُلُقٍ حَسَنٍ',
      textEnglish: 'Fear Allah wherever you are, and follow up a bad deed with a good one and it will wipe it out, and behave well towards people.',
      textBangla: 'যেখানেই থাক আল্লাহকে ভয় কর এবং মন্দ কাজের পর ভালো কাজ কর তা মন্দকে মুছে দেবে এবং মানুষের সাথে সুন্দর আচরণ কর।',
      narrator: 'Abu Dharr (RA) and Muadh ibn Jabal (RA)',
      reference: 'Jami\' at-Tirmidhi 1987',
    ),
    Hadith(
      number: 19,
      titleArabic: 'آمن بالقدر',
      titleEnglish: 'Believe in Divine Decree',
      titleBangla: 'তাকদীরে বিশ্বাস',
      textArabic: 'احْفَظِ اللَّهَ يَحْفَظْكَ، احْفَظِ اللَّهَ تَجِدْهُ تُجاهَكَ',
      textEnglish: 'Be mindful of Allah and He will protect you. Be mindful of Allah and you will find Him before you.',
      textBangla: 'আল্লাহকে স্মরণ রাখ তিনি তোমাকে রক্ষা করবেন। আল্লাহকে স্মরণ রাখ তাঁকে তোমার সামনে পাবে।',
      narrator: 'Abdullah ibn Abbas (RA)',
      reference: 'Jami\' at-Tirmidhi 2516',
    ),
    Hadith(
      number: 20,
      titleArabic: 'الحياء من الإيمان',
      titleEnglish: 'Modesty is from Faith',
      titleBangla: 'লজ্জা ঈমানের অংশ',
      textArabic: 'إنَّ ممَّا أدْرَكَ النَّاسُ مِنَ الكَلامِ النبُوَّةِ الأُولَى: إذا لَمْ تَسْتَحْيِ فاصْنَعْ ما شِئْتَ',
      textEnglish: 'Indeed, among the words people have learned from the first prophets is: If you have no modesty, then do as you wish.',
      textBangla: 'নিশ্চয়ই প্রথম নবীদের থেকে মানুষ যে কথাগুলো শিখেছে তার মধ্যে রয়েছে: যদি তোমার লজ্জা না থাকে তাহলে যা ইচ্ছা তাই কর।',
      narrator: 'Abu Masud (RA)',
      reference: 'Sahih al-Bukhari 3484',
    ),
    Hadith(
      number: 21,
      titleArabic: 'الإيمان والتوحيد',
      titleEnglish: 'Faith and Tawheed',
      titleBangla: 'ঈমান ও তাওহীদ',
      textArabic: 'قُلْ: آمَنْتُ باللَّهِ ثُمَّ اسْتَقِمْ',
      textEnglish: 'Say: I believe in Allah, then be steadfast.',
      textBangla: 'বল: আমি আল্লাহর প্রতি ঈমান এনেছি, অতঃপর দৃঢ়তার সাথে থাক।',
      narrator: 'Sufyan ibn Abdullah (RA)',
      reference: 'Sahih Muslim 38',
    ),
    Hadith(
      number: 22,
      titleArabic: 'طريق الجنة',
      titleEnglish: 'The Path to Paradise',
      titleBangla: 'জান্নাতের পথ',
      textArabic: 'أرَأَيْتَ إنْ صَلَّيْتُ المَكْتُوباتِ، وصُمْتُ رَمَضانَ، وأَحْلَلْتُ الحَلالَ، وحَرَّمْتُ الحَرامَ، ولَمْ أزِدْ علَى ذلكَ شيئًا، أأَدْخُلُ الجَنَّةَ؟ قالَ: نَعَمْ',
      textEnglish: 'If I pray the obligatory prayers, fast Ramadan, treat as lawful that which is lawful and treat as forbidden that which is forbidden, and do not add anything to that, will I enter Paradise? He said: Yes.',
      textBangla: 'যদি আমি ফরয সালাত আদায় করি, রমাদানে রোযা রাখি, হালালকে হালাল এবং হারামকে হারাম মানি এবং এর উপর কিছু বৃদ্ধি না করি, তাহলে কি আমি জান্নাতে প্রবেশ করব? তিনি বললেন: হ্যাঁ।',
      narrator: 'Abu Abdullah al-Khath\'ami (RA)',      reference: 'Sahih Muslim 15',    ),
    Hadith(
      number: 23,
      titleArabic: 'الطهارة',
      titleEnglish: 'Purity',
      titleBangla: 'পবিত্রতা',
      textArabic: 'الطُّهُورُ شَطْرُ الإيمانِ، والحَمْدُ لِلَّهِ تَمْلَأُ المِيزانَ، وسُبْحانَ اللهِ والحَمْدُ لِلَّهِ تَمْلَآنِ أوْ تَمْلَأُ ما بيْنَ السَّماواتِ والأرْضِ، والصَّلاةُ نُورٌ، والصَّدَقَةُ بُرْهانٌ، والصَّبْرُ ضِياءٌ، والقُرْآنُ حُجَّةٌ لَكَ أوْ عَلَيْكَ',
      textEnglish: 'Purity is half of faith. Alhamdulillah fills the scales, and Subhan Allah and Alhamdulillah fill what is between the heavens and the earth. Prayer is light, charity is proof, patience is illumination, and the Quran is an argument for or against you.',
      textBangla: 'পবিত্রতা ঈমানের অর্ধেক। আলহামদুলিল্লাহ পাল্লা পূর্ণ করে এবং সুবহানাল্লাহ ও আলহামদুলিল্লাহ আকাশ ও পৃথিবীর মাঝের সবকিছু পূর্ণ করে। সালাত আলো, দান প্রমাণ, ধৈর্য উজ্জ্বলতা এবং কুরআন তোমার পক্ষে অথবা বিপক্ষে দলীল।',
      narrator: 'Abu Malik al-Ashari (RA)',
      reference: 'Sahih Muslim 223',
    ),
    Hadith(
      number: 24,
      titleArabic: 'القرب من الله',
      titleEnglish: 'Drawing Near to Allah',
      titleBangla: 'আল্লাহর নৈকট্য',
      textArabic: 'لا يَزالُ عَبْدِي يَتَقَرَّبُ إلَيَّ بالنَّوافِلِ حتَّى أُحِبَّهُ',
      textEnglish: 'My servant continues to draw near to Me with voluntary acts of worship until I love him.',
      textBangla: 'আমার বান্দা নফল ইবাদত দ্বারা আমার নৈকট্য অর্জন করতে থাকে যতক্ষণ না আমি তাকে ভালোবাসি।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih al-Bukhari 6502',
    ),
    Hadith(
      number: 25,
      titleArabic: 'الصدقة',
      titleEnglish: 'Charity',
      titleBangla: 'দান',
      textArabic: 'كُلُّ سُلامَى مِنَ النَّاسِ عليه صَدَقَةٌ، كُلَّ يَوْمٍ تَطْلُعُ فيه الشَّمْسُ، تَعْدِلُ بيْنَ الِاثْنَيْنِ صَدَقَةٌ، وتُعِينُ الرَّجُلَ علَى دابَّتِهِ فَتَحْمِلُهُ عليها أوْ تَرْفَعُ له عليها مَتاعَهُ صَدَقَةٌ، والكَلِمَةُ الطَّيِّبَةُ صَدَقَةٌ',
      textEnglish: 'Every joint of a person must perform a charity each day that the sun rises: to judge justly between two people is a charity. To help a man with his mount, lifting him onto it or hoisting his belongings onto it, is a charity. And a good word is a charity.',
      textBangla: 'মানুষের প্রতিটি জোড়ার উপর প্রতিদিন সূর্যোদয়ের সময় দান করা ওয়াজিব: দুই মানুষের মধ্যে ন্যায়বিচার করা দান, একজন মানুষকে তার বাহনে উঠতে সাহায্য করা বা তার মালামাল তুলে দেওয়া দান এবং ভালো কথা বলা দান।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih al-Bukhari 2989, Sahih Muslim 1009',
    ),
    Hadith(
      number: 26,
      titleArabic: 'أبواب الخير',
      titleEnglish: 'Gates of Goodness',
      titleBangla: 'কল্যাণের দরজাসমূহ',
      textArabic: 'كُلُّ مَعْرُوفٍ صَدَقَةٌ',
      textEnglish: 'Every act of kindness is charity.',
      textBangla: 'প্রতিটি ভালো কাজ দান।',
      narrator: 'Jabir ibn Abdullah (RA)',
      reference: 'Sahih al-Bukhari 6021, Sahih Muslim 1005',
    ),
    Hadith(
      number: 27,
      titleArabic: 'البر والإثم',
      titleEnglish: 'Righteousness and Sin',
      titleBangla: 'সৎকর্ম ও পাপ',
      textArabic: 'البِرُّ حُسْنُ الخُلُقِ، والإثْمُ ما حاكَ في نَفْسِكَ وكَرِهْتَ أنْ يَطَّلِعَ عليه النَّاسُ',
      textEnglish: 'Righteousness is good character, and sin is that which wavers in your heart and you dislike that people should come to know of it.',
      textBangla: 'সৎকর্ম হলো সুন্দর চরিত্র এবং পাপ হলো যা তোমার অন্তরে দোদুল্যমান থাকে এবং মানুষ তা জানুক এটা তুমি অপছন্দ কর।',
      narrator: 'Al-Nawwas ibn Saman (RA)',
      reference: 'Sahih Muslim 2553',
    ),
    Hadith(
      number: 28,
      titleArabic: 'الوصية بالسنة',
      titleEnglish: 'Adhering to the Sunnah',
      titleBangla: 'সুন্নাহ মেনে চলা',
      textArabic: 'أُوصِيكُمْ بتَقْوَى اللَّهِ والسَّمْعِ والطَّاعَةِ، وإنْ عَبْدًا حَبَشِيًّا، فإنَّهُ مَن يَعِشْ مِنكُمْ بَعْدِي فَسَيَرَى اخْتِلافًا كَثِيرًا، فَعَلَيْكُمْ بسُنَّتِي وسُنَّةِ الخُلَفاءِ الرَّاشِدِينَ المَهْدِيِّينَ، عَضُّوا عَلَيْها بالنَّواجِذِ',
      textEnglish: 'I advise you to fear Allah, to listen and obey even if an Abyssinian slave is made your leader. Whoever among you lives after me will see much disagreement. Hold fast to my Sunnah and the Sunnah of the rightly-guided Caliphs after me. Cling to it stubbornly.',
      textBangla: 'আমি তোমাদের আল্লাহকে ভয় করতে এবং শুনতে ও মান্য করতে উপদেশ দিচ্ছি, যদিও একজন হাবশী দাস তোমাদের নেতা হয়। তোমাদের মধ্যে যে আমার পরে বেঁচে থাকবে সে অনেক মতভেদ দেখবে। তখন তোমরা আমার সুন্নাহ এবং আমার পরে হিদায়াতপ্রাপ্ত খলীফাদের সুন্নাহ আঁকড়ে ধর। দাঁত দিয়ে কামড়ে ধরে রাখ।',
      narrator: 'Al-Irbad ibn Sariyah (RA)',
      reference: 'Sunan Abu Dawud 4607, Jami\' at-Tirmidhi 2676',
    ),
    Hadith(
      number: 29,
      titleArabic: 'علامات القبول',
      titleEnglish: 'Signs of Acceptance',
      titleBangla: 'কবুলের নিদর্শন',
      textArabic: 'مَن أحَبَّ لِقاءَ اللَّهِ أحَبَّ اللَّهُ لِقاءَهُ',
      textEnglish: 'Whoever loves to meet Allah, Allah loves to meet him.',
      textBangla: 'যে আল্লাহর সাক্ষাৎ পছন্দ করে আল্লাহ তার সাক্ষাৎ পছন্দ করেন।',
      narrator: 'Ubadah ibn al-Samit (RA)',
      reference: 'Sahih al-Bukhari 6507, Sahih Muslim 2683',
    ),
    Hadith(
      number: 30,
      titleArabic: 'حق الله على العباد',
      titleEnglish: 'The Right of Allah',
      titleBangla: 'বান্দাদের উপর আল্লাহর হক',
      textArabic: 'حَقُّ اللَّهِ علَى العِبادِ أنْ يَعْبُدُوهُ ولا يُشْرِكُوا به شيئًا',
      textEnglish: 'The right of Allah upon His servants is that they worship Him and do not associate anything with Him.',
      textBangla: 'বান্দাদের উপর আল্লাহর হক হলো তারা তাঁর ইবাদত করবে এবং তাঁর সাথে কিছু শরীক করবে না।',
      narrator: 'Muadh ibn Jabal (RA)',
      reference: 'Sahih al-Bukhari 5967, Sahih Muslim 30',
    ),
    Hadith(
      number: 31,
      titleArabic: 'الزهد في الدنيا',
      titleEnglish: 'Detachment from the World',
      titleBangla: 'দুনিয়া থেকে বৈরাগ্য',
      textArabic: 'ازْهَدْ في الدُّنْيا يُحِبَّكَ اللَّهُ',
      textEnglish: 'Be detached from the world and Allah will love you.',
      textBangla: 'দুনিয়া থেকে বৈরাগ্য অবলম্বন কর তাহলে আল্লাহ তোমাকে ভালোবাসবেন।',
      narrator: 'Sahl ibn Sad (RA)',
      reference: 'Sunan Ibn Majah 4102',
    ),
    Hadith(
      number: 32,
      titleArabic: 'لا ضرر ولا ضرار',
      titleEnglish: 'No Harm or Reciprocating Harm',
      titleBangla: 'ক্ষতি করা নিষেধ',
      textArabic: 'لا ضَرَرَ ولا ضِرارَ',
      textEnglish: 'There should be neither harming nor reciprocating harm.',
      textBangla: 'ক্ষতি করা যাবে না এবং ক্ষতির প্রতিশোধ নেওয়াও যাবে না।',
      narrator: 'Abu Said al-Khudri (RA)',
      reference: 'Sunan Ibn Majah 2341',
    ),
    Hadith(
      number: 33,
      titleArabic: 'البينة على المدعي',
      titleEnglish: 'Burden of Proof',
      titleBangla: 'প্রমাণের দায়িত্ব',
      textArabic: 'البَيِّنَةُ علَى المُدَّعِي، واليَمِينُ علَى مَن أنْكَرَ',
      textEnglish: 'The burden of proof is upon the claimant, and the oath is upon the one who denies.',
      textBangla: 'প্রমাণের দায়িত্ব দাবীদারের এবং শপথের দায়িত্ব অস্বীকারকারীর।',
      narrator: 'Ibn Abbas (RA)',
      reference: 'Sunan Ibn Majah 2369, Jami\' at-Tirmidhi 1341',
    ),
    Hadith(
      number: 34,
      titleArabic: 'النهي عن المنكر',
      titleEnglish: 'Forbidding Evil',
      titleBangla: 'অন্যায় নিষেধ করা',
      textArabic: 'مَن رَأى مِنكُمْ مُنْكَرًا فَلْيُغَيِّرْهُ بيَدِهِ، فإنْ لَمْ يَسْتَطِعْ فَبِلِسانِهِ، فإنْ لَمْ يَسْتَطِعْ فَبِقَلْبِهِ، وذلكَ أضْعَفُ الإيمانِ',
      textEnglish: 'Whoever among you sees an evil, let him change it with his hand; if he cannot, then with his tongue; if he cannot, then with his heart, and that is the weakest of faith.',
      textBangla: 'তোমাদের মধ্যে যে অন্যায় দেখবে সে যেন তা হাত দিয়ে পরিবর্তন করে। যদি সক্ষম না হয় তাহলে মুখ দিয়ে। যদি তাও সক্ষম না হয় তাহলে অন্তর দিয়ে এবং এটি ঈমানের সবচেয়ে দুর্বল স্তর।',
      narrator: 'Abu Said al-Khudri (RA)',
      reference: 'Sahih Muslim 49',
    ),
    Hadith(
      number: 35,
      titleArabic: 'الأخوة في الله',
      titleEnglish: 'Brotherhood in Allah',
      titleBangla: 'আল্লাহর জন্য ভ্রাতৃত্ব',
      textArabic: 'المُسْلِمُ أخُو المُسْلِمِ لا يَظْلِمُهُ ولا يُسْلِمُهُ، ومَن كانَ في حاجَةِ أخِيهِ كانَ اللَّهُ في حاجَتِهِ، ومَن فَرَّجَ عن مُسْلِمٍ كُرْبَةً، فَرَّجَ اللَّهُ عنْه كُرْبَةً مِن كُرُباتِ يَومِ القِيامَةِ',
      textEnglish: 'A Muslim is the brother of a Muslim: he does not oppress him, nor does he forsake him. Whoever fulfills the needs of his brother, Allah will fulfill his needs. Whoever relieves a Muslim of a burden, Allah will relieve him of a burden on the Day of Resurrection.',
      textBangla: 'মুসলিম মুসলিমের ভাই: সে তার প্রতি অত্যাচার করে না এবং তাকে পরিত্যাগ করে না। যে তার ভাইয়ের প্রয়োজন পূরণ করে আল্লাহ তার প্রয়োজন পূরণ করবেন। যে মুসলিমের কষ্ট দূর করে আল্লাহ কিয়ামতের দিন তার কষ্ট দূর করবেন।',
      narrator: 'Abdullah ibn Umar (RA)',
      reference: 'Sahih al-Bukhari 2442, Sahih Muslim 2580',
    ),
    Hadith(
      number: 36,
      titleArabic: 'قضاء حوائج المسلمين',
      titleEnglish: 'Helping Fellow Muslims',
      titleBangla: 'মুসলিমদের সাহায্য করা',
      textArabic: 'مَن نَفَّسَ عن مُؤْمِنٍ كُرْبَةً مِن كُرَبِ الدُّنْيا نَفَّسَ اللَّهُ عنه كُرْبَةً مِن كُرَبِ يَومِ القِيامَةِ، ومَن يَسَّرَ علَى مُعْسِرٍ، يَسَّرَ اللَّهُ عليه في الدُّنْيا والآخِرَةِ، ومَن سَتَرَ مُسْلِمًا، سَتَرَهُ اللَّهُ في الدُّنْيا والآخِرَةِ، واللَّهُ في عَوْنِ العَبْدِ ما كانَ العَبْدُ في عَوْنِ أخِيهِ',
      textEnglish: 'Whoever relieves a believer of distress in this world, Allah will relieve him of distress on the Day of Resurrection. Whoever makes things easy for one in difficulty, Allah will make things easy for him in this world and the Hereafter. Whoever conceals the faults of a Muslim, Allah will conceal his faults in this world and the Hereafter. Allah helps the servant as long as the servant helps his brother.',
      textBangla: 'যে মুমিনের দুনিয়ার কষ্ট দূর করবে আল্লাহ কিয়ামতের দিন তার কষ্ট দূর করবেন। যে কষ্টে থাকা কারো জন্য সহজ করবে আল্লাহ দুনিয়া ও আখিরাতে তার জন্য সহজ করবেন। যে মুসলিমের দোষ গোপন করবে আল্লাহ দুনিয়া ও আখিরাতে তার দোষ গোপন করবেন। আল্লাহ বান্দার সাহায্যে থাকেন যতক্ষণ বান্দা তার ভাইয়ের সাহায্যে থাকে।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih Muslim 2699',
    ),
    Hadith(
      number: 37,
      titleArabic: 'فضل الأعمال',
      titleEnglish: 'Virtue of Good Deeds',
      titleBangla: 'সৎকর্মের ফযীলত',
      textArabic: 'إنَّ اللَّهَ كَتَبَ الحَسَناتِ والسَّيِّئاتِ',
      textEnglish: 'Indeed, Allah has written down the good deeds and the bad deeds.',
      textBangla: 'নিশ্চয়ই আল্লাহ ভালো ও মন্দ কাজ লিখে রেখেছেন।',
      narrator: 'Ibn Abbas (RA)',
      reference: 'Sahih al-Bukhari 6491, Sahih Muslim 131',
    ),
    Hadith(
      number: 38,
      titleArabic: 'محبة الله',
      titleEnglish: 'The Love of Allah',
      titleBangla: 'আল্লাহর ভালোবাসা',
      textArabic: 'إنَّ اللَّهَ قالَ: مَن عادَى لي وَلِيًّا فقَدْ آذَنْتُهُ بالحَرْبِ',
      textEnglish: 'Indeed Allah said: Whoever shows enmity to a friend of Mine, I shall be at war with him.',
      textBangla: 'নিশ্চয়ই আল্লাহ বলেছেন: যে আমার বন্ধুর সাথে শত্রুতা করবে আমি তার বিরুদ্ধে যুদ্ধ ঘোষণা করব।',
      narrator: 'Abu Hurairah (RA)',
      reference: 'Sahih al-Bukhari 6502',
    ),
    Hadith(
      number: 39,
      titleArabic: 'العفو عن الخطأ',
      titleEnglish: 'Pardon for Mistakes',
      titleBangla: 'ভুলের ক্ষমা',
      textArabic: 'إنَّ اللَّهَ تَجاوَزَ عن أُمَّتي الخَطَأَ والنِّسْيانَ وما اسْتُكْرِهُوا عليه',
      textEnglish: 'Indeed Allah has pardoned for my Ummah: their mistakes, their forgetfulness, and that which they are forced to do.',
      textBangla: 'নিশ্চয়ই আল্লাহ আমার উম্মতের ভুল, ভুলে যাওয়া এবং যা তারা বাধ্য হয়ে করেছে তা ক্ষমা করেছেন।',
      narrator: 'Ibn Abbas (RA)',
      reference: 'Sunan Ibn Majah 2045',
    ),
    Hadith(
      number: 40,
      titleArabic: 'الإخلاص لله',
      titleEnglish: 'Sincerity to Allah',
      titleBangla: 'আল্লাহর জন্য একনিষ্ঠতা',
      textArabic: 'كُنْ في الدُّنْيا كَأنَّكَ غَرِيبٌ أوْ عابِرُ سَبِيلٍ',
      textEnglish: 'Be in this world as if you are a stranger or a traveler along a path.',
      textBangla: 'এই দুনিয়ায় এমনভাবে থাক যেন তুমি একজন অপরিচিত অথবা পথিক।',
      narrator: 'Abdullah ibn Umar (RA)',
      reference: 'Sahih al-Bukhari 6416',
    ),
  ];
}
