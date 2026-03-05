import '../models/islamic_month_models.dart';

class IslamicMonthsService {
  static List<IslamicMonth> getIslamicMonths() {
    return [
      // 1. Muharram
      IslamicMonth(
        number: 1,
        nameAr: 'مُحَرَّم',
        nameEn: 'Muharram',
        nameBn: 'মুহাররম',
        significance: 'The first month of the Islamic calendar. One of the four sacred months in which fighting is forbidden. It is a time for reflection and remembrance.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের প্রথম মাস। চারটি পবিত্র মাসের মধ্যে একটি যেখানে যুদ্ধ নিষিদ্ধ। এটি প্রতিফলন এবং স্মরণের একটি সময়।',
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Islamic New Year',
            titleBn: 'ইসলামিক নববর্ষ',
            descriptionEn: 'The first day of the Islamic calendar, marking the beginning of a new Hijri year. It commemorates the migration (Hijrah) of Prophet Muhammad (ﷺ) from Makkah to Madinah.',
            descriptionBn: 'ইসলামিক ক্যালেন্ডারের প্রথম দিন, একটি নতুন হিজরি বছরের সূচনা চিহ্নিত করে। এটি নবী মুহাম্মাদ (ﷺ) এর মক্কা থেকে মদিনায় হিজরতের স্মরণ করে।',
          ),
          ImportantEvent(
            day: 10,
            titleEn: 'Day of Ashura',
            titleBn: 'আশুরার দিন',
            descriptionEn: 'The 10th day of Muharram, commemorating when Allah saved Prophet Musa (Moses) and the Israelites from Pharaoh. Prophet Muhammad (ﷺ) fasted on this day and recommended Muslims to fast.',
            descriptionBn: 'মুহাররমের ১০তম দিন, যখন আল্লাহ নবী মুসা (মূসা) এবং ইসরায়েলীদের ফেরাউন থেকে রক্ষা করেছিলেন তার স্মরণে। নবী মুহাম্মাদ (ﷺ) এই দিনে রোজা রাখতেন এবং মুসলমানদের রোজা রাখার সুপারিশ করেছিলেন।',
          ),
        ],
      ),

      // 2. Safar
      IslamicMonth(
        number: 2,
        nameAr: 'صَفَر',
        nameEn: 'Safar',
        nameBn: 'সফর',
        significance: 'The second month of the Islamic calendar. The name means "empty" or "yellow" as houses were empty during this time when Arabs would travel for trade.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের দ্বিতীয় মাস। নামের অর্থ "খালি" বা "হলুদ" কারণ এই সময়ে আরবরা বাণিজ্যের জন্য তাদের ঘর খালি রাখত।',
        events: [
          ImportantEvent(
            day: 27,
            titleEn: 'Night Journey Preparations',
            titleBn: 'রাত্রি ভ্রমণের প্রস্তুতি',
            descriptionEn: 'Historical significance in the Islamic calendar. This month witnessed various events in the life of Prophet Muhammad (ﷺ).',
            descriptionBn: 'ইসলামিক ক্যালেন্ডারে ঐতিহাসিক তাৎপর্য। এই মাসে নবী মুহাম্মাদ (ﷺ) এর জীবনে বিভিন্ন ঘটনা ঘটেছিল।',
          ),
        ],
      ),

      // 3. Rabi' al-Awwal
      IslamicMonth(
        number: 3,
        nameAr: 'رَبِيع ٱلْأَوَّل',
        nameEn: "Rabi' al-Awwal",
        nameBn: 'রবিউল আউয়াল',
        significance: 'The third month of the Islamic calendar, meaning "the first spring". This is the blessed month of the birth of Prophet Muhammad (ﷺ).',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের তৃতীয় মাস, যার অর্থ "প্রথম বসন্ত"। এই মাসে নবী মুহাম্মাদ (ﷺ) জন্মগ্রহণ করেছিলেন।',
        events: [
          ImportantEvent(
            day: 12,
            titleEn: 'Mawlid al-Nabi (Birth of the Prophet)',
            titleBn: 'মাওলিদ আল-নবী (নবীর জন্মদিন)',
            descriptionEn: 'The birth of Prophet Muhammad (ﷺ) in 570 CE in Makkah. Many Muslims celebrate this day with gatherings, recitation of poetry in praise of the Prophet, and acts of charity.',
            descriptionBn: '৫৭০ খ্রিস্টাব্দে মক্কায় নবী মুহাম্মাদ (ﷺ) এর জন্ম। অনেক মুসলমান এই দিনটি সমাবেশ, নবীর প্রশংসায় কবিতা পাঠ এবং দাতব্য কাজের মাধ্যমে উদযাপন করে।',
          ),
          ImportantEvent(
            day: 17,
            titleEn: 'Migration to Madinah Completed',
            titleBn: 'মদিনায় হিজরত সম্পন্ন',
            descriptionEn: 'Prophet Muhammad (ﷺ) arrived in Madinah on this day, marking the establishment of the first Islamic state.',
            descriptionBn: 'নবী মুহাম্মাদ (ﷺ) এই দিনে মদিনায় পৌঁছেছিলেন, প্রথম ইসলামী রাষ্ট্র প্রতিষ্ঠার সূচনা করে।',
          ),
        ],
      ),

