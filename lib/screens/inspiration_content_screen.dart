import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/inspiration_models.dart';
import '../theme/app_theme.dart';

class InspirationContentScreen extends StatefulWidget {
  final InspirationCategory category;

  const InspirationContentScreen({
    super.key,
    required this.category,
  });

  @override
  State<InspirationContentScreen> createState() => _InspirationContentScreenState();
}

class _InspirationContentScreenState extends State<InspirationContentScreen> {
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
            onPressed: () => _shareCurrentContent(),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.white),
            tooltip: 'Select Languages',
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'language_selection',
                child: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setMenuState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Show Languages',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('Arabic'),
                          value: _showArabic,
                          onChanged: (bool? value) {
                            setState(() {
                              _showArabic = value ?? true;
                            });
                            setMenuState(() {});
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('English'),
                          value: _showEnglish,
                          onChanged: (bool? value) {
                            setState(() {
                              _showEnglish = value ?? true;
                            });
                            setMenuState(() {});
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        CheckboxListTile(
                          title: const Text('Bengali'),
                          value: _showBengali,
                          onChanged: (bool? value) {
                            setState(() {
                              _showBengali = value ?? true;
                            });
                            setMenuState(() {});
                          },
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.forestBackground,
              AppTheme.forestSurface,
            ],
          ),
        ),
        child: Column(
          children: [
            // Content indicator
            if (widget.category.contents.length > 1)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.category.contents.length,
                    (index) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex
                            ? AppTheme.accentGold
                            : AppTheme.primaryGreen.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

            // Content pages
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.category.contents.length,
                itemBuilder: (context, index) {
                  final content = widget.category.contents[index];
                  return _buildContentPage(content);
                },
              ),
            ),

            // Navigation buttons
            if (widget.category.contents.length > 1)
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavButton(
                      icon: Icons.arrow_back_ios,
                      label: 'Previous',
                      onTap: _currentIndex > 0 ? _previousContent : null,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentIndex + 1} of ${widget.category.contents.length}',
                        style: TextStyle(
                          color: AppTheme.darkGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _buildNavButton(
                      icon: Icons.arrow_forward_ios,
                      label: 'Next',
                      onTap: _currentIndex < widget.category.contents.length - 1
                          ? _nextContent
                          : null,
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPage(InspirationContent content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Source badge
          Container(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: content.type == 'verse' ? AppTheme.accentGold : AppTheme.primaryGreen,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                content.type == 'verse' ? 'Quran' : 'Hadith',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Arabic text
          if (_showArabic)
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Arabic (العربية)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content.textAr,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 22,
                        fontFamily: AppTheme.arabicFont,
                        color: AppTheme.darkGreen,
                        height: 1.8,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (content.transliteration != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        content.transliteration!,
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: AppTheme.primaryGreen,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

          if (_showArabic) const SizedBox(height: 16),

          // English text
          if (_showEnglish)
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'English',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content.textEn,
                      style: TextStyle(
                        fontSize: 16,
                        color: AppTheme.darkGreen,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_showEnglish) const SizedBox(height: 16),

          // Bengali text
          if (_showBengali)
            Card(
              elevation: 2,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Bengali (বাংলা)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      content.textBn,
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: AppTheme.banglaFont,
                        color: AppTheme.darkGreen,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (_showBengali) const SizedBox(height: 16),

          // Reference and actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryGreen.withOpacity(0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  content.reference,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkGreen,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(
                      icon: Icons.copy,
                      label: 'Copy',
                      onTap: () => _copyContent(content),
                    ),
                    _buildActionButton(
                      icon: Icons.share,
                      label: 'Share',
                      onTap: () => _shareContent(content),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    final isEnabled = onTap != null;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled ? AppTheme.primaryGreen : AppTheme.primaryGreen.withOpacity(0.3),
          borderRadius: BorderRadius.circular(24),
          boxShadow: isEnabled ? [AppTheme.softShadow] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon == Icons.arrow_back_ios) ...[
              Icon(
                icon,
                size: 16,
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (icon == Icons.arrow_forward_ios) ...[
              const SizedBox(width: 4),
              Icon(
                icon,
                size: 16,
                color: isEnabled ? Colors.white : Colors.white.withOpacity(0.5),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppTheme.islamicGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [AppTheme.softShadow],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _previousContent() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextContent() {
    if (_currentIndex < widget.category.contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _copyContent(InspirationContent content) {
    final textToCopy = '''
${content.textAr}

${content.textEn}

${content.textBn}

${content.reference}''';
    
    Clipboard.setData(ClipboardData(text: textToCopy));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Content copied to clipboard'),
        backgroundColor: AppTheme.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _shareContent(InspirationContent content) {
    final textToShare = '''${content.textAr}

${content.textEn}

${content.textBn}

📖 ${content.reference}

Shared from Quran App 🕌''';
    
    Share.share(
      textToShare,
      subject: 'Islamic Inspiration - ${widget.category.nameEn}',
    );
  }

  void _shareCurrentContent() {
    if (widget.category.contents.isNotEmpty) {
      _shareContent(widget.category.contents[_currentIndex]);
    }
  }
}