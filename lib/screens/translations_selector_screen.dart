import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';
import '../models/translation_source.dart';

class TranslationsSelectorScreen extends StatefulWidget {
  const TranslationsSelectorScreen({super.key});

  @override
  State<TranslationsSelectorScreen> createState() => _TranslationsSelectorScreenState();
}

class _TranslationsSelectorScreenState extends State<TranslationsSelectorScreen> {
  final TranslationService _translationService = TranslationService();
  List<TranslationSource> _allTranslations = [];
  Map<String, List<TranslationSource>> _groupedTranslations = {};
  bool _isLoading = true;
  String? _selectedLanguage;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    final translations = await _translationService.getAvailableTranslations();
    
    // Group by language
    final grouped = <String, List<TranslationSource>>{};
    for (final trans in translations) {
      grouped.putIfAbsent(trans.language, () => []);
      grouped[trans.language]!.add(trans);
    }

    if (mounted) {
      setState(() {
        _allTranslations = translations;
        _groupedTranslations = grouped;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedLanguage == null 
            ? 'Select Language' 
            : _translationService.getLanguageDisplayName(_selectedLanguage!)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_selectedLanguage != null) {
              setState(() {
                _selectedLanguage = null;
              });
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedLanguage == null
              ? _buildLanguageList()
              : _buildTranslationList(_selectedLanguage!),
    );
  }

  Widget _buildLanguageList() {
    final languages = _groupedTranslations.keys.toList();
    
    // Sort with popular languages first
    final popularOrder = ['en', 'ar', 'ur', 'bn', 'hi', 'id', 'tr', 'fr', 'de', 'es', 'ru', 'fa'];
    languages.sort((a, b) {
      final aIndex = popularOrder.indexOf(a);
      final bIndex = popularOrder.indexOf(b);
      if (aIndex >= 0 && bIndex >= 0) return aIndex.compareTo(bIndex);
      if (aIndex >= 0) return -1;
      if (bIndex >= 0) return 1;
      return a.compareTo(b);
    });

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final language = languages[index];
            final translations = _groupedTranslations[language]!;
            final displayName = _translationService.getLanguageDisplayName(language);
            final isSelected = settings.selectedTranslationLanguage == language;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : _getLanguageColor(language),
                  child: Text(
                    language.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                title: Text(
                  displayName,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${translations.length} translator(s) available'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected)
                      Icon(Icons.check_circle, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () {
                  setState(() {
                    _selectedLanguage = language;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTranslationList(String language) {
    final translations = _groupedTranslations[language] ?? [];

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: translations.length,
          itemBuilder: (context, index) {
            final trans = translations[index];
            final isSelected = settings.selectedTranslationId == trans.id;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isSelected
                  ? Theme.of(context).primaryColor.withOpacity(0.1)
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300],
                  child: Icon(
                    isSelected ? Icons.check : Icons.translate,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
                title: Text(
                  trans.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(trans.translator),
                trailing: isSelected
                    ? Icon(Icons.radio_button_checked,
                        color: Theme.of(context).primaryColor)
                    : const Icon(Icons.radio_button_unchecked),
                onTap: () {
                  settings.setSelectedTranslation(trans.id, language);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selected: ${trans.name}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Color _getLanguageColor(String code) {
    final colors = {
      'en': Colors.blue,
      'ar': Colors.green,
      'ur': Colors.orange,
      'bn': Colors.teal,
      'hi': Colors.deepOrange,
      'id': Colors.red,
      'tr': Colors.purple,
      'fr': Colors.indigo,
      'de': Colors.amber,
      'es': Colors.pink,
      'ru': Colors.cyan,
      'fa': Colors.brown,
      'ms': Colors.lime,
      'zh': Colors.redAccent,
      'ja': Colors.deepPurple,
      'ko': Colors.blueGrey,
    };
    return colors[code] ?? Colors.grey;
  }
}