      // 4. Rabi' al-Thani
      IslamicMonth(
        number: 4,
        nameAr: 'رَبِيع ٱلثَّانِي',
        nameEn: "Rabi' al-Thani",
        nameBn: 'রবিউস সানি',
        significance: 'The fourth month of the Islamic calendar, meaning "the second spring".',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের চতুর্থ মাস, যার অর্থ "দ্বিতীয় বসন্ত"।',
        events: [],
      ),

      // 5. Jumada al-Awwal
      IslamicMonth(
        number: 5,
        nameAr: 'جُمَادَىٰ ٱلْأُولَىٰ',
        nameEn: "Jumada al-Awwal",
        nameBn: 'জমাদিউল আউয়াল',
        significance: 'The fifth month of the Islamic calendar, meaning "the first of parched land". Named so because it fell in the dry summer season.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের পঞ্চম মাস, যার অর্থ "শুষ্ক ভূমির প্রথম"। এই নামকরণ করা হয়েছিল কারণ এটি শুষ্ক গ্রীষ্মের মৌসুমে পড়েছিল।',
        events: [
          ImportantEvent(
            day: 13,
            titleEn: 'Birth of Imam Ali (رضي الله عنه)',
            titleBn: 'ইমাম আলী (রাঃ) এর জন্ম',
            descriptionEn: 'The birth of Ali ibn Abi Talib, cousin and son-in-law of Prophet Muhammad (ﷺ), the fourth Caliph of Islam, known for his knowledge, bravery, and piety.',
            descriptionBn: 'আলী ইবনে আবি তালিবের জন্ম, নবী মুহাম্মাদ (ﷺ) এর চাচাতো ভাই এবং জামাতা, ইসলামের চতুর্থ খলিফা, তাঁর জ্ঞান, সাহস এবং ধার্মিকতার জন্য পরিচিত।',
          ),
        ],
      ),

      // 6. Jumada al-Thani
      IslamicMonth(
        number: 6,
        nameAr: 'جُمَادَىٰ ٱلثَّانِيَة',
        nameEn: "Jumada al-Thani",
        nameBn: 'জমাদিউস সানি',
        significance: 'The sixth month of the Islamic calendar, meaning "the second of parched land".',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের ষষ্ঠ মাস, যার অর্থ "শুষ্ক ভূমির দ্বিতীয়"।',
        events: [
          ImportantEvent(
            day: 20,
            titleEn: 'Birth of Fatimah az-Zahra (رضي الله عنها)',
            titleBn: 'ফাতিমা আয-যাহরা (রাঃ) এর জন্ম',
            descriptionEn: 'The birth of Fatimah, beloved daughter of Prophet Muhammad (ﷺ) and wife of Ali ibn Abi Talib, known for her piety, patience, and devotion.',
            descriptionBn: 'ফাতিমার জন্ম, নবী মুহাম্মাদ (ﷺ) এর প্রিয় কন্যা এবং আলী ইবনে আবি তালিবের স্ত্রী, তাঁর ধার্মিকতা, ধৈর্য এবং ভক্তির জন্য পরিচিত।',
          ),
        ],
      ),

