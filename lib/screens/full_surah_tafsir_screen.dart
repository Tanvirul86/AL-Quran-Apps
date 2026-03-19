import 'package:flutter/material.dart';
import '../models/ayah.dart';
import '../models/tafsir_source.dart';
import '../services/tafsir_service.dart';
import '../theme/app_theme.dart';

class FullSurahTafsirScreen extends StatefulWidget {
  final String surahName;
  final List<Ayah> ayahs;

  const FullSurahTafsirScreen({
    super.key,
    required this.surahName,
    required this.ayahs,
  });

  @override
  State<FullSurahTafsirScreen> createState() => _FullSurahTafsirScreenState();
}

class _FullSurahTafsirScreenState extends State<FullSurahTafsirScreen> {
  final TafsirService _tafsirService = TafsirService();
  final Map<String, Future<String>> _tafsirFutures = {};

  String _selectedLanguage = 'en';
  TafsirSource? _selectedSource;
  Map<String, List<TafsirSource>> _tafsirsByLanguage = {};

  final List<String> _languageOrder = ['en', 'bn', 'ar', 'ur', 'ru', 'ku'];

  @override
  void initState() {
    super.initState();
    _tafsirsByLanguage = _tafsirService.getTafsirsByLanguage();
    _selectedSource = _tafsirsByLanguage[_selectedLanguage]?.first;
  }

  Future<String> _loadTafsir(Ayah ayah) {
    final sourceId = _selectedSource?.id ?? '169';
    final key = '${ayah.surahNumber}:${ayah.ayahNumber}:$_selectedLanguage:$sourceId';

    return _tafsirFutures.putIfAbsent(key, () async {
      final tafsirs = await _tafsirService.getTafsirForAyah(
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        tafsirSourceId: sourceId,
        language: _selectedLanguage,
      );

      if (tafsirs.isEmpty) {
        return 'Tafsir not available for this ayah yet.';
      }
      return tafsirs.first.text;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final languageCodes = _tafsirsByLanguage.keys.toList()
      ..sort((a, b) {
        final ai = _languageOrder.indexOf(a);
        final bi = _languageOrder.indexOf(b);
        if (ai == -1 && bi == -1) return a.compareTo(b);
        if (ai == -1) return 1;
        if (bi == -1) return -1;
        return ai.compareTo(bi);
      });
    final currentSources = _tafsirsByLanguage[_selectedLanguage] ?? [];

    if (_selectedSource == null && currentSources.isNotEmpty) {
      _selectedSource = currentSources.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Full Tafsir - ${widget.surahName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 38,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: languageCodes.length,
                    itemBuilder: (context, index) {
                      final code = languageCodes[index];
                      final selected = _selectedLanguage == code;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: selected,
                          label: Text(_tafsirService.getLanguageDisplayName(code)),
                          onSelected: (_) {
                            setState(() {
                              _selectedLanguage = code;
                              final nextSources = _tafsirsByLanguage[code] ?? [];
                              _selectedSource = nextSources.isNotEmpty ? nextSources.first : null;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _selectedSource?.id,
                  decoration: InputDecoration(
                    labelText: 'Tafsir Source',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    isDense: true,
                  ),
                  items: currentSources
                      .map(
                        (s) => DropdownMenuItem<String>(
                          value: s.id,
                          child: Text(s.name, overflow: TextOverflow.ellipsis),
                        ),
                      )
                      .toList(),
                  onChanged: currentSources.isEmpty
                      ? null
                      : (value) {
                          setState(() {
                            _selectedSource = currentSources.firstWhere(
                              (s) => s.id == value,
                              orElse: () => currentSources.first,
                            );
                          });
                        },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: widget.ayahs.length,
              itemBuilder: (context, index) {
                final ayah = widget.ayahs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: primary.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${ayah.surahNumber}:${ayah.ayahNumber}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: primary,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          ayah.uthmaniText ?? ayah.arabicText,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: AppTheme.arabicFont,
                            fontSize: 24,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FutureBuilder<String>(
                          future: _loadTafsir(ayah),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 8),
                                child: LinearProgressIndicator(minHeight: 2),
                              );
                            }

                            return Text(
                              snapshot.data ?? 'Tafsir not available for this ayah yet.',
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.55,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
