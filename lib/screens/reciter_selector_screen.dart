import 'package:flutter/material.dart';
import '../services/enhanced_reciter_service.dart';
import '../models/reciter.dart';
import 'package:provider/provider.dart';

/// Reciter Selector - Choose from 15 world-renowned reciters
class ReciterSelectorScreen extends StatefulWidget {
  const ReciterSelectorScreen({super.key});

  @override
  State<ReciterSelectorScreen> createState() => _ReciterSelectorScreenState();
}

class _ReciterSelectorScreenState extends State<ReciterSelectorScreen> {
  late EnhancedReciterService _reciterService;
  String _selectedReciterId = '';
  Map<String, double> _downloadProgress = {};
  Set<String> _downloadingReciters = {};

  @override
  void initState() {
    super.initState();
    _reciterService = EnhancedReciterService();
    _loadSavedReciter();
  }

  Future<void> _loadSavedReciter() async {
    final reciter = await _reciterService.getSelectedReciter();
    if (mounted) {
      setState(() {
        _selectedReciterId = reciter.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Reciter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showDownloadOptionsDialog(),
            tooltip: 'Download Options',
          ),
        ],
      ),
      body: FutureBuilder<List<Reciter>>(
        future: _reciterService.getAllReciters(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reciters = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reciters.length,
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              return _buildReciterCard(reciter);
            },
          );
        },
      ),
    );
  }

  Widget _buildReciterCard(Reciter reciter) {
    final isSelected = _selectedReciterId == reciter.id;
    final isDownloading = _downloadingReciters.contains(reciter.id);
    final downloadProgress = _downloadProgress[reciter.id] ?? 0.0;

    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.green : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _selectReciter(reciter),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Reciter Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: reciter.imageUrl != null
                        ? NetworkImage(reciter.imageUrl!)
                        : null,
                    child: reciter.imageUrl == null
                        ? Text(
                            reciter.name[0],
                            style: const TextStyle(fontSize: 24),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),

                  // Name and Country
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reciter.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.flag, size: 16),
                            const SizedBox(width: 4),
                            Text(reciter.country),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Selected Check
                  if (isSelected)
                    const Icon(Icons.check_circle, color: Colors.green, size: 32),
                ],
              ),

              // Bio
              if (reciter.bio != null) ...[
                const SizedBox(height: 12),
                Text(
                  reciter.bio!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],

              const SizedBox(height: 12),

              // Recitation Style Chips
              Wrap(
                spacing: 8,
                children: reciter.recitationStyles.map((style) {
                  return Chip(
                    label: Text(style.name.toUpperCase()),
                    labelStyle: const TextStyle(fontSize: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),

              // Download Progress
              if (isDownloading) ...[
                LinearProgressIndicator(value: downloadProgress),
                const SizedBox(height: 8),
                Text('Downloading... ${(downloadProgress * 100).toInt()}%'),
              ],

              // Action Buttons
              Row(
                children: [
                  // Preview Button
                  OutlinedButton.icon(
                    onPressed: () => _previewReciter(reciter),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Preview'),
                  ),
                  const SizedBox(width: 8),

                  // Download Button
                  if (reciter.isDownloadable)
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isDownloading
                            ? null
                            : () => _showDownloadDialog(reciter),
                        icon: Icon(
                          _isReciterDownloaded(reciter.id)
                              ? Icons.download_done
                              : Icons.download,
                          size: 18,
                        ),
                        label: Text(
                          _isReciterDownloaded(reciter.id)
                              ? 'Downloaded'
                              : 'Download',
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectReciter(Reciter reciter) async {
    await _reciterService.saveSelectedReciter(reciter.id);
    setState(() {
      _selectedReciterId = reciter.id;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${reciter.name} selected'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _previewReciter(Reciter reciter) async {
    // Play Al-Fatihah (Surah 1) as preview
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Playing preview from ${reciter.name}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    // TODO: Implement audio preview using just_audio
  }

  void _showDownloadDialog(Reciter reciter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Download ${reciter.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What would you like to download?'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Full Quran'),
              subtitle: const Text('~1.5 GB'),
              onTap: () {
                Navigator.pop(context);
                _downloadFullQuran(reciter);
              },
            ),
            ListTile(
              leading: const Icon(Icons.article),
              title: const Text('Select Surahs'),
              onTap: () {
                Navigator.pop(context);
                _showSurahSelector(reciter);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadFullQuran(Reciter reciter) async {
    setState(() {
      _downloadingReciters.add(reciter.id);
      _downloadProgress[reciter.id] = 0.0;
    });

    try {
      await _reciterService.downloadFullQuran(
        reciter.id,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress[reciter.id] = progress;
            });
          }
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reciter.name} downloaded successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _downloadingReciters.remove(reciter.id);
        _downloadProgress.remove(reciter.id);
      });
    }
  }

  void _showSurahSelector(Reciter reciter) {
    // Show grid of 114 surahs to select and download
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Surahs'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 6,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: 114,
            itemBuilder: (context, index) {
              final surahNumber = index + 1;
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _downloadSurah(reciter, surahNumber);
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '$surahNumber',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadSurah(Reciter reciter, int surahNumber) async {
    setState(() {
      _downloadingReciters.add('${reciter.id}_$surahNumber');
    });

    try {
      await _reciterService.downloadSurahAudio(reciter.id, surahNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Surah $surahNumber downloaded'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _downloadingReciters.remove('${reciter.id}_$surahNumber');
      });
    }
  }

  void _showDownloadOptionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Download Manager'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download_for_offline),
              title: const Text('Download All Reciters'),
              subtitle: const Text('~22.5 GB total'),
              onTap: () {
                Navigator.pop(context);
                _downloadAllReciters();
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Clear All Downloads'),
              onTap: () {
                Navigator.pop(context);
                _clearAllDownloads();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAllReciters() async {
    final reciters = await _reciterService.getAllReciters();
    
    for (final reciter in reciters) {
      if (reciter.isDownloadable) {
        await _downloadFullQuran(reciter);
      }
    }
  }

  Future<void> _clearAllDownloads() async {
    // TODO: Implement clearing all downloads
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Clearing downloads...')),
    );
  }

  bool _isReciterDownloaded(String reciterId) {
    // TODO: Check if reciter files exist locally
    return false;
  }
}