      // 7. Rajab
      IslamicMonth(
        number: 7,
        nameAr: 'رَجَب',
        nameEn: 'Rajab',
        nameBn: 'রজব',
        significance: 'The seventh month of the Islamic calendar and one of the four sacred months. The name means "respect" or "honor". Fighting was forbidden during this month.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের সপ্তম মাস এবং চারটি পবিত্র মাসের একটি। নামের অর্থ "সম্মান" বা "মর্যাদা"। এই মাসে যুদ্ধ নিষিদ্ধ ছিল।',
        events: [
          ImportantEvent(
            day: 27,
            titleEn: 'Isra and Mi\'raj',
            titleBn: 'ইসরা ও মিরাজ',
            descriptionEn: 'The night journey of Prophet Muhammad (ﷺ) from Makkah to Jerusalem and his ascension to the heavens. During this journey, the five daily prayers were prescribed.',
            descriptionBn: 'নবী মুহাম্মাদ (ﷺ) এর মক্কা থেকে জেরুজালেমে রাত্রি ভ্রমণ এবং স্বর্গে আরোহণ। এই যাত্রার সময় পাঁচ ওয়াক্ত নামাজ নির্ধারিত হয়েছিল।',
          ),
        ],
      ),

      // 8. Sha'ban
      IslamicMonth(
        number: 8,
        nameAr: 'شَعْبَان',
        nameEn: "Sha'ban",
        nameBn: 'শাবান',
        significance: 'The eighth month of the Islamic calendar. The name means "scattered" or "separation" as Arab tribes dispersed to find water. It is a month of preparation for Ramadan.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের অষ্টম মাস। নামের অর্থ "ছড়িয়ে পড়া" বা "বিচ্ছেদ" কারণ আরব গোত্রগুলি পানি খুঁজতে ছড়িয়ে পড়েছিল। এটি রমজানের প্রস্তুতির একটি মাস।',
        events: [
          ImportantEvent(
            day: 15,
            titleEn: 'Mid-Sha\'ban (Laylat al-Bara\'ah)',
            titleBn: 'মধ্য-শাবান (শবে বরাত)',
            descriptionEn: 'The night of mid-Sha\'ban, also known as Laylat al-Bara\'ah. Many Muslims spend this night in prayer and ask for forgiveness.',
            descriptionBn: 'মধ্য-শাবানের রাত, যা লাইলাতুল বারাআহ নামেও পরিচিত। অনেক মুসলমান এই রাতটি প্রার্থনায় কাটান এবং ক্ষমা প্রার্থনা করেন।',
          ),
        ],
      ),

      // 9. Ramadan
      IslamicMonth(
        number: 9,
        nameAr: 'رَمَضَان',
        nameEn: 'Ramadan',
        nameBn: 'রমজান',
        significance: 'The ninth and holiest month of the Islamic calendar. Muslims fast from dawn to sunset. The Quran was first revealed during this month. One of the five pillars of Islam.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের নবম এবং পবিত্রতম মাস। মুসলমানরা ভোর থেকে সূর্যাস্ত পর্যন্ত রোজা রাখে। এই মাসে কুরআন প্রথম অবতীর্ণ হয়েছিল। ইসলামের পাঁচটি স্তম্ভের একটি।',
        events: [
          ImportantEvent(
            day: 10,
            titleEn: 'Passing of Khadijah (رضي الله عنها)',
            titleBn: 'খাদিজা (রাঃ) এর ওফাত',
            descriptionEn: 'The passing of Khadijah bint Khuwaylid, the first wife of Prophet Muhammad (ﷺ), the first person to accept Islam, and a pillar of support during difficult times.',
            descriptionBn: 'খাদিজা বিনতে খুওয়াইলিদের ওফাত, নবী মুহাম্মাদ (ﷺ) এর প্রথম স্ত্রী, ইসলাম গ্রহণকারী প্রথম ব্যক্তি এবং কঠিন সময়ে সমর্থনের স্তম্ভ।',
          ),
          ImportantEvent(
            day: 17,
            titleEn: 'Battle of Badr',
            titleBn: 'বদর যুদ্ধ',
            descriptionEn: 'The first major battle between Muslims and Makkans in 624 CE. Despite being outnumbered 3:1, Muslims achieved a decisive victory with Allah\'s help, marking a turning point in Islamic history.',
            descriptionBn: '৬২৪ খ্রিস্টাব্দে মুসলমান এবং মক্কাবাসীদের মধ্যে প্রথম বড় যুদ্ধ। ৩:১ অনুপাতে সংখ্যায় কম হওয়া সত্ত্বেও, মুসলমানরা আল্লাহর সাহায্যে নিষ্পত্তিমূলক বিজয় অর্জন করে, ইসলামী ইতিহাসে একটি টার্নিং পয়েন্ট চিহ্নিত করে।',
          ),
          ImportantEvent(
            day: 19,
            titleEn: 'Conquest of Makkah',
            titleBn: 'মক্কা বিজয়',
            descriptionEn: 'The peaceful conquest of Makkah in 630 CE (8 AH), when Prophet Muhammad (ﷺ) entered the city with 10,000 companions and purified the Ka\'bah from idols.',
            descriptionBn: '৬৩০ খ্রিস্টাব্দে (৮ হিজরী) মক্কার শান্তিপূর্ণ বিজয়, যখন নবী মুহাম্মাদ (ﷺ) ১০,০০০ সাহাবীদের সাথে শহরে প্রবেশ করেন এবং কাবাকে মূর্তি থেকে পবিত্র করেন।',
          ),
          ImportantEvent(
            day: 21,
            titleEn: 'Laylat al-Qadr (Night of Power) - Last 10 Nights',
            titleBn: 'লাইলাতুল কদর (শক্তির রাত্রি) - শেষ ১০ রাত',
            descriptionEn: 'The night when the Quran was first revealed to Prophet Muhammad (ﷺ). It is better than a thousand months. Muslims seek this night in the last 10 odd nights of Ramadan, especially on the 21st, 23rd, 25th, 27th, or 29th.',
            descriptionBn: 'রাত্রি যখন কুরআন প্রথম নবী মুহাম্মাদ (ﷺ) এর কাছে অবতীর্ণ হয়েছিল। এটি হাজার মাসের চেয়ে ভাল। মুসলমানরা রমজানের শেষ ১০ বিজোড় রাতে, বিশেষত ২১, ২৩, ২৫, ২৭ বা ২৯ তারিখে এই রাত্রি খোঁজেন।',
          ),
        ],
      ),

