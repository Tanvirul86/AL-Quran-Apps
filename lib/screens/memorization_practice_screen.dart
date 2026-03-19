import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../widgets/glass_card.dart';
import '../widgets/spiritual_background.dart';
import 'package:flutter_animate/flutter_animate.dart';

class MemorizationPracticeScreen extends StatefulWidget {
  final int surahNumber;
  final int startAyah;
  final int endAyah;

  const MemorizationPracticeScreen({
    super.key,
    required this.surahNumber,
    required this.startAyah,
    required this.endAyah,
  });

  @override
  State<MemorizationPracticeScreen> createState() => _MemorizationPracticeScreenState();
}

class _MemorizationPracticeScreenState extends State<MemorizationPracticeScreen> {
  int _loopCount = 1;
  bool _waitForRecitation = false;
  int _currentAyahIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentAyahIndex = widget.startAyah;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Surah ${widget.surahNumber} Practice'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SpiritualBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                const Spacer(),
                // Display Current Ayah Number
                GlassCard(
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'Ayah $_currentAyahIndex',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: theme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn().scale(),
                      const SizedBox(height: 20),
                      Text(
                        'Practice Range: ${widget.startAyah} - ${widget.endAyah}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.primaryColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Control Panel
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildControlRow(
                        'Loop Times',
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => setState(() => _loopCount = (_loopCount > 1) ? _loopCount - 1 : 1),
                            ),
                            Text('$_loopCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => setState(() => _loopCount++),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 32),
                      _buildControlRow(
                        'Wait for Recitation',
                        Switch(
                          value: _waitForRecitation,
                          onChanged: (val) => setState(() => _waitForRecitation = val),
                          activeColor: theme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Play/Pause Button
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            if (audioProvider.isPlaying) {
                              audioProvider.pause();
                            } else {
                              audioProvider.startPractice(
                                loopCount: _loopCount,
                                wait: _waitForRecitation,
                              );
                              audioProvider.playAyah(
                                widget.surahNumber,
                                _currentAyahIndex,
                                totalAyahs: widget.endAyah,
                              );
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlRow(String label, Widget control) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        control,
      ],
    );
  }
}
