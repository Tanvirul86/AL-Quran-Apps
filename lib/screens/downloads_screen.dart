import 'package:flutter/material.dart';
import '../models/tafsir_source.dart';
import '../models/translation_source.dart';
import '../models/reciter.dart';
import '../services/tafsir_service.dart';
import '../services/translation_service.dart';
import '../services/enhanced_reciter_service.dart';
import '../services/download_manager_service.dart';

/// Downloads management screen for tafsir, translations, and audio
class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  final TafsirService _tafsirService = TafsirService();
  final TranslationService _translationService = TranslationService();
  final EnhancedReciterService _reciterService = EnhancedReciterService();
  final DownloadManagerService _downloadManager = DownloadManagerService();

  List<TafsirSource> _tafsirs = [];
  List<TranslationSource> _translations = [];
  List<Reciter> _reciters = [];
  
  bool _loading = true;
  int _totalStorageUsed = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    
    final tafsirs = await _tafsirService.getAvailableTafsirs();
    final translations = await _translationService.getAvailableTranslations();
    final reciters = await _reciterService.getAllReciters();
    final storage = await _downloadManager.getTotalStorageUsed();
    
    setState(() {
      _tafsirs = tafsirs;
      _translations = translations;
      _reciters = reciters;
      _totalStorageUsed = storage;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloads'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tafsir', icon: Icon(Icons.book)),
            Tab(text: 'Translations', icon: Icon(Icons.translate)),
            Tab(text: 'Reciters', icon: Icon(Icons.mic)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Storage Used', style: TextStyle(fontSize: 10)),
                Text(
                  _formatBytes(_totalStorageUsed),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTafsirTab(),
                _buildTranslationsTab(),
                _buildRecitersTab(),
              ],
            ),
    );
  }

  Widget _buildTafsirTab() {
    return ListView.builder(
      itemCount: _tafsirs.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final tafsir = _tafsirs[index];
        return _TafsirDownloadCard(
          tafsir: tafsir,
          tafsirService: _tafsirService,
          onDownloadComplete: () => _loadData(),
        );
      },
    );
  }

  Widget _buildTranslationsTab() {
    // Group by language
    final languageGroups = <String, List<TranslationSource>>{};
    for (final trans in _translations) {
      languageGroups.putIfAbsent(trans.language, () => []).add(trans);
    }

    return ListView.builder(
      itemCount: languageGroups.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final language = languageGroups.keys.elementAt(index);
        final translations = languageGroups[language]!;
        
        return ExpansionTile(
          title: Text(_getLanguageName(language)),
          subtitle: Text('${translations.length} translations available'),
          children: translations.map((trans) => _TranslationDownloadCard(
            translation: trans,
            translationService: _translationService,
            onDownloadComplete: () => _loadData(),
          )).toList(),
        );
      },
    );
  }

  Widget _buildRecitersTab() {
    return ListView.builder(
      itemCount: _reciters.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final reciter = _reciters[index];
        return _ReciterDownloadCard(
          reciter: reciter,
          reciterService: _reciterService,
          onDownloadComplete: () => _loadData(),
        );
      },
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String _getLanguageName(String code) {
    const names = {
      'en': 'English',
      'bn': 'বাংলা (Bangla)',
      'hi': 'हिंदी (Hindi)',
      'ur': 'اردو (Urdu)',
      'ar': 'العربية (Arabic)',
      'id': 'Indonesian',
      'tr': 'Turkish',
      'fr': 'French',
    };
    return names[code] ?? code.toUpperCase();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Individual card widgets
class _TafsirDownloadCard extends StatefulWidget {
  final TafsirSource tafsir;
  final TafsirService tafsirService;
  final VoidCallback onDownloadComplete;

  const _TafsirDownloadCard({
    required this.tafsir,
    required this.tafsirService,
    required this.onDownloadComplete,
  });

  @override
  State<_TafsirDownloadCard> createState() => _TafsirDownloadCardState();
}

class _TafsirDownloadCardState extends State<_TafsirDownloadCard> {
  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final downloaded = await widget.tafsirService.isTafsirDownloaded(widget.tafsir.id);
    setState(() => _isDownloaded = downloaded);
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    final success = await widget.tafsirService.downloadTafsirSource(widget.tafsir);
    setState(() {
      _isDownloading = false;
      _isDownloaded = success;
    });
    if (success) widget.onDownloadComplete();
  }

  Future<void> _delete() async {
    final success = await widget.tafsirService.deleteTafsir(widget.tafsir.id);
    if (success) {
      setState(() => _isDownloaded = false);
      widget.onDownloadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.book, color: Colors.teal),
        title: Text(widget.tafsir.displayName),
        subtitle: Text('${widget.tafsir.fileSizeFormatted} • ${widget.tafsir.language.toUpperCase()}'),
        trailing: _isDownloading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _isDownloaded
                ? IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: _delete,
                  )
                : IconButton(
                    icon: const Icon(Icons.download, color: Colors.green),
                    onPressed: _download,
                  ),
      ),
    );
  }
}

class _TranslationDownloadCard extends StatefulWidget {
  final TranslationSource translation;
  final TranslationService translationService;
  final VoidCallback onDownloadComplete;

  const _TranslationDownloadCard({
    required this.translation,
    required this.translationService,
    required this.onDownloadComplete,
  });

  @override
  State<_TranslationDownloadCard> createState() => _TranslationDownloadCardState();
}

class _TranslationDownloadCardState extends State<_TranslationDownloadCard> {
  bool _isDownloading = false;
  bool _isDownloaded = false;

  @override
  void initState() {
    super.initState();
    _checkDownloadStatus();
  }

  Future<void> _checkDownloadStatus() async {
    final downloaded = await widget.translationService
        .isTranslationDownloaded(widget.translation.id);
    setState(() => _isDownloaded = downloaded);
  }

  Future<void> _download() async {
    setState(() => _isDownloading = true);
    final success = await widget.translationService
        .downloadTranslation(widget.translation);
    setState(() {
      _isDownloading = false;
      _isDownloaded = success;
    });
    if (success) widget.onDownloadComplete();
  }

  Future<void> _delete() async {
    final success = await widget.translationService
        .deleteTranslation(widget.translation.id);
    if (success) {
      setState(() => _isDownloaded = false);
      widget.onDownloadComplete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.translate, color: Colors.blue),
      title: Text(widget.translation.name),
      subtitle: Text(widget.translation.translator),
      trailing: _isDownloading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : _isDownloaded
              ? IconButton(
                  icon: const Icon(Icons.check_circle, color: Colors.green),
                  onPressed: _delete,
                )
              : IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _download,
                ),
    );
  }
}

class _ReciterDownloadCard extends StatelessWidget {
  final Reciter reciter;
  final EnhancedReciterService reciterService;
  final VoidCallback onDownloadComplete;

  const _ReciterDownloadCard({
    required this.reciter,
    required this.reciterService,
    required this.onDownloadComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        leading: const Icon(Icons.mic, color: Colors.purple),
        title: Text(reciter.name),
        subtitle: Text('${reciter.nameArabic} • ${reciter.style}'),
        children: [
          ListTile(
            title: Text(reciter.bio ?? 'Renowned Quranic reciter'),
            subtitle: Text('Country: ${reciter.country ?? "N/A"}'),
          ),
          ButtonBar(
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  // Download full Quran
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading full Quran...')),
                  );
                  await reciterService.downloadFullQuran(reciter.id);
                  onDownloadComplete();
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Full Quran'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