      // 10. Shawwal
      IslamicMonth(
        number: 10,
        nameAr: 'شَوَّال',
        nameEn: 'Shawwal',
        nameBn: 'শাওয়াল',
        significance: 'The tenth month of the Islamic calendar. The name means "raised" as camels would raise their tails during this time. It begins with Eid al-Fitr celebration.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের দশম মাস। নামের অর্থ "উত্থিত" কারণ এই সময়ে উটগুলি তাদের লেজ তুলত। এটি ঈদ-উল-ফিতর উদযাপনের সাথে শুরু হয়।',
        events: [
          ImportantEvent(
            day: 1,
            titleEn: 'Eid al-Fitr',
            titleBn: 'ঈদ-উল-ফিতর',
            descriptionEn: 'The festival of breaking the fast, celebrated on the first day of Shawwal after completing the month of Ramadan. Muslims perform special prayers, give charity, and celebrate with family.',
            descriptionBn: 'রোজা ভাঙার উৎসব, রমজান মাস সম্পন্ন করার পরে শাওয়ালের প্রথম দিনে উদযাপিত হয়। মুসলমানরা বিশেষ নামাজ আদায় করে, দাতব্য দেয় এবং পরিবারের সাথে উদযাপন করে।',
          ),
        ],
      ),

      // 11. Dhul-Qa'dah
      IslamicMonth(
        number: 11,
        nameAr: 'ذُو ٱلْقَعْدَة',
        nameEn: "Dhul-Qa'dah",
        nameBn: 'জিলকদ',
        significance: 'The eleventh month of the Islamic calendar and one of the four sacred months. The name means "the one of truce" as fighting was forbidden. It precedes the Hajj season.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের একাদশ মাস এবং চারটি পবিত্র মাসের একটি। নামের অর্থ "যুদ্ধবিরতির সময়" কারণ যুদ্ধ নিষিদ্ধ ছিল। এটি হজের মৌসুমের আগে আসে।',
        events: [
          ImportantEvent(
            day: 25,
            titleEn: 'Treaty of Hudaybiyyah',
            titleBn: 'হুদায়বিয়ার সন্ধি',
            descriptionEn: 'The peace treaty between Muslims and Makkans in 628 CE (6 AH). Though it seemed unfavorable at first, Allah called it a "Clear Victory" (Fath al-Mubin) in the Quran.',
            descriptionBn: '৬২৮ খ্রিস্টাব্দে (৬ হিজরী) মুসলমান এবং মক্কাবাসীদের মধ্যে শান্তি চুক্তি। যদিও প্রথমে এটি প্রতিকূল মনে হয়েছিল, আল্লাহ কুরআনে এটিকে "সুস্পষ্ট বিজয়" (ফাতহ আল-মুবীন) বলে অভিহিত করেছেন।',
          ),
        ],
      ),

