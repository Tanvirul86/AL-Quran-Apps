import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/dua_models.dart';
import '../theme/app_theme.dart';

class DuaContentScreen extends StatefulWidget {
  final DuaCategory category;

  const DuaContentScreen({
    super.key,
    required this.category,
  });

  @override
  State<DuaContentScreen> createState() => _DuaContentScreenState();
}

class _DuaContentScreenState extends State<DuaContentScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showArabic = true;
  bool _showEnglish = true;
  bool _showBengali = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.forestBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.forestPrimary,
        elevation: 0,
        title: Row(
          children: [
            Text(
              widget.category.iconPath,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.category.nameEn,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () => _shareCurrentDua(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: 'Select Languages',
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'language_selection',
                child: StatefulBuilder(
                  builder: (context, setState) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CheckboxListTile(
                        title: const Text('Arabic'),
                        value: _showArabic,
                        onChanged: (bool? value) {
                          setState(() {
                            _showArabic = value ?? true;
                          });
                          this.setState(() {});
                        },
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                      CheckboxListTile(
                        title: const Text('English'),
                        value: _showEnglish,
                        onChanged: (bool? value) {
                          setState(() {
                            _showEnglish = value ?? true;
                          });
                          this.setState(() {});
                        },
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                      CheckboxListTile(
                        title: const Text('Bengali'),
                        value: _showBengali,
                        onChanged: (bool? value) {
                          setState(() {
                            _showBengali = value ?? true;
                          });
                          this.setState(() {});
                        },
                        dense: true,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppTheme.forestSurface,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentIndex + 1} of ${widget.category.duas.length}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  width: 120,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: (_currentIndex + 1) / widget.category.duas.length,
                    alignment: Alignment.centerLeft,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: widget.category.duas.length,
              itemBuilder: (context, index) {
                return _buildDuaCard(widget.category.duas[index]);
              },
            ),
          ),

          // Navigation controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: _currentIndex > 0 
                    ? () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                    : null,
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: _currentIndex > 0 ? AppTheme.primaryGreen : AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                ),
                Row(
                  children: List.generate(
                    widget.category.duas.length.clamp(0, 5),
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: index == _currentIndex 
                          ? AppTheme.primaryGreen 
                          : AppTheme.primaryGreen.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _currentIndex < widget.category.duas.length - 1 
                    ? () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      )
                    : null,
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    color: _currentIndex < widget.category.duas.length - 1 
                      ? AppTheme.primaryGreen 
                      : AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDuaCard(Dua dua) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title section
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      dua.type.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _copyDua(dua),
                    icon: const Icon(Icons.copy, color: AppTheme.primaryGreen),
                    tooltip: 'Copy Dua',
                  ),
                ],
              ),
              
              const SizedBox(height: 16),

              // Title
              if (_showEnglish) ...[
                Text(
                  dua.titleEn,
                  style: const TextStyle(
                    color: AppTheme.darkGreen,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              if (_showBengali) ...[
                Text(
                  dua.titleBn,
                  style: const TextStyle(
                    color: AppTheme.primaryGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Arabic text
              if (_showArabic) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    dua.textAr,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: AppTheme.darkGreen,
                      fontSize: 22,
                      height: 1.8,
                      letterSpacing: 0.5,
                      fontFamily: AppTheme.arabicFont,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Transliteration
              if (dua.transliteration != null && _showEnglish) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    dua.transliteration!,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // English translation
              if (_showEnglish) ...[
                const Text(
                  'Translation:',
                  style: TextStyle(
                    color: AppTheme.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.textEn,
                  style: const TextStyle(
                    color: AppTheme.darkGreen,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Bengali translation
              if (_showBengali) ...[
                const Text(
                  'বাংলা অর্থ:',
                  style: TextStyle(
                    color: AppTheme.darkGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  dua.textBn,
                  style: const TextStyle(
                    color: AppTheme.darkGreen,
                    fontSize: 16,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Reference and occasion
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          dua.source == 'Quran' ? Icons.book : Icons.format_quote,
                          color: AppTheme.primaryGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${dua.source}: ${dua.reference}',
                          style: const TextStyle(
                            color: AppTheme.darkGreen,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (dua.occasion != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            color: AppTheme.primaryGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'When: ${dua.occasion}',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _shareCurrentDua() {
    final dua = widget.category.duas[_currentIndex];
    final shareText = '''
${dua.titleEn}

Arabic: ${dua.textAr}

Translation: ${dua.textEn}

Reference: ${dua.source} - ${dua.reference}

${dua.occasion != null ? 'When: ${dua.occasion}' : ''}

Shared from Al-Quran Pro
''';
    Share.share(shareText);
  }

  void _copyDua(Dua dua) {
    final copyText = '''${dua.titleEn}

Arabic: ${dua.textAr}

Translation: ${dua.textEn}

Reference: ${dua.source} - ${dua.reference}''';

    Clipboard.setData(ClipboardData(text: copyText));
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dua copied to clipboard'),
        backgroundColor: AppTheme.forestPrimary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}