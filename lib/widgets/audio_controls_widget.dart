import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';

class AudioControlsWidget extends StatelessWidget {
  final int? totalAyahs;
  
  const AudioControlsWidget({super.key, this.totalAyahs});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, SettingsProvider>(
      builder: (context, audioProvider, settingsProvider, _) {
        if (audioProvider.currentSurah == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Currently playing info
              Text(
                'Surah ${audioProvider.currentSurah} - Ayah ${audioProvider.currentAyah}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              // Progress bar
              Row(
                children: [
                  Text(
                    _formatDuration(audioProvider.position),
                    style: const TextStyle(fontSize: 12),
                  ),
                  Expanded(
                    child: Slider(
                      value: audioProvider.position.inMilliseconds.toDouble().clamp(
                        0.0,
                        audioProvider.duration.inMilliseconds > 0
                            ? audioProvider.duration.inMilliseconds.toDouble()
                            : 1.0,
                      ),
                      min: 0,
                      max: audioProvider.duration.inMilliseconds > 0
                          ? audioProvider.duration.inMilliseconds.toDouble()
                          : 1,
                      onChanged: (value) {
                        audioProvider.seek(
                          Duration(milliseconds: value.toInt()),
                        );
                      },
                    ),
                  ),
                  Text(
                    _formatDuration(audioProvider.duration),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Main controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Previous ayah
                  IconButton(
                    icon: const Icon(Icons.skip_previous),
                    onPressed: audioProvider.currentAyah != null && audioProvider.currentAyah! > 1
                        ? audioProvider.playPreviousAyah
                        : null,
                    tooltip: 'Previous ayah',
                  ),
                  // Repeat mode toggle
                  IconButton(
                    icon: Icon(_getRepeatIcon(audioProvider.repeatMode)),
                    color: audioProvider.repeatMode != RepeatMode.none 
                        ? Theme.of(context).primaryColor 
                        : null,
                    onPressed: audioProvider.toggleRepeatMode,
                    tooltip: _getRepeatTooltip(audioProvider.repeatMode),
                  ),
                  // Play/Pause button
                  audioProvider.isLoading
                      ? const CircularProgressIndicator()
                      : IconButton(
                          icon: Icon(
                            audioProvider.isPlaying
                                ? Icons.pause_circle_filled
                                : Icons.play_circle_filled,
                          ),
                          iconSize: 56,
                          onPressed: () {
                            if (audioProvider.isPlaying) {
                              audioProvider.pause();
                            } else {
                              audioProvider.resume();
                            }
                          },
                        ),
                  // Speed control
                  PopupMenuButton<double>(
                    icon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.speed),
                        const SizedBox(width: 4),
                        Text('${audioProvider.playbackSpeed}x'),
                      ],
                    ),
                    tooltip: 'Playback speed',
                    itemBuilder: (context) => audioProvider.availableSpeeds.map((speed) {
                      return PopupMenuItem(
                        value: speed,
                        child: Row(
                          children: [
                            Text('${speed}x'),
                            const Spacer(),
                            if (audioProvider.playbackSpeed == speed)
                              const Icon(Icons.check, size: 20),
                          ],
                        ),
                      );
                    }).toList(),
                    onSelected: (speed) {
                      settingsProvider.setPlaybackSpeed(speed);
                      audioProvider.setPlaybackSpeed(speed);
                    },
                  ),
                  // Next ayah
                  IconButton(
                    icon: const Icon(Icons.skip_next),
                    onPressed: totalAyahs != null && 
                              audioProvider.currentAyah != null && 
                              audioProvider.currentAyah! < totalAyahs!
                        ? audioProvider.playNextAyah
                        : null,
                    tooltip: 'Next ayah',
                  ),
                  // Stop button
                  IconButton(
                    icon: const Icon(Icons.stop),
                    onPressed: audioProvider.stop,
                    tooltip: 'Stop',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return Icons.repeat;
      case RepeatMode.one:
        return Icons.repeat_one;
      case RepeatMode.all:
        return Icons.repeat_on;
    }
  }

  String _getRepeatTooltip(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.none:
        return 'Repeat off';
      case RepeatMode.one:
        return 'Repeat one';
      case RepeatMode.all:
        return 'Repeat all';
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
