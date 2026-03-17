import 'package:flutter/material.dart';
import '../models/mushaf_page.dart';
import '../services/mushaf_service.dart';

/// Mushaf Mode — 604-page Madani Mushaf view (Muslim Pro style)
class MushafPageScreen extends StatefulWidget {
  final int initialPage;

  const MushafPageScreen({
    super.key,
    this.initialPage = 1,
  });

  @override
  State<MushafPageScreen> createState() => _MushafPageScreenState();
}

class _MushafPageScreenState extends State<MushafPageScreen> {
  final MushafService _mushafService = MushafService();
  late PageController _pageController;

  // ── Palette (Muslim Pro inspired warm parchment) ──────────────────────────
  static const Color _pageBg        = Color(0xFFFDF6E3);
  static const Color _textColor     = Color(0xFF1A1208);
  static const Color _brownAccent   = Color(0xFF6B3410);
  static const Color _goldAccent    = Color(0xFFB8860B);
  static const Color _bannerBg      = Color(0xFFEEDFB4);

  int _currentPage = 1;
  MushafPage? _currentPageData;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.initialPage;
    _pageController = PageController(initialPage: _currentPage - 1);
    _loadPage(_currentPage);
  }

  Future<void> _loadPage(int pageNumber) async {
    setState(() => _loading = true);
    final pageData = await _mushafService.getPage(pageNumber);
    setState(() {
      _currentPageData = pageData;
      _loading = false;
    });
    await _mushafService.saveLastReadPage(pageNumber);
  }

  // ── Scaffold ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _buildAppBar(),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() => _currentPage = index + 1);
          _loadPage(index + 1);
        },
        itemCount: 604,
        itemBuilder: (_, __) => _buildMushafPage(),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _pageBg,
      foregroundColor: _brownAccent,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Navigator.of(context).pop(),
        color: _brownAccent,
      ),
      title: _currentPageData == null
          ? null
          : Text(
              _getSurahArabicName(_currentPageData!.startSurahNumber),
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 20,
                color: _brownAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.menu_book_outlined, size: 22),
          onPressed: _showJuzNavigation,
          color: _brownAccent,
          tooltip: 'Jump to Juz',
        ),
        IconButton(
          icon: const Icon(Icons.search, size: 22),
          onPressed: _showPageJump,
          color: _brownAccent,
          tooltip: 'Jump to Page',
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  // ── Page layout (Muslim Pro style) ────────────────────────────────────────

  Widget _buildMushafPage() {
    if (_loading || _currentPageData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      color: _pageBg,
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
      child: Column(
        children: [
          _buildPageTopBar(),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFAEC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _goldAccent.withValues(alpha: 0.75), width: 1),
              ),
              child: Container(
                margin: const EdgeInsets.all(4),
                padding: const EdgeInsets.fromLTRB(12, 6, 12, 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _brownAccent.withValues(alpha: 0.45), width: 0.7),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_isStartOfSurah()) _buildSurahBanner(),
                    if (_isStartOfSurah() && _mushafService.pageHasBismillah(_currentPage))
                      _buildBismillah(),
                    Expanded(child: _buildTextLines()),
                    _buildPageNumber(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Top bar:  الجزء N (left)  ──gold line──  سورة Name (right)
  Widget _buildPageTopBar() {
    final juz = _mushafService.getJuzForPage(_currentPage);
    final surahName = _getSurahArabicName(_currentPageData!.startSurahNumber);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
          child: Row(
            children: [
              Text(
                'الجزء $juz',
                style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 14,
                  color: _brownAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'سورة $surahName',
                style: const TextStyle(
                  fontFamily: 'Scheherazade',
                  fontSize: 14,
                  color: _brownAccent,
                  fontWeight: FontWeight.w600,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
        _buildGoldHairline(),
      ],
    );
  }

  Widget _buildGoldHairline() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _goldAccent,
            _goldAccent,
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  bool _isStartOfSurah() => _currentPageData!.startAyahNumber == 1;

  /// Ornamental surah name banner (Muslim Pro style: gold-bordered strip)
  Widget _buildSurahBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 6, 0, 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: _bannerBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _goldAccent.withValues(alpha: 0.9), width: 0.8),
      ),
      child: Row(
        children: [
          const Text('۞', style: TextStyle(color: _goldAccent, fontSize: 16)),
          Expanded(
            child: Text(
              'سُورَةُ ${_getSurahArabicName(_currentPageData!.startSurahNumber)}',
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 20,
                color: _brownAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Text('۞', style: TextStyle(color: _goldAccent, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Text(
        'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ',
        textAlign: TextAlign.center,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 24,
          height: 1.6,
          color: _textColor,
        ),
      ),
    );
  }

  /// Lines spread evenly to fill the page — like a real Mushaf
  Widget _buildTextLines() {
    final lines = _currentPageData!.lines;
    if (lines.isEmpty) {
      return const Center(
        child: Text('No content available', style: TextStyle(color: Colors.grey)),
      );
    }
    final paddedLines = List<PageLine>.from(lines);
    while (paddedLines.length < 15) {
      paddedLines.add(
        PageLine(
          lineNumber: paddedLines.length + 1,
          surahNumber: _currentPageData!.startSurahNumber,
          ayahNumber: _currentPageData!.startAyahNumber,
          arabicText: '',
        ),
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: paddedLines
          .map(
            (line) => Text(
              line.arabicText,
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 21,
                height: 1.45,
                color: _textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.visible,
            ),
          )
          .toList(),
    );
  }

  /// ─────── 123 ─────── (page number between gold lines)
  Widget _buildPageNumber() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, _goldAccent],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Text(
              '$_currentPage',
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _brownAccent,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_goldAccent, Colors.transparent],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Minimal bottom bar: ›  page / 604  ‹  (tap page counter to jump)
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: _pageBg,
        border: Border(
          top: BorderSide(color: _goldAccent, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Right chevron = previous page (RTL reading order)
              IconButton(
                icon: Icon(
                  Icons.chevron_right,
                  size: 32,
                  color: _currentPage > 1 ? _brownAccent : Colors.grey.shade300,
                ),
                onPressed: _currentPage > 1
                    ? () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                tooltip: 'Previous Page',
              ),
              GestureDetector(
                onTap: _showPageJump,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                  decoration: BoxDecoration(
                    border: Border.all(color: _goldAccent.withValues(alpha: 0.6)),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_currentPage / 604',
                    style: const TextStyle(
                      color: _brownAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              // Left chevron = next page (RTL reading order)
              IconButton(
                icon: Icon(
                  Icons.chevron_left,
                  size: 32,
                  color: _currentPage < 604 ? _brownAccent : Colors.grey.shade300,
                ),
                onPressed: _currentPage < 604
                    ? () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        )
                    : null,
                tooltip: 'Next Page',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── All 114 surah names ───────────────────────────────────────────────────

  String _getSurahArabicName(int n) {
    const names = {
      1: 'الفاتحة',    2: 'البقرة',      3: 'آل عمران',   4: 'النساء',
      5: 'المائدة',    6: 'الأنعام',     7: 'الأعراف',    8: 'الأنفال',
      9: 'التوبة',    10: 'يونس',       11: 'هود',        12: 'يوسف',
     13: 'الرعد',     14: 'إبراهيم',    15: 'الحجر',      16: 'النحل',
     17: 'الإسراء',   18: 'الكهف',      19: 'مريم',       20: 'طه',
     21: 'الأنبياء',  22: 'الحج',       23: 'المؤمنون',   24: 'النور',
     25: 'الفرقان',   26: 'الشعراء',    27: 'النمل',      28: 'القصص',
     29: 'العنكبوت',  30: 'الروم',      31: 'لقمان',      32: 'السجدة',
     33: 'الأحزاب',   34: 'سبأ',        35: 'فاطر',       36: 'يس',
     37: 'الصافات',   38: 'ص',          39: 'الزمر',      40: 'غافر',
     41: 'فصلت',      42: 'الشورى',     43: 'الزخرف',     44: 'الدخان',
     45: 'الجاثية',   46: 'الأحقاف',    47: 'محمد',       48: 'الفتح',
     49: 'الحجرات',   50: 'ق',          51: 'الذاريات',   52: 'الطور',
     53: 'النجم',     54: 'القمر',      55: 'الرحمن',     56: 'الواقعة',
     57: 'الحديد',    58: 'المجادلة',   59: 'الحشر',      60: 'الممتحنة',
     61: 'الصف',      62: 'الجمعة',     63: 'المنافقون',  64: 'التغابن',
     65: 'الطلاق',    66: 'التحريم',    67: 'الملك',      68: 'القلم',
     69: 'الحاقة',    70: 'المعارج',    71: 'نوح',        72: 'الجن',
     73: 'المزمل',    74: 'المدثر',     75: 'القيامة',    76: 'الإنسان',
     77: 'المرسلات',  78: 'النبأ',      79: 'النازعات',   80: 'عبس',
     81: 'التكوير',   82: 'الانفطار',   83: 'المطففين',   84: 'الانشقاق',
     85: 'البروج',    86: 'الطارق',     87: 'الأعلى',     88: 'الغاشية',
     89: 'الفجر',     90: 'البلد',      91: 'الشمس',      92: 'الليل',
     93: 'الضحى',     94: 'الشرح',      95: 'التين',      96: 'العلق',
     97: 'القدر',     98: 'البينة',     99: 'الزلزلة',   100: 'العاديات',
    101: 'القارعة',  102: 'التكاثر',   103: 'العصر',     104: 'الهمزة',
    105: 'الفيل',    106: 'قريش',      107: 'الماعون',   108: 'الكوثر',
    109: 'الكافرون', 110: 'النصر',     111: 'المسد',     112: 'الإخلاص',
    113: 'الفلق',    114: 'الناس',
    };
    return names[n] ?? 'القرآن الكريم';
  }

  void _showJuzNavigation() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Jump to Juz',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final juz = index + 1;
                  return ElevatedButton(
                    onPressed: () {
                      final page = _mushafService.getPageForJuz(juz);
                      _pageController.jumpToPage(page - 1);
                      Navigator.pop(context);
                    },
                    child: Text('$juz'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPageJump() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Jump to Page'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Page Number (1-604)',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= 604) {
                _pageController.jumpToPage(page - 1);
                Navigator.pop(context);
              }
            },
            child: const Text('Go'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
