import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

/// Enhanced Search Screen - Fuzzy search, topic search, root word search
class EnhancedSearchScreen extends StatefulWidget {
  const EnhancedSearchScreen({super.key});

  @override
  State<EnhancedSearchScreen> createState() => _EnhancedSearchScreenState();
}

class _EnhancedSearchScreenState extends State<EnhancedSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedLanguage = 'en';
  bool _caseSensitive = false;
  bool _wholeWord = false;
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, _) => Scaffold(
        appBar: AppBar(
          title: const Text('Advanced Search'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.text_fields), text: 'Text'),
              Tab(icon: Icon(Icons.topic), text: 'Topic'),
              Tab(icon: Icon(Icons.language), text: 'Root Word'),
              Tab(icon: Icon(Icons.bookmark), text: 'Reference'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search Bar
            _buildSearchBar(),

            // Advanced Options
            _buildAdvancedOptions(),

            // Results
            Expanded(
              child: _isSearching
                  ? const Center(child: CircularProgressIndicator())
                  : _buildResults(settings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _getSearchHint(),
          prefixIcon: const Icon(Icons.search),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchResults = []);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: _performSearch,
              ),
            ],
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        onSubmitted: (_) => _performSearch(),
      ),
    );
  }

  Widget _buildAdvancedOptions() {
    return ExpansionTile(
      title: const Text('Advanced Options'),
      leading: const Icon(Icons.tune),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Type
              const Text('Search In:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Arabic'),
                    selected: _selectedLanguage == 'ar',
                    onSelected: (_) => setState(() => _selectedLanguage = 'ar'),
                  ),
                  ChoiceChip(
                    label: const Text('Translation'),
                    selected: _selectedLanguage == 'en',
                    onSelected: (_) => setState(() => _selectedLanguage = 'en'),
                  ),
                  ChoiceChip(
                    label: const Text('Transliteration'),
                    selected: _selectedLanguage == 'trans',
                    onSelected: (_) => setState(() => _selectedLanguage = 'trans'),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Options
              CheckboxListTile(
                title: const Text('Case Sensitive'),
                value: _caseSensitive,
                onChanged: (value) => setState(() => _caseSensitive = value ?? false),
                dense: true,
              ),
              CheckboxListTile(
                title: const Text('Whole Word Only'),
                value: _wholeWord,
                onChanged: (value) => setState(() => _wholeWord = value ?? false),
                dense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResults(SettingsProvider settings) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isEmpty
                  ? 'Enter search terms above'
                  : 'No results found',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildResultCard(result, settings);
      },
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result, SettingsProvider settings) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToAyah(result),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Reference
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${result['surah']}:${result['ayah']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    result['surahName'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Arabic Text
              if (result['arabicText'] != null)
                Text(
                  result['arabicText'],
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: settings.arabicFontFamily,
                    height: 2,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),

              const SizedBox(height: 8),

              // Translation
              if (result['translation'] != null)
                Text(
                  result['translation'],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),

              // Match Info
              if (result['matchType'] != null) ...[
                const SizedBox(height: 8),
                Chip(
                  label: Text(
                    result['matchType'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: Colors.blue.shade100,
                  padding: EdgeInsets.zero,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getSearchHint() {
    switch (_tabController.index) {
      case 0:
        return 'Search by text...';
      case 1:
        return 'Search by topic (e.g., prayer, paradise)...';
      case 2:
        return 'Search by root word...';
      case 3:
        return 'Enter reference (e.g., 2:255)...';
      default:
        return 'Search...';
    }
  }

  Future<void> _performSearch() async {
    if (_searchController.text.trim().isEmpty) return;

    setState(() => _isSearching = true);

    // Simulate search delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Sample results - In real implementation, use search service
    final sampleResults = [
      {
        'surah': 1,
        'ayah': 1,
        'surahName': 'Al-Fatihah',
        'arabicText': 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        'translation': 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
        'matchType': 'Text Match',
      },
      {
        'surah': 2,
        'ayah': 255,
        'surahName': 'Al-Baqarah',
        'arabicText': 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        'translation': 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence.',
        'matchType': 'Exact Match',
      },
    ];

    setState(() {
      _searchResults = sampleResults;
      _isSearching = false;
    });
  }

  void _navigateToAyah(Map<String, dynamic> result) {
    Navigator.pop(context, {
      'surah': result['surah'],
      'ayah': result['ayah'],
    });
  }
}
