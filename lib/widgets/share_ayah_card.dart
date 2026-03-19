import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/ayah.dart';
import '../theme/app_theme.dart';

/// Shows the share ayah bottom sheet and triggers image share
Future<void> shareAyahAsCard(BuildContext context, Ayah ayah) async {
  await showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ShareAyahSheet(ayah: ayah),
  );
}

class _ShareAyahSheet extends StatefulWidget {
  final Ayah ayah;
  const _ShareAyahSheet({required this.ayah});

  @override
  State<_ShareAyahSheet> createState() => _ShareAyahSheetState();
}

class _ShareAyahSheetState extends State<_ShareAyahSheet> {
  final _repaintKey = GlobalKey();
  bool _sharing = false;
  int _selectedTheme = 0;

  static const _themes = [
    {'label': 'Forest', 'bg1': Color(0xFF1B5E20), 'bg2': Color(0xFF2E7D32), 'text': Colors.white},
    {'label': 'Night', 'bg1': Color(0xFF0D1B2A), 'bg2': Color(0xFF1B263B), 'text': Colors.white},
    {'label': 'Gold', 'bg1': Color(0xFF7B3F00), 'bg2': Color(0xFFC47F1A), 'text': Colors.white},
    {'label': 'Pearl', 'bg1': Color(0xFFF5F0E8), 'bg2': Color(0xFFEDE8D8), 'text': Color(0xFF1A1A2E)},
  ];

  Future<void> _share() async {
    setState(() => _sharing = true);
    try {
      final boundary = _repaintKey.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/ayah_share.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text:
            'Surah ${widget.ayah.surahNumber}:${widget.ayah.ayahNumber} | Al-Quran Pro',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not share: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_selectedTheme];
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF1E1E1E) : Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade400,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Share Ayah',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          // Card preview (repaint boundary for capture)
          RepaintBoundary(
            key: _repaintKey,
            child: _AyahShareCard(ayah: widget.ayah, theme: theme),
          ),

          const SizedBox(height: 16),

          // Theme selector
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: _themes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final t = _themes[i];
                final sel = _selectedTheme == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedTheme = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [t['bg1'] as Color, t['bg2'] as Color],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: sel ? Colors.amber : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        t['label'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Share button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sharing ? null : _share,
              icon: _sharing
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.share_rounded),
              label: Text(_sharing ? 'Creating...' : 'Share as Image'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AyahShareCard extends StatelessWidget {
  final Ayah ayah;
  final Map<String, Object> theme;

  const _AyahShareCard({required this.ayah, required this.theme});

  @override
  Widget build(BuildContext context) {
    final bg1 = theme['bg1'] as Color;
    final bg2 = theme['bg2'] as Color;
    final textColor = theme['text'] as Color;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bg1, bg2],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Arabic calligraphy style header
          Text(
            'القرآن الكريم',
            style: TextStyle(
              color: textColor.withOpacity(0.5),
              fontSize: 13,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          // Arabic ayah
          Text(
            ayah.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.arabicFont,
              fontSize: 26,
              color: textColor,
              height: 2.2,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          // Divider
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: textColor.withOpacity(0.2),
          ),
          const SizedBox(height: 14),
          // Translation
          if (ayah.banglaTranslation.isNotEmpty)
            Text(
              ayah.banglaTranslation,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: textColor.withOpacity(0.85),
                height: 1.7,
                fontFamily: AppTheme.banglaFont,
              ),
            ),
          const SizedBox(height: 14),
          // Surah reference
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: textColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Surah ${ayah.surahNumber} : Ayah ${ayah.ayahNumber}',
              style: TextStyle(
                fontSize: 11,
                color: textColor.withOpacity(0.7),
                fontWeight: FontWeight.w500,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Al-Quran Pro',
            style: TextStyle(
              fontSize: 10,
              color: textColor.withOpacity(0.4),
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
