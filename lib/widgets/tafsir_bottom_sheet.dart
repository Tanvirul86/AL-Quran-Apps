import 'package:flutter/material.dart';
import '../models/tafsir_source.dart';
import '../services/tafsir_service.dart';
import '../theme/app_theme.dart';

/// Bottom sheet widget for displaying Tafsir (commentary) for an ayah
class TafsirBottomSheet extends StatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final String arabicText;

  const TafsirBottomSheet({
    super.key,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arabicText,
  });

  @override
  State<TafsirBottomSheet> createState() => _TafsirBottomSheetState();
}

class _TafsirBottomSheetState extends State<TafsirBottomSheet> {
  late TafsirService _tafsirService;
  bool _isLoading = true;
  String? _tafsirText;
  String _selectedLanguage = 'en';
  TafsirSource? _selectedSource;
  Map<String, List<TafsirSource>> _tafsirsByLanguage = {};
  
  // Available languages
  final List<Map<String, String>> _languages = [
    {'code': 'en', 'name': 'English', 'native': 'English'},
    {'code': 'ar', 'name': 'Arabic', 'native': 'العربية'},
    {'code': 'ur', 'name': 'Urdu', 'native': 'اردو'},
    {'code': 'bn', 'name': 'Bengali', 'native': 'বাংলা'},
    {'code': 'ru', 'name': 'Russian', 'native': 'Русский'},
    {'code': 'ku', 'name': 'Kurdish', 'native': 'کوردی'},
  ];

  @override
  void initState() {
    super.initState();
    _tafsirService = TafsirService();
    _loadSources();
  }

  Future<void> _loadSources() async {
    _tafsirsByLanguage = _tafsirService.getTafsirsByLanguage();
    
    // Set default source (English Ibn Kathir)
    if (_tafsirsByLanguage['en']?.isNotEmpty == true) {
      _selectedSource = _tafsirsByLanguage['en']!.first;
    }
    
    await _loadTafsir();
  }

  Future<void> _loadTafsir() async {
    if (_selectedSource == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final tafsirs = await _tafsirService.getTafsirForAyah(
        surahNumber: widget.surahNumber,
        ayahNumber: widget.ayahNumber,
        tafsirSourceId: _selectedSource!.id,
        language: _selectedLanguage,
      );
      
      setState(() {
        _tafsirText = tafsirs.isNotEmpty ? tafsirs.first.text : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _tafsirText = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      color: Theme.of(context).primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tafsir',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Verse reference
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${widget.surahNumber}:${widget.ayahNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.arabicText.length > 50 
                              ? '${widget.arabicText.substring(0, 50)}...' 
                              : widget.arabicText,
                          style: AppTheme.arabicTextStyle(fontSize: 14),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Language selector
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final lang = _languages[index];
                final isSelected = _selectedLanguage == lang['code'];
                final hasContent = _tafsirsByLanguage[lang['code']]?.isNotEmpty == true;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      lang['native']!,
                      style: TextStyle(
                        color: isSelected ? Colors.white : (hasContent ? null : Colors.grey),
                        fontSize: 13,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: hasContent ? (selected) {
                      if (selected) {
                        setState(() {
                          _selectedLanguage = lang['code']!;
                          _selectedSource = _tafsirsByLanguage[_selectedLanguage]?.first;
                        });
                        _loadTafsir();
                      }
                    } : null,
                    backgroundColor: hasContent ? null : Colors.grey[200],
                    selectedColor: Theme.of(context).primaryColor,
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Tafsir source selector
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSourceSelector(),
          ),
          
          const Divider(height: 24),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTafsirContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSourceSelector() {
    final sources = _tafsirsByLanguage[_selectedLanguage] ?? [];
    
    if (sources.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Text(
              'No tafsir available for this language',
              style: TextStyle(color: Colors.orange[700]),
            ),
          ],
        ),
      );
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<TafsirSource>(
          value: _selectedSource,
          isExpanded: true,
          hint: const Text('Select Tafsir'),
          items: sources.map((source) {
            return DropdownMenuItem<TafsirSource>(
              value: source,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    source.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    source.author,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (source) {
            if (source != null) {
              setState(() => _selectedSource = source);
              _loadTafsir();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTafsirContent() {
    if (_tafsirText == null || _tafsirText!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Tafsir not available',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different tafsir source',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    // Determine text direction based on language
    final isRtl = ['ar', 'ur', 'ku'].contains(_selectedLanguage);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Source info
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedSource?.name ?? 'Tafsir',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Text(
                        _selectedSource?.author ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tafsir text
          SelectableText(
            _tafsirText!,
            textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
            textAlign: isRtl ? TextAlign.right : TextAlign.left,
            style: _getTextStyle(),
          ),
        ],
      ),
    );
  }
  
  TextStyle _getTextStyle() {
    switch (_selectedLanguage) {
      case 'ar':
        return AppTheme.arabicTextStyle(fontSize: 18, height: 2.0);
      case 'bn':
        return AppTheme.banglaTextStyle(fontSize: 16, height: 1.8);
      case 'ur':
        return const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 17,
          height: 2.0,
        );
      case 'ru':
        return const TextStyle(fontSize: 15, height: 1.7);
      case 'ku':
        return const TextStyle(
          fontFamily: 'NotoNaskhArabic',
          fontSize: 17,
          height: 2.0,
        );
      default:
        return AppTheme.englishTextStyle(fontSize: 15, height: 1.7);
    }
  }
}

/// Static method to show tafsir bottom sheet
void showTafsirBottomSheet(
  BuildContext context, {
  required int surahNumber,
  required int ayahNumber,
  required String arabicText,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TafsirBottomSheet(
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      arabicText: arabicText,
    ),
  );
}
