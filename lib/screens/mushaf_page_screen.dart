import 'package:flutter/material.dart';
import '../models/mushaf_page.dart';
import '../services/mushaf_service.dart';
import '../theme/app_theme.dart';

/// Mushaf Mode - 604-page Madani Mushaf view
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
    print('Loading page $pageNumber');
    setState(() => _loading = true);
    final pageData = await _mushafService.getPage(pageNumber);
    print('Loaded page ${pageData.pageNumber} with ${pageData.lines.length} lines');
    if (pageData.lines.isNotEmpty) {
      print('First line: ${pageData.lines[0].arabicText}');
      print('Last line: ${pageData.lines[pageData.lines.length - 1].arabicText}');
    }
    setState(() {
      _currentPageData = pageData;
      _loading = false;
    });
    await _mushafService.saveLastReadPage(pageNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5DC), // Authentic Mushaf background
      appBar: AppBar(
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        title: Column(
          children: [
            const Text('المصحف الشريف', style: TextStyle(fontFamily: 'Scheherazade', fontSize: 18)),
            Text(
              'صفحة $_currentPage من 604 • الجزء ${_mushafService.getJuzForPage(_currentPage)}',
              style: const TextStyle(fontSize: 12, fontFamily: 'Scheherazade'),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            onPressed: _showJuzNavigation,
            tooltip: 'Jump to Juz',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showPageJump,
            tooltip: 'Jump to Page',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() => _currentPage = index + 1);
                _loadPage(index + 1);
              },
              itemCount: 604,
              itemBuilder: (context, index) {
                return _buildAuthenticMushafPage();
              },
            ),
      bottomNavigationBar: _buildBottomControls(),
    );
  }

  Widget _buildAuthenticMushafPage() {
    if (_currentPageData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      margin: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7), // Authentic cream background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF8B4513), width: 3),
        ),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFDAA520), width: 2),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFFFF8E7),
                  const Color(0xFFFAF0E6),
                ],
              ),
            ),
            child: Column(
              children: [
                // Surah header if this is the start of a new surah
                if (_isStartOfSurah())
                  _buildSurahHeader(),
                
                // Bismillah if page starts with new Surah
                if (_mushafService.pageHasBismillah(_currentPage))
                  _buildAuthenticBismillah(),
                
                const SizedBox(height: 16),
                
                // Main content area
                Expanded(
                  child: _buildPageContent(),
                ),
                
                const SizedBox(height: 16),
                
                // Page number at bottom
                _buildAuthenticPageFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isStartOfSurah() {
    // Check if this page starts a new surah
    return _currentPageData!.startAyahNumber == 1;
  }

  Widget _buildSurahHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2E8B57), Color(0xFF228B22)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFDAA520), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${_currentPageData!.startSurahNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            _getSurahName(_currentPageData!.startSurahNumber),
            style: const TextStyle(
              fontFamily: 'Scheherazade',
              fontSize: 20,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF228B22),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                '${_currentPageData!.startSurahNumber}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSurahName(int surahNumber) {
    final surahNames = {
      1: 'سُورَةُ الْفَاتِحَةِ',
      2: 'سُورَةُ البَقَرَةِ',
      3: 'سُورَةُ آلِ عِمْرَان',
      4: 'سُورَةُ النِّسَاء',
      5: 'سُورَةُ الْمَائِدَة',
    };
    return surahNames[surahNumber] ?? 'سُورَة';
  }

  Widget _buildMushafPage() {
    if (_currentPageData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Page header with Juz info
          _buildPageHeader(),
          
          const SizedBox(height: 16),
          
          // Mushaf content (15 lines) - Fixed height without scrolling
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Bismillah if page starts with new Surah
                  if (_mushafService.pageHasBismillah(_currentPage))
                    _buildBismillah(),
                  
                  // Page lines (typically 15 lines) - Evenly distributed
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _currentPageData!.lines.map((line) => _buildLine(line)).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Page number at bottom
          _buildPageFooter(),
        ],
      ),
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B4513),
            const Color(0xFFDAA520),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'جُزْء ${_mushafService.getJuzForPage(_currentPage)}',
        style: const TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAuthenticBismillah() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.8),
            const Color(0xFFFFF8E7).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFFDAA520), width: 1),
      ),
      child: Center(
        child: Text(
          'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِیمِ',
          style: const TextStyle(
            fontFamily: 'Scheherazade',
            fontSize: 28,
            height: 2.0,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B4513),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    if (_currentPageData == null || _currentPageData!.lines.isEmpty) {
      return const Center(
        child: Text(
          'Loading page content...',
          style: TextStyle(fontSize: 18, fontFamily: 'Scheherazade'),
        ),
      );
    }
    
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _currentPageData!.lines.length,
      itemBuilder: (context, index) {
        return _buildAuthenticLine(_currentPageData!.lines[index], index);
      },
    );
  }

  Widget _buildAuthenticLine(PageLine line, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Text(
        line.arabicText,
        style: const TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 18,
          height: 1.6,
          letterSpacing: 0.4,
          color: Color(0xFF2F4F4F),
        ),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        maxLines: 1,
        overflow: TextOverflow.visible,
      ),
    );
  }

  Widget _buildVerseMarker(int ayahNumber) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4682B4).withOpacity(0.8),
            const Color(0xFF5F9EA0).withOpacity(0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFDAA520), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Center(
          child: Text(
            '$ayahNumber',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
              fontFamily: 'Scheherazade',
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthenticPageFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B4513).withOpacity(0.8),
            const Color(0xFFDAA520).withOpacity(0.6),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF8B4513), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$_currentPage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              fontFamily: 'Scheherazade',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBismillah() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
        style: const TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 26,
          height: 2.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildLine(PageLine line) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        line.arabicText,
        style: const TextStyle(
          fontFamily: 'Scheherazade',
          fontSize: 26, // Increased for better readability
          height: 2.2,  // Better line spacing for Mushaf
          letterSpacing: 0.5,
        ),
        textAlign: TextAlign.justify,
        textDirection: TextDirection.rtl,
        maxLines: null, // Allow text wrapping
      ),
    );
  }

  Widget _buildPageFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B4513),
            const Color(0xFFDAA520),
          ],
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Decorative pattern
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '◆',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Page number with ornate styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF8B4513), width: 2),
            ),
            child: Text(
              '$_currentPage',
              style: const TextStyle(
                fontFamily: 'Scheherazade',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF8B4513),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Decorative pattern
          Container(
            width: 40,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                '◆',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.first_page),
            onPressed: _currentPage > 1
                ? () {
                    _pageController.jumpToPage(0);
                  }
                : null,
            tooltip: 'First Page',
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right), // RTL, so right is previous
            onPressed: _currentPage > 1
                ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            tooltip: 'Previous Page',
          ),
          Text(
            '$_currentPage / 604',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_left), // RTL, so left is next
            onPressed: _currentPage < 604
                ? () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
            tooltip: 'Next Page',
          ),
          IconButton(
            icon: const Icon(Icons.last_page),
            onPressed: _currentPage < 604
                ? () {
                    _pageController.jumpToPage(603);
                  }
                : null,
            tooltip: 'Last Page',
          ),
        ],
      ),
    );
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