      // 12. Dhul-Hijjah
      IslamicMonth(
        number: 12,
        nameAr: 'ذُو ٱلْحِجَّة',
        nameEn: 'Dhul-Hijjah',
        nameBn: 'জিলহজ্জ',
        significance: 'The twelfth and final month of the Islamic calendar. One of the four sacred months. The month of Hajj (pilgrimage), one of the five pillars of Islam. The first ten days are among the most blessed.',
        significanceBn: 'ইসলামিক ক্যালেন্ডারের দ্বাদশ এবং চূড়ান্ত মাস। চারটি পবিত্র মাসের একটি। হজ্জের (তীর্থযাত্রা) মাস, ইসলামের পাঁচটি স্তম্ভের একটি। প্রথম দশ দিন সবচেয়ে আশীর্বাদপূর্ণ।',
        events: [
          ImportantEvent(
            day: 8,
            titleEn: 'Day of Tarwiyah (Hajj Begins)',
            titleBn: 'তারবিয়াহর দিন (হজ্জ শুরু)',
            descriptionEn: 'Pilgrims begin their journey to Mina, preparing for the main days of Hajj. They spend the day in worship and reflection.',
            descriptionBn: 'তীর্থযাত্রীরা মিনার দিকে তাদের যাত্রা শুরু করে, হজ্জের প্রধান দিনগুলির জন্য প্রস্তুতি নিয়ে। তারা ইবাদত এবং প্রতিফলনে দিন কাটায়।',
          ),
          ImportantEvent(
            day: 9,
            titleEn: 'Day of Arafah',
            titleBn: 'আরাফাহর দিন',
            descriptionEn: 'The most important day of Hajj where pilgrims stand at Mount Arafat. Prophet Muhammad (ﷺ) delivered his farewell sermon on this day. Fasting on this day expiates sins of two years for those not performing Hajj.',
            descriptionBn: 'হজ্জের সবচেয়ে গুরুত্বপূর্ণ দিন যেখানে তীর্থযাত্রীরা আরাফাত পর্বতে দাঁড়ায়। নবী মুহাম্মাদ (ﷺ) এই দিনে তাঁর বিদায়ী ভাষণ দিয়েছিলেন। যারা হজ্জ করছেন না তাদের জন্য এই দিনে রোজা রাখা দুই বছরের পাপ মোচন করে।',
          ),
          ImportantEvent(
            day: 10,
            titleEn: 'Eid al-Adha (Festival of Sacrifice)',
            titleBn: 'ঈদ-উল-আযহা (কুরবানীর ঈদ)',
            descriptionEn: 'The festival of sacrifice, commemorating Prophet Ibrahim\'s (Abraham) willingness to sacrifice his son for Allah. Muslims sacrifice animals and distribute meat to family, friends, and the poor.',
            descriptionBn: 'কুরবানীর উৎসব, নবী ইব্রাহিম (আব্রাহাম) এর আল্লাহর জন্য তাঁর পুত্রকে কুরবানী করার ইচ্ছার স্মরণে। মুসলমানরা পশু কুরবানী করে এবং পরিবার, বন্ধুবান্ধব এবং গরীবদের মধ্যে মাংস বিতরণ করে।',
          ),
          ImportantEvent(
            day: 18,
            titleEn: 'Ghadir Khumm',
            titleBn: 'গাদীর খুম',
            descriptionEn: 'The event where Prophet Muhammad (ﷺ) gave his final sermon during his last pilgrimage, emphasizing the importance of following the Quran and Sunnah.',
            descriptionBn: 'ঘটনা যেখানে নবী মুহাম্মাদ (ﷺ) তাঁর শেষ তীর্থযাত্রার সময় তাঁর চূড়ান্ত ভাষণ দিয়েছিলেন, কুরআন এবং সুন্নাহ অনুসরণের গুরুত্বের উপর জোর দিয়ে।',
          ),
        ],
      ),
    ];
  }
}
