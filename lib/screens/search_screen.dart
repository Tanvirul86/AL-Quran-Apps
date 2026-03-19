import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'ayah_reading_screen.dart';
import '../models/ayah.dart';
import '../providers/ai_provider.dart';
import '../providers/quran_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/spiritual_background.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Ayah> _searchResults = [];
  bool _isSearching = false;
  bool _isSemanticMode = false;

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    if (_isSemanticMode) {
      final aiProvider = context.read<AIProvider>();
      await aiProvider.semanticSearch(query);
      setState(() {
        _searchResults = aiProvider.searchResults;
        _isSearching = false;
      });
    } else {
      final quranProvider = context.read<QuranProvider>();
      final results = await quranProvider.searchAyahs(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Spiritual Search'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SpiritualBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Search bar and mode toggle
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 16),
                        decoration: InputDecoration(
                          hintText: _isSemanticMode 
                              ? 'Search by feeling (e.g., "I feel sad")'
                              : 'Search by surah, ayah, or keywords...',
                          prefixIcon: Icon(Icons.psychology, color: _isSemanticMode ? Colors.purple : null),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _performSearch('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                        onChanged: _performSearch,
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                _isSemanticMode ? Icons.auto_awesome : Icons.search,
                                size: 18,
                                color: _isSemanticMode ? Colors.purple : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _isSemanticMode ? 'AI Semantic Mode' : 'Standard Mode',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _isSemanticMode ? Colors.purple : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isSemanticMode,
                            onChanged: (val) {
                              setState(() => _isSemanticMode = val);
                              if (_searchController.text.isNotEmpty) {
                                _performSearch(_searchController.text);
                              }
                            },
                            activeColor: Colors.purple,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn().slideY(begin: -0.1),
              
              // Search results
              Expanded(
                child: _isSearching
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _isSemanticMode ? Icons.psychology : Icons.search_off,
                                  size: 64,
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _searchController.text.isEmpty
                                      ? (_isSemanticMode ? 'Try "I feel anxious" or "need guidance"' : 'Start typing to search...')
                                      : 'Deep within, no results were found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey.withOpacity(0.6),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              final ayah = _searchResults[index];
                              return _SearchResultItem(
                                ayah: ayah,
                                searchQuery: _searchController.text,
                                onTap: () async {
                                  final quranProvider = context.read<QuranProvider>();
                                  final surah = quranProvider.getSurah(ayah.surahNumber);
                                  if (surah != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AyahReadingScreen(surah: surah),
                                      ),
                                    );
                                  }
                                },
                              ).animate().fadeIn(delay: (50 * (index % 10)).ms).slideX(begin: 0.05);
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchResultItem extends StatelessWidget {
  final Ayah ayah;
  final String searchQuery;
  final VoidCallback onTap;

  const _SearchResultItem({
    required this.ayah,
    required this.searchQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '${ayah.surahNumber}:${ayah.ayahNumber}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        title: Text(
          ayah.arabicText,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 20, height: 1.5),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Text(
              ayah.englishTranslation,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}
