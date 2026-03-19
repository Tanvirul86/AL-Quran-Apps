import '../models/islamic_month_models.dart';

class IslamicMonthsService {
  static List<IslamicMonth> getIslamicMonths() {
    return [
      IslamicMonth(
        number: 1,
        nameAr: 'مُحَرَّم',
        nameEn: 'Muharram',
        nameBn: 'মুহাররম',
        meaning: 'The Sacred / Forbidden',
        meaningBn: 'পবিত্র / নিষিদ্ধ',
        isSacredMonth: true,
        significance:
            'Muharram is one of the four sacred months mentioned in the Qur\'an. It is a month of restraint, repentance, and extra worship.',
        significanceBn:
            'মুহাররম কুরআনে উল্লেখিত চারটি পবিত্র মাসের একটি। এটি আত্মসংযম, তওবা ও অতিরিক্ত ইবাদতের মাস।',
        quranRef: 'At-Tawbah 9:36',
        quranAyahEn:
            'Indeed, the number of months with Allah is twelve months... of these, four are sacred.',
        keyHadith:
            'The best fasting after Ramadan is fasting in Allah\'s month, Muharram.',
        keyHadithRef: 'Sahih Muslim 1163',
        recommendedDeeds: [
          'Fast on Ashura with one additional day (9th or 11th)',
          'Increase Dhikr and Istighfar',
          'Review Hijrah lessons and renew intentions',
        ],
        recommendedDeedsBn: [
          'আশুরার সাথে ৯ বা ১১ তারিখে অতিরিক্ত রোজা',
          'জিকির ও ইস্তিগফার বৃদ্ধি',
          'হিজরতের শিক্ষা স্মরণ ও নিয়ত নবায়ন',
        ],
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Hijri New Year Begins',
            titleBn: 'হিজরি নববর্ষের শুরু',
            descriptionEn:
                'The Islamic year begins. The Hijri calendar was institutionalized during the caliphate of Umar ibn al-Khattab (RA), anchored to Hijrah.',
            descriptionBn:
                'ইসলামিক বছর শুরু হয়। উমর (রাঃ)-এর খেলাফতে হিজরি বর্ষপঞ্জি প্রাতিষ্ঠানিকভাবে চালু হয়, যার ভিত্তি হিজরত।',
            hadithRef: 'Historical consensus of early Islamic governance',
          ),
          ImportantEvent(
            day: 9,
            titleEn: 'Tasu\'a Fast (Sunnah)',
            titleBn: 'তাসু\'আর রোজা (সুন্নাহ)',
            descriptionEn:
                'The Prophet ﷺ intended fasting the 9th along with the 10th to differ from previous communities.',
            descriptionBn:
                'নবী ﷺ ১০ তারিখের সাথে ৯ তারিখ রোজা রাখতে বলেছেন, পূর্ববর্তী জাতির পদ্ধতি থেকে ভিন্নতা করার জন্য।',
            hadithRef: 'Sahih Muslim 1134',
          ),
          ImportantEvent(
            day: 10,
            titleEn: 'Ashura',
            titleBn: 'আশুরা',
            descriptionEn:
                'Fasting Ashura expiates sins of the previous year. The Prophet ﷺ fasted it and encouraged fasting it.',
            descriptionBn:
                'আশুরার রোজা পূর্ববর্তী এক বছরের গুনাহের কাফফারা হয়। নবী ﷺ নিজে রোজা রেখেছেন এবং উৎসাহ দিয়েছেন।',
            hadithRef: 'Sahih Bukhari 2004; Sahih Muslim 1130, 1162',
            isHighImportance: true,
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 10,
            titleEn: 'Musa (AS) Saved from Pharaoh (commemorated by fasting)',
            titleBn: 'ফিরআউন থেকে মূসা (আঃ)-এর নাজাত স্মরণ',
            descriptionEn:
                'The Prophet ﷺ observed Ashura and explained that Musa (AS) was saved on this day, then he fasted it in gratitude to Allah.',
            descriptionBn:
                'নবী ﷺ আশুরার দিন রোজা রেখেছেন এবং বলেছেন এ দিনে মূসা (আঃ)-কে নাজাত দেওয়া হয়েছিল; তাই আল্লাহর শোকরস্বরূপ রোজা রাখা হয়।',
            hadithRef: 'Sahih Bukhari 3397; Sahih Muslim 1130',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 2,
        nameAr: 'صَفَر',
        nameEn: 'Safar',
        nameBn: 'সফর',
        meaning: 'Whistling/Empty (classical usage)',
        meaningBn: 'খালি/প্রস্থান (প্রচলিত ব্যুৎপত্তি)',
        significance:
            'Safar has no inherent bad omen in Islam. Muslims are instructed to reject superstition and continue normal worship and reliance on Allah.',
        significanceBn:
            'ইসলামে সফর মাস নিজে অশুভ নয়। কুসংস্কার বর্জন করে স্বাভাবিক ইবাদত ও আল্লাহর উপর ভরসা রাখতে বলা হয়েছে।',
        keyHadith:
            'No contagion (by itself), no evil omen, no hama, and no Safar (as a superstition).',
        keyHadithRef: 'Sahih Bukhari 5757; Sahih Muslim 2220',
        recommendedDeeds: [
          'Avoid superstitious practices',
          'Strengthen Tawakkul (trust in Allah)',
          'Keep consistent daily prayers and Qur\'an',
        ],
        recommendedDeedsBn: [
          'কুসংস্কার ত্যাগ করা',
          'তাওয়াক্কুল (আল্লাহর উপর ভরসা) বৃদ্ধি',
          'নিয়মিত নামাজ ও কুরআন চর্চা',
        ],
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Month of Rejecting Superstition',
            titleBn: 'কুসংস্কার বর্জনের মাস',
            descriptionEn:
                'Islamic teaching rejects the idea that Safar itself brings harm or misfortune.',
            descriptionBn:
                'ইসলাম সফর মাসকে স্বয়ং অমঙ্গলজনক মনে করার ধারণা প্রত্যাখ্যান করে।',
            hadithRef: 'Sahih Bukhari 5757; Sahih Muslim 2220',
            isHighImportance: true,
          ),
          ImportantEvent(
            day: 15,
            titleEn: 'Continue Good Deeds without Innovation',
            titleBn: 'বিদআত ছাড়া নিয়মিত নেক আমল',
            descriptionEn:
                'No special fixed ritual is established exclusively for Safar; continue established Sunnah deeds.',
            descriptionBn:
                'সফরের জন্য আলাদা নির্ধারিত বিশেষ ইবাদত প্রমাণিত নয়; সুন্নতপ্রসূত আমল অব্যাহত রাখুন।',
            hadithRef: 'General fiqh principle from authentic Sunnah practice',
            evidenceTier: EvidenceTier.scholarly,
          ),
          ImportantEvent(
            day: 20,
            titleEn: 'Reliance on Allah During Hardship',
            titleBn: 'কঠিন সময়ে আল্লাহর উপর পূর্ণ ভরসা',
            descriptionEn:
                'A key practical lesson in this month is to reject fear-based superstition and strengthen trust in Allah in daily life.',
            descriptionBn:
                'এই মাসের একটি বাস্তব শিক্ষা হলো কুসংস্কারের ভয় বাদ দিয়ে জীবনের প্রতিটি ক্ষেত্রে আল্লাহর উপর ভরসা দৃঢ় করা।',
            hadithRef: 'Jami\' at-Tirmidhi 2344 (Hasan)',
            evidenceTier: EvidenceTier.hasanHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 3,
        nameAr: 'رَبِيع ٱلْأَوَّل',
        nameEn: 'Rabi\' al-Awwal',
        nameBn: 'রবিউল আউয়াল',
        significance:
            'A month linked to major Sirah milestones, including the Prophet\'s ﷺ migration period and establishment of the Madinan community.',
        significanceBn:
            'এই মাস নবী ﷺ-এর হিজরত-পর্ব ও মদিনাভিত্তিক সমাজ প্রতিষ্ঠার গুরুত্বপূর্ণ সিরাত ঘটনাবলির সাথে সংশ্লিষ্ট।',
        recommendedDeeds: [
          'Study the Sirah in depth',
          'Increase Salawat upon the Prophet ﷺ',
          'Follow his Sunnah in character and worship',
        ],
        recommendedDeedsBn: [
          'সিরাত অধ্যয়ন বৃদ্ধি',
          'নবী ﷺ-এর উপর দরূদ বৃদ্ধি',
          'আখলাক ও ইবাদতে সুন্নাহ অনুসরণ',
        ],
        events: [
          ImportantEvent(
            day: 12,
            titleEn: 'Arrival in Madinah (widely reported date)',
            titleBn: 'মদিনায় আগমন (প্রচলিত বর্ণিত তারিখ)',
            descriptionEn:
                'The Prophet ﷺ arrived in the Madinah region after Hijrah, marking the beginning of an Islamic society and state structure. Exact date details differ in historical reports.',
            descriptionBn:
                'হিজরতের পর নবী ﷺ মদিনা অঞ্চলে পৌঁছান; এর মাধ্যমে ইসলামি সমাজ-রাষ্ট্রের ভিত্তি প্রতিষ্ঠিত হয়। নির্দিষ্ট তারিখে ঐতিহাসিক বর্ণনায় পার্থক্য আছে।',
            hadithRef: 'Early Sirah sources (Ibn Ishaq/Ibn Hisham) with variant narrations',
            isHighImportance: true,
          ),
          ImportantEvent(
            day: 12,
            titleEn: 'Passing of the Prophet ﷺ (widely reported)',
            titleBn: 'নবী ﷺ-এর ওফাত (প্রচলিত বর্ণনা)',
            descriptionEn:
                'Many classical reports mention Monday in Rabi\' al-Awwal as the Prophet\'s ﷺ passing; scholars discuss exact day details.',
            descriptionBn:
                'অনেক শাস্ত্রীয় বর্ণনায় রবিউল আউয়ালের সোমবার নবী ﷺ-এর ওফাতের কথা এসেছে; নির্দিষ্ট দিন নিয়ে আলেমদের আলোচনা আছে।',
            hadithRef: 'Sahih al-Bukhari (Book of Maghazi) and Sirah discussions',
            isHighImportance: true,
            evidenceTier: EvidenceTier.historical,
          ),
          ImportantEvent(
            day: 8,
            titleEn: 'Quba Masjid Established During Hijrah Arrival Period',
            titleBn: 'হিজরতের আগমন-পর্বে কুবা মসজিদের প্রতিষ্ঠা',
            descriptionEn:
                'The Prophet ﷺ stayed in Quba before entering Madinah and established the first mosque built on piety.',
            descriptionBn:
                'মদিনায় প্রবেশের আগে নবী ﷺ কুবায় অবস্থান করেন এবং তাকওয়ার ভিত্তিতে প্রথম মসজিদ প্রতিষ্ঠা করেন।',
            quranRef: 'At-Tawbah 9:108',
            hadithRef: 'Sahih Bukhari (Virtues of Quba Masjid)',
            evidenceTier: EvidenceTier.quran,
          ),
        ],
      ),

      IslamicMonth(
        number: 4,
        nameAr: 'رَبِيع ٱلثَّانِي',
        nameEn: 'Rabi\' al-Thani',
        nameBn: 'রবিউস সানি',
        significance:
            'No universally established annual festival is fixed for this month in primary texts. It remains a normal month for obedience and growth.',
        significanceBn:
            'প্রাথমিক শরঈ সূত্রে এ মাসের জন্য সর্বজনস্বীকৃত বার্ষিক উৎসব নির্ধারিত নেই; এটি সাধারণভাবে নেক আমলের ধারাবাহিকতার মাস।',
        recommendedDeeds: [
          'Maintain regular Sunnah fasting (Mondays/Thursdays)',
          'Increase Qur\'an recitation',
          'Give charity quietly',
        ],
        recommendedDeedsBn: [
          'সোম-বৃহস্পতিবার সুন্নত রোজা',
          'কুরআন তিলাওয়াত বৃদ্ধি',
          'গোপনে সদকা করা',
        ],
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Month of Steadfast Deeds',
            titleBn: 'ধারাবাহিক নেক আমলের মাস',
            descriptionEn:
                'The best deeds are those that are consistent even if small; this applies in every month including Rabi\' al-Thani.',
            descriptionBn:
                'সর্বোত্তম আমল হলো ধারাবাহিক আমল, যদিও তা কম হয়—এ নীতি রবিউস সানিসহ সব মাসে প্রযোজ্য।',
            hadithRef: 'Sahih Bukhari 6464; Sahih Muslim 783',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 18,
            titleEn: 'Sunnah Fasting on Mondays and Thursdays',
            titleBn: 'সোম ও বৃহস্পতিবার সুন্নাহ রোজা',
            descriptionEn:
                'Regular voluntary fasting on Mondays and Thursdays is an established Sunnah and fits this month\'s theme of consistency.',
            descriptionBn:
                'সোম ও বৃহস্পতিবার নফল রোজা প্রমাণিত সুন্নাহ; ধারাবাহিক আমলের এই মাসে এটি বিশেষ উপযোগী।',
            hadithRef: 'Sahih Muslim 1162; Jami\' at-Tirmidhi 747',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 5,
        nameAr: 'جُمَادَىٰ ٱلْأُولَىٰ',
        nameEn: 'Jumada al-Awwal',
        nameBn: 'জমাদিউল আউয়াল',
        significance:
            'Historically connected to major Sirah events in the Madinan period, including the Battle of Mu\'tah (8 AH).',
        significanceBn:
            'মাদানি যুগের গুরুত্বপূর্ণ সিরাত ঘটনাবলির সাথে এই মাস যুক্ত, বিশেষত মুতা যুদ্ধ (৮ হিজরি)।',
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Battle of Mu\'tah (8 AH, in this month)',
            titleBn: 'মুতা যুদ্ধ (৮ হিজরি, এই মাসে)',
            descriptionEn:
                'A major expedition against Byzantine-aligned forces. It highlighted sacrifice and leadership of Zayd, Ja\'far, and Ibn Rawahah (RA).',
            descriptionBn:
                'বাইজেন্টাইন-সমর্থিত বাহিনীর বিরুদ্ধে গুরুত্বপূর্ণ অভিযান; জায়েদ, জাফর ও ইবনু রাওয়াহা (রাঃ)-এর ত্যাগ ও নেতৃত্ব এতে উজ্জ্বল।',
            hadithRef: 'Sahih al-Bukhari, Kitab al-Maghazi',
            isHighImportance: true,
            evidenceTier: EvidenceTier.historical,
          ),
          ImportantEvent(
            day: 3,
            titleEn: 'Leadership Lessons from Mu\'tah',
            titleBn: 'মুতা থেকে নেতৃত্বের শিক্ষা',
            descriptionEn:
                'The Prophet ﷺ informed companions about the martyrdom sequence of Zayd, Ja\'far and Ibn Rawahah, highlighting sacrifice and leadership under trial.',
            descriptionBn:
                'নবী ﷺ জায়েদ, জাফর ও ইবনু রাওয়াহা (রাঃ)-এর শাহাদাতের ধারাবিবরণী দিয়ে কঠিন পরিস্থিতিতে নেতৃত্ব ও ত্যাগের শিক্ষা দেন।',
            hadithRef: 'Sahih al-Bukhari 4262',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 6,
        nameAr: 'جُمَادَىٰ ٱلْآخِرَة',
        nameEn: 'Jumada al-Akhirah',
        nameBn: 'জমাদিউস সানি',
        significance:
            'A month without fixed obligatory rituals, ideal for continuing beneficial knowledge, repentance and family rights.',
        significanceBn:
            'এ মাসে নির্দিষ্ট ফরজ বার্ষিক রীতি নেই; ইলম, তওবা ও হক আদায়ে ধারাবাহিকতার জন্য উপযুক্ত মাস।',
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Continue Sunnah-Centered Worship',
            titleBn: 'সুন্নাহকেন্দ্রিক ইবাদত অব্যাহত রাখা',
            descriptionEn:
                'Use the month to strengthen prayer, Qur\'an, and rights of kinship without introducing unfounded rituals.',
            descriptionBn:
                'বিদআত ছাড়া নামাজ, কুরআন ও আত্মীয়তার হক জোরদার করার মাস হিসেবে কাজে লাগান।',
            hadithRef: 'General Sunnah principle',
            evidenceTier: EvidenceTier.scholarly,
          ),
          ImportantEvent(
            day: 22,
            titleEn: 'Passing of Abu Bakr (RA) (widely reported in this month)',
            titleBn: 'আবু বকর (রাঃ)-এর ওফাত (প্রচলিত ঐতিহাসিক বর্ণনা)',
            descriptionEn:
                'Classical historical sources mention the passing of Abu Bakr as-Siddiq (RA) in Jumada al-Akhirah (13 AH).',
            descriptionBn:
                'শাস্ত্রীয় ইতিহাসগ্রন্থে জমাদিউস সানি (১৩ হিজরি) মাসে আবু বকর সিদ্দীক (রাঃ)-এর ওফাতের বর্ণনা পাওয়া যায়।',
            hadithRef: 'Classical historical sources (Tarikh works)',
            evidenceTier: EvidenceTier.historical,
          ),
        ],
      ),

