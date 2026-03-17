import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/translation_service.dart';
import '../models/translation_source.dart';

class TranslationsSelectorScreen extends StatefulWidget {
  final VoidCallback? onApplyAndGoReading;

  const TranslationsSelectorScreen({
    super.key,
    this.onApplyAndGoReading,
  });

  @override
  State<TranslationsSelectorScreen> createState() => _TranslationsSelectorScreenState();
}

class _TranslationsSelectorScreenState extends State<TranslationsSelectorScreen> {
  final TranslationService _translationService = TranslationService();
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<TranslationSource>> _groupedTranslations = {};
  bool _isLoading = true;
  String? _selectedLanguage;
  String _searchQuery = '';

  // Popular language ordering
  static const _popularOrder = [
    'en', 'ar', 'ur', 'bn', 'hi', 'id', 'tr', 'fr', 'de', 'es',
    'ru', 'fa', 'ms', 'zh', 'ja', 'ko', 'ta', 'pt', 'nl', 'it',
    'sw', 'th',
  ];

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadTranslations() async {
    final translations = await _translationService.getAvailableTranslations();
    final grouped = <String, List<TranslationSource>>{};
    for (final trans in translations) {
      grouped.putIfAbsent(trans.language, () => []);
      grouped[trans.language]!.add(trans);
    }
    if (mounted) {
      setState(() {
        _groupedTranslations = grouped;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedLanguage == null
              ? 'Translation'
              : _translationService.getLanguageDisplayName(_selectedLanguage!),
        ),
        leading: _selectedLanguage != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedLanguage = null),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedLanguage == null
              ? _buildLanguageView()
              : _buildTranslationList(_selectedLanguage!),
      bottomNavigationBar: _buildApplyBar(),
    );
  }

  Widget _buildApplyBar() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final hasSelection = settings.selectedTranslations.isNotEmpty;
        return SafeArea(
          top: false,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasSelection
                    ? () {
                        if (widget.onApplyAndGoReading != null) {
                          widget.onApplyAndGoReading!.call();
                          return;
                        }

                        if (Navigator.of(context).canPop()) {
                          Navigator.of(context).pop();
                        }
                      }
                    : null,
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(
                  hasSelection
                      ? 'Apply & Back to Reading'
                      : 'Select at least one translation',
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Language picker (root level) ────────────────────────────────────────────

  Widget _buildLanguageView() {
    return Column(
      children: [
        _buildSelectionBanner(),
        _buildSearchBar(),
        Expanded(child: _buildLanguageList()),
      ],
    );
  }

  Widget _buildSelectionBanner() {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        final selections = settings.selectedTranslations;
        final scheme = Theme.of(context).colorScheme;

        if (selections.isEmpty) {
          return Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 18, color: scheme.onSurfaceVariant),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'No translation selected. Choose a language below.',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 16, color: scheme.onPrimaryContainer),
                  const SizedBox(width: 6),
                  Text(
                    'Active translation${selections.length > 1 ? 's' : ''} (tap × to remove)',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: scheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              ...selections.map((sel) {
                final langTranslations = _groupedTranslations[sel['language']] ?? [];
                final source = langTranslations.firstWhere(
                  (t) => t.id == sel['id'],
                  orElse: () => TranslationSource(
                    id: sel['id']!,
                    name: sel['id']!,
                    language: sel['language']!,
                    translator: '',
                    downloadUrl: '',
                    fileSize: 0,
                  ),
                );
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 13,
                        backgroundColor: _langColor(sel['language']!),
                        child: Text(
                          sel['language']!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          source.name,
                          style: TextStyle(
                            color: scheme.onPrimaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 16, color: scheme.onPrimaryContainer),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => context
                            .read<SettingsProvider>()
                            .selectTranslation(sel['id']!, sel['language']!),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search languages…',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
        onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
      ),
    );
  }

  Widget _buildLanguageList() {
    var languages = _groupedTranslations.keys.toList();
    languages.sort((a, b) {
      final ai = _popularOrder.indexOf(a);
      final bi = _popularOrder.indexOf(b);
      if (ai >= 0 && bi >= 0) return ai.compareTo(bi);
      if (ai >= 0) return -1;
      if (bi >= 0) return 1;
      return a.compareTo(b);
    });

    if (_searchQuery.isNotEmpty) {
      languages = languages.where((lang) {
        final display = _translationService.getLanguageDisplayName(lang).toLowerCase();
        return display.contains(_searchQuery) || lang.contains(_searchQuery);
      }).toList();
    }

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        if (languages.isEmpty) {
          return const Center(child: Text('No languages found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: languages.length,
          itemBuilder: (context, index) {
            final lang = languages[index];
            final translations = _groupedTranslations[lang]!;
            final displayName = _translationService.getLanguageDisplayName(lang);
            final isActive = settings.isTranslationSelected(lang);
            final color = _langColor(lang);

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              elevation: isActive ? 2 : 1,
              color: isActive
                  ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45)
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isActive ? Theme.of(context).primaryColor : color,
                  child: Text(
                    lang.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text('${translations.length} translator${translations.length != 1 ? 's' : ''}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      Icon(Icons.check_circle, color: Theme.of(context).primaryColor, size: 20),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right),
                  ],
                ),
                onTap: () => setState(() => _selectedLanguage = lang),
              ),
            );
          },
        );
      },
    );
  }

  // ── Translator picker ───────────────────────────────────────────────────────

  Widget _buildTranslationList(String language) {
    final translations = _groupedTranslations[language] ?? [];

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: translations.length,
          itemBuilder: (context, index) {
            final trans = translations[index];
            final isSelected = settings.selectedTranslations.any((t) => t['id'] == trans.id);

            return Card(
              margin: const EdgeInsets.only(bottom: 10),
              elevation: isSelected ? 2 : 1,
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45)
                  : null,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isSelected ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  child: Icon(
                    isSelected ? Icons.check : Icons.translate,
                    color: isSelected ? Colors.white : Colors.grey.shade700,
                    size: 20,
                  ),
                ),
                title: Text(
                  trans.name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
                subtitle: Text(trans.translator),
                trailing: isSelected
                    ? Icon(Icons.radio_button_checked, color: Theme.of(context).primaryColor)
                    : const Icon(Icons.radio_button_unchecked),
                onTap: () {
                  final wasSelected =
                      settings.selectedTranslations.any((t) => t['id'] == trans.id);
                  settings.selectTranslation(trans.id, language);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(wasSelected
                          ? '${trans.name} removed'
                          : '✓ ${trans.name} selected'),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
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

  // ── Helpers ─────────────────────────────────────────────────────────────────

  Color _langColor(String code) {
    const map = {
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
      'ta': Colors.deepOrangeAccent,
      'pt': Colors.lightBlue,
      'nl': Colors.orangeAccent,
      'it': Colors.greenAccent,
      'sw': Colors.lightGreen,
      'th': Colors.yellow,
    };
    return map[code] ?? Colors.grey;
  }
}
