import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';

/// Compact mini audio player that slides up from bottom
class AudioMiniPlayer extends StatefulWidget {
  const AudioMiniPlayer({super.key});

  @override
  State<AudioMiniPlayer> createState() => _AudioMiniPlayerState();
}

class _AudioMiniPlayerState extends State<AudioMiniPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, SettingsProvider>(
      builder: (context, audioProvider, settingsProvider, _) {
        if (audioProvider.currentSurah == null) {
          return const SizedBox.shrink();
        }

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Container(
              height: _isExpanded ? 200 : 70,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Mini player bar
                  GestureDetector(
                    onTap: _toggleExpanded,
                    child: Container(
                      height: 70,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          // Play/Pause button
                          IconButton(
                            icon: Icon(
                              audioProvider.isPlaying
                                  ? Icons.pause_circle_filled
                                  : Icons.play_circle_filled,
                              color: Colors.white,
                              size: 40,
                            ),
                            onPressed: () {
                              if (audioProvider.isPlaying) {
                                audioProvider.pause();
                              } else {
                                audioProvider.resume();
                              }
                            },
                          ),
                          const SizedBox(width: 12),
                          
                          // Info
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Surah ${audioProvider.currentSurah}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Ayah ${audioProvider.currentAyah ?? 1}',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Expand icon
                          Icon(
                            _isExpanded
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Expanded controls
                  if (_isExpanded)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            // Progress slider
                            Row(
                              children: [
                                Text(
                                  _formatDuration(audioProvider.position),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Expanded(
                                  child: Slider(
                                    value: audioProvider.position.inMilliseconds
                                        .toDouble()
                                        .clamp(
                                          0.0,
                                          audioProvider.duration.inMilliseconds > 0
                                              ? audioProvider.duration.inMilliseconds.toDouble()
                                              : 1.0,
                                        ),
                                    min: 0,
                                    max: audioProvider.duration.inMilliseconds > 0
                                        ? audioProvider.duration.inMilliseconds
                                            .toDouble()
                                        : 1,
                                    onChanged: (value) {
                                      audioProvider.seek(
                                        Duration(milliseconds: value.toInt()),
                                      );
                                    },
                                    activeColor: Colors.white,
                                    inactiveColor: Colors.white24,
                                  ),
                                ),
                                Text(
                                  _formatDuration(audioProvider.duration),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Playback controls
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.skip_previous,
                                      color: Colors.white),
                                  iconSize: 32,
                                  onPressed: audioProvider.currentAyah != null &&
                                          audioProvider.currentAyah! > 1
                                      ? audioProvider.playPreviousAyah
                                      : null,
                                ),
                                IconButton(
                                  icon: Icon(
                                    _getRepeatIcon(audioProvider.repeatMode),
                                    color: audioProvider.repeatMode !=
                                            RepeatMode.none
                                        ? Colors.white
                                        : Colors.white54,
                                  ),
                                  iconSize: 28,
                                  onPressed: audioProvider.toggleRepeatMode,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.skip_next,
                                      color: Colors.white),
                                  iconSize: 32,
                                  onPressed: audioProvider.playNextAyah,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat;
      default:
        return Icons.repeat;
    }
  }
}