      IslamicMonth(
        number: 7,
        nameAr: 'رَجَب',
        nameEn: 'Rajab',
        nameBn: 'রজব',
        isSacredMonth: true,
        significance:
            'Rajab is one of the four sacred months. It is a time to avoid sin and prepare spiritually for Sha\'ban and Ramadan.',
        significanceBn:
            'রজব চারটি পবিত্র মাসের একটি। গুনাহ থেকে বিরত থাকা এবং শাবান-রমজানের আধ্যাত্মিক প্রস্তুতির মাস।',
        quranRef: 'At-Tawbah 9:36',
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Sacred Month Begins',
            titleBn: 'পবিত্র মাসের সূচনা',
            descriptionEn:
                'Rajab begins as a sacred month in which wrongdoing should be especially avoided.',
            descriptionBn:
                'রজব পবিত্র মাস হিসেবে শুরু হয়; এ সময়ে গুনাহ থেকে বিশেষভাবে বাঁচতে হবে।',
            quranRef: 'At-Tawbah 9:36',
            isHighImportance: true,
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 15,
            titleEn: 'Warning Against Unverified Rajab Rituals',
            titleBn: 'রজবের অপ্রমাণিত আমল থেকে সতর্কতা',
            descriptionEn:
                'Scholars caution against attaching fixed acts to Rajab without authentic evidence. Focus on established Sunnah deeds.',
            descriptionBn:
                'সাহিহ প্রমাণ ছাড়া রজবের সাথে নির্দিষ্ট আমল জুড়ে না দিতে আলেমরা সতর্ক করেছেন; প্রমাণিত সুন্নাহ আমলে থাকুন।',
            hadithRef: 'Hadith criticism works of Ibn Hajar, Ibn Rajab (scholarly guidance)',
            evidenceTier: EvidenceTier.scholarly,
          ),
          ImportantEvent(
            day: 20,
            titleEn: 'Isra and Mi\'raj: Event Affirmed, Date Not Fixed by Sahih Text',
            titleBn: 'ইসরা-মেরাজ: ঘটনা প্রমাণিত, নির্দিষ্ট তারিখ সাহিহভাবে স্থির নয়',
            descriptionEn:
                'The event of Isra and Mi\'raj is established in the Qur\'an and authentic narrations, but assigning a fixed annual Rajab ritual date is debated by scholars.',
            descriptionBn:
                'ইসরা-মেরাজের ঘটনা কুরআন ও সহিহ বর্ণনায় প্রতিষ্ঠিত; তবে রজবের নির্দিষ্ট তারিখকে বার্ষিক শরঈ রীতি হিসেবে নির্ধারণে আলেমদের মতভেদ আছে।',
            quranRef: 'Al-Isra 17:1',
            hadithRef: 'Sahih al-Bukhari (Kitab al-Salah); scholarly date discussions',
            evidenceTier: EvidenceTier.scholarly,
          ),
        ],
      ),

      IslamicMonth(
        number: 8,
        nameAr: 'شَعْبَان',
        nameEn: 'Sha\'ban',
        nameBn: 'শাবান',
        significance:
            'Sha\'ban is a preparation month before Ramadan. The Prophet ﷺ used to fast much of this month.',
        significanceBn:
            'শাবান রমজানের পূর্বপ্রস্তুতির মাস। নবী ﷺ এ মাসে অনেক বেশি নফল রোজা রাখতেন।',
        keyHadith:
            'I did not see the Prophet complete fasting in any month besides Ramadan, and I did not see him fasting in any month more than Sha\'ban.',
        keyHadithRef: 'Sahih Bukhari 1969; Sahih Muslim 1156',
        events: [
          ImportantEvent(
            day: 15,
            titleEn: 'Middle of Sha\'ban (date known, practices differ)',
            titleBn: 'মধ্য-শাবান (তারিখ পরিচিত, আমলে মতপার্থক্য)',
            descriptionEn:
                'The date is known in the calendar, but scholars differ on assigning special fixed rituals to this night. Follow authenticated worship only.',
            descriptionBn:
                'ক্যালেন্ডারে তারিখটি পরিচিত, তবে এ রাতে নির্দিষ্ট বিশেষ আমল নির্ধারণে আলেমদের মতভেদ আছে। প্রমাণিত আমলেই সীমাবদ্ধ থাকুন।',
            hadithRef: 'Scholarly discussions on authenticity (tahqiq-based fiqh)',
            evidenceTier: EvidenceTier.scholarly,
          ),
          ImportantEvent(
            day: 16,
            titleEn: 'Qiblah Change (reported in this period)',
            titleBn: 'কিবলা পরিবর্তন (এই সময়পর্বে বর্ণিত)',
            descriptionEn:
                'The direction of prayer was changed to the Ka\'bah in Madinah during this period according many reports.',
            descriptionBn:
                'অনেক বর্ণনা অনুযায়ী মদিনা পর্বে এ সময় কিবলা বাইতুল মুকাদ্দাস থেকে কা\'বার দিকে পরিবর্তিত হয়।',
            quranRef: 'Al-Baqarah 2:144',
            isHighImportance: true,
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 1,
            titleEn: 'The Prophet ﷺ Frequently Fasted in Sha\'ban',
            titleBn: 'নবী ﷺ শাবানে অধিক নফল রোজা রাখতেন',
            descriptionEn:
                'Authentic narrations describe Sha\'ban as the month in which the Prophet ﷺ fasted more than in most months besides Ramadan.',
            descriptionBn:
                'সহিহ বর্ণনায় এসেছে, রমজান ছাড়া শাবান মাসে নবী ﷺ অধিক নফল রোজা রাখতেন।',
            hadithRef: 'Sahih Bukhari 1969; Sahih Muslim 1156',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 9,
        nameAr: 'رَمَضَان',
        nameEn: 'Ramadan',
        nameBn: 'রমজান',
        significance:
            'The holiest month in which fasting is obligatory and the Qur\'an was revealed. It includes Laylat al-Qadr in the last ten nights.',
        significanceBn:
            'সবচেয়ে পবিত্র মাস; এতে রোজা ফরজ এবং কুরআন নাযিল হয়েছে। শেষ দশ রাতে লাইলাতুল কদর রয়েছে।',
        quranRef: 'Al-Baqarah 2:185',
        keyHadithRef: 'Sahih Bukhari 1901; Sahih Muslim 760',
        recommendedDeeds: [
          'Observe obligatory fast properly',
          'Pray Taraweeh and Qiyam',
          'Search for Laylat al-Qadr in odd last ten nights',
          'Increase charity and Qur\'an recitation',
        ],
        recommendedDeedsBn: [
          'ফরজ রোজা সুন্দরভাবে পালন',
          'তারাবি ও কিয়ামুল লাইল',
          'শেষ দশ বিজোড় রাতে লাইলাতুল কদর অনুসন্ধান',
          'সদকা ও কুরআন তিলাওয়াত বৃদ্ধি',
        ],
        events: [
          ImportantEvent(
            day: 17,
            titleEn: 'Battle of Badr (2 AH)',
            titleBn: 'বদর যুদ্ধ (২ হিজরি)',
            descriptionEn:
                'The first decisive battle in Islam where Allah granted victory to the believers despite small numbers.',
            descriptionBn:
                'ইসলামের প্রথম সিদ্ধান্তমূলক যুদ্ধ; স্বল্প সংখ্যক মুমিনকে আল্লাহ বিজয় দান করেন।',
            quranRef: 'Al-Anfal 8:9-12',
            isHighImportance: true,
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 20,
            titleEn: 'Conquest of Makkah (8 AH)',
            titleBn: 'মক্কা বিজয় (৮ হিজরি)',
            descriptionEn:
                'A major turning point when Makkah entered Islam and idols were removed from the Ka\'bah.',
            descriptionBn:
                'মক্কা ইসলামে প্রবেশ করে এবং কা\'বা থেকে মূর্তি অপসারণ করা হয়—ইসলামী ইতিহাসের বড় মোড়।',
            quranRef: 'An-Nasr 110:1-3',
            isHighImportance: true,
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 21,
            titleEn: 'Last Ten Nights Begin (Seek Laylat al-Qadr)',
            titleBn: 'শেষ দশ রাত শুরু (লাইলাতুল কদর অনুসন্ধান)',
            descriptionEn:
                'The Prophet ﷺ intensified worship in the last ten nights and urged seeking Laylat al-Qadr in odd nights.',
            descriptionBn:
                'নবী ﷺ শেষ দশ রাতে ইবাদত বাড়াতেন এবং বিজোড় রাতে লাইলাতুল কদর অনুসন্ধানের নির্দেশ দেন।',
            hadithRef: 'Sahih Bukhari 2017; Sahih Muslim 1167',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 1,
            titleEn: 'Ramadan Begins: Gates of Mercy Open',
            titleBn: 'রমজান শুরু: রহমতের দরজা উন্মুক্ত',
            descriptionEn:
                'When Ramadan begins, gates of Paradise are opened and devils are restrained, encouraging believers to increase obedience.',
            descriptionBn:
                'রমজান শুরু হলে জান্নাতের দরজাগুলো খুলে দেওয়া হয় এবং শয়তানদের শৃঙ্খলিত করা হয়; মুমিনদের জন্য এটি ইবাদত বৃদ্ধির আহ্বান।',
            hadithRef: 'Sahih Bukhari 1899; Sahih Muslim 1079',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 10,
        nameAr: 'شَوَّال',
        nameEn: 'Shawwal',
        nameBn: 'শাওয়াল',
        significance:
            'Shawwal begins with Eid al-Fitr and includes the Sunnah of six voluntary fasts after Ramadan.',
        significanceBn:
            'শাওয়াল ঈদুল ফিতর দিয়ে শুরু হয় এবং রমজানের পর ৬টি নফল রোজার সুন্নাহ এতে রয়েছে।',
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Eid al-Fitr',
            titleBn: 'ঈদুল ফিতর',
            descriptionEn:
                'A day of gratitude after Ramadan: Eid prayer, Zakah al-Fitr completion, family ties and lawful joy.',
            descriptionBn:
                'রমজান শেষে কৃতজ্ঞতার দিন: ঈদের নামাজ, সদকাতুল ফিতর, আত্মীয়তা ও হালাল আনন্দ।',
            hadithRef: 'Sahih Bukhari (Eid chapters); Sahih Muslim (Eid chapters)',
            isHighImportance: true,
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 2,
            titleEn: 'Six Fasts of Shawwal (any 6 days)',
            titleBn: 'শাওয়ালের ৬ রোজা (যে কোনো ৬ দিন)',
            descriptionEn:
                'Whoever fasts Ramadan and follows it with six days of Shawwal gets the reward like fasting the whole year.',
            descriptionBn:
                'যে ব্যক্তি রমজানের রোজার পর শাওয়ালের ৬টি রোজা রাখে, সে যেন পুরো বছর রোজা রাখল—এমন সওয়াব পায়।',
            hadithRef: 'Sahih Muslim 1164',
            isHighImportance: true,
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 7,
            titleEn: 'Battle of Uhud (3 AH)',
            titleBn: 'উহুদ যুদ্ধ (৩ হিজরি)',
            descriptionEn:
                'A major lesson in obedience, patience and discipline after early Muslim setbacks.',
            descriptionBn:
                'আনুগত্য, ধৈর্য ও শৃঙ্খলার গুরুত্বপূর্ণ শিক্ষা বহনকারী ঐতিহাসিক যুদ্ধ।',
            quranRef: 'Aal-Imran 3:152-153',
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 5,
            titleEn: 'Marriage of Aisha (RA) in Shawwal (reported)',
            titleBn: 'শাওয়ালে আয়িশা (রাঃ)-এর বিবাহ (বর্ণিত)',
            descriptionEn:
                'Aisha (RA) reported that her marriage to the Prophet ﷺ was in Shawwal, used by scholars to refute pre-Islamic superstitions about this month.',
            descriptionBn:
                'আয়িশা (রাঃ) বর্ণনা করেন যে নবী ﷺ-এর সাথে তার বিবাহ শাওয়ালে হয়েছিল; আলেমরা এ বর্ণনা দিয়ে এ মাসের কুসংস্কার খণ্ডন করেন।',
            hadithRef: 'Sahih Muslim 1423',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 11,
        nameAr: 'ذُو ٱلْقَعْدَة',
        nameEn: 'Dhul-Qa\'dah',
        nameBn: 'জিলকদ',
        isSacredMonth: true,
        significance:
            'A sacred month and the opening period of Hajj preparations. Warfare was traditionally suspended.',
        significanceBn:
            'এটি পবিত্র মাস এবং হজ্জ প্রস্তুতির সূচনাকাল। ঐতিহ্যগতভাবে এ মাসে যুদ্ধবিগ্রহ স্থগিত থাকত।',
        quranRef: 'At-Tawbah 9:36',
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Sacred Month Reminder',
            titleBn: 'পবিত্র মাসের নির্দেশনা',
            descriptionEn:
                'As a sacred month, Muslims should avoid oppression and increase obedience.',
            descriptionBn:
                'পবিত্র মাস হিসেবে জুলুম বর্জন ও ইবাদত বৃদ্ধি করা আবশ্যক।',
            quranRef: 'At-Tawbah 9:36',
            isHighImportance: true,
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 25,
            titleEn: 'Treaty of Hudaybiyyah (6 AH, in this month)',
            titleBn: 'হুদায়বিয়ার সন্ধি (৬ হিজরি, এ মাসে)',
            descriptionEn:
                'A strategic peace treaty Allah called a clear victory, opening the door for rapid spread of Islam.',
            descriptionBn:
                'আল্লাহ যাকে ‘স্পষ্ট বিজয়’ বলেছেন, সেই কৌশলগত শান্তিচুক্তি ইসলামের দ্রুত বিস্তারের পথ খুলে দেয়।',
            quranRef: 'Al-Fath 48:1',
            isHighImportance: true,
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 18,
            titleEn: 'Most Umrahs of the Prophet ﷺ Were in Dhul-Qa\'dah',
            titleBn: 'নবী ﷺ-এর অধিকাংশ উমরা ছিল জিলকদ মাসে',
            descriptionEn:
                'Authentic narrations mention that most of the Prophet\'s ﷺ performed Umrahs occurred in Dhul-Qa\'dah, showing its importance for pilgrimage preparation.',
            descriptionBn:
                'সহিহ বর্ণনায় এসেছে, নবী ﷺ-এর অধিকাংশ উমরা জিলকদ মাসে সংঘটিত হয়েছে; এটি হজ্জ-উমরা প্রস্তুতির তাৎপর্য প্রকাশ করে।',
            hadithRef: 'Sahih Bukhari 1780; Sahih Muslim 1253',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),

      IslamicMonth(
        number: 12,
        nameAr: 'ذُو ٱلْحِجَّة',
        nameEn: 'Dhul-Hijjah',
        nameBn: 'জিলহজ্জ',
        isSacredMonth: true,
        significance:
            'The month of Hajj and Eid al-Adha. The first ten days are among the greatest days of the year for righteous deeds.',
        significanceBn:
            'হজ্জ ও ঈদুল আযহার মাস। এ মাসের প্রথম দশ দিন নেক আমলের জন্য বছরের সেরা দিনগুলোর অন্তর্ভুক্ত।',
        keyHadith:
            'There are no days in which righteous deeds are more beloved to Allah than these ten days.',
        keyHadithRef: 'Sahih Bukhari 969',
        events: [
          ImportantEvent(
            day: 8,
            titleEn: 'Day of Tarwiyah',
            titleBn: 'ইয়াওমুত তারবিয়াহ',
            descriptionEn:
                'Pilgrims move to Mina to begin core Hajj rites.',
            descriptionBn:
                'হাজিরা হজ্জের মূল আনুষ্ঠানিকতা শুরু করতে মিনায় গমন করেন।',
            hadithRef: 'Hajj chapters in Sahih Muslim',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 9,
            titleEn: 'Day of Arafah',
            titleBn: 'ইয়াওমু আরাফাহ',
            descriptionEn:
                'The greatest day of Hajj. For non-pilgrims, fasting this day expiates sins of the previous and coming year.',
            descriptionBn:
                'হজ্জের শ্রেষ্ঠ দিন। অ-হাজিদের জন্য এ দিনের রোজা অতীত ও আগত এক বছরের গুনাহের কাফফারা হয়।',
            hadithRef: 'Sahih Muslim 1162',
            isHighImportance: true,
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 10,
            titleEn: 'Eid al-Adha / Day of Sacrifice',
            titleBn: 'ঈদুল আযহা / কুরবানির দিন',
            descriptionEn:
                'Commemorates the devotion of Ibrahim (AS); Muslims offer sacrifice and distribute meat.',
            descriptionBn:
                'ইবরাহিম (আঃ)-এর আনুগত্য স্মরণে মুসলমানরা কুরবানি করে এবং মাংস বণ্টন করে।',
            quranRef: 'Al-Hajj 22:34-37',
            isHighImportance: true,
            evidenceTier: EvidenceTier.quran,
          ),
          ImportantEvent(
            day: 11,
            titleEn: 'Days of Tashriq (11-13 Dhul-Hijjah)',
            titleBn: 'আইয়্যামুত তাশরীক (১১-১৩ জিলহজ্জ)',
            descriptionEn:
                'Days of eating, drinking, and remembrance of Allah after Eid; pilgrims continue rites in Mina.',
            descriptionBn:
                'ঈদের পর আল্লাহর জিকির, হালাল আহার ও মিনায় হজ্জের বাকি আনুষ্ঠানিকতার দিনসমূহ।',
            hadithRef: 'Sahih Muslim 1141',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
          ImportantEvent(
            day: 13,
            titleEn: 'Final Day of Tashriq and Takbir',
            titleBn: 'তাশরীকের শেষ দিন ও তাকবির',
            descriptionEn:
                'Pilgrims complete remaining rites and Muslims continue remembrance of Allah during the days of Tashriq.',
            descriptionBn:
                'হাজিরা বাকি আনুষ্ঠানিকতা সম্পন্ন করেন এবং মুসলমানরা তাশরীকের দিনগুলোতে আল্লাহর জিকির অব্যাহত রাখেন।',
            hadithRef: 'Sahih Muslim 1141; Al-Baqarah 2:203',
            evidenceTier: EvidenceTier.sahihHadith,
          ),
        ],
      ),
    ];
  }
}
