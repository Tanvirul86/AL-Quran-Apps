import 'package:flutter/material.dart' hide RepeatMode;
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/settings_provider.dart';

class AudioControlsWidget extends StatelessWidget {
  final int? totalAyahs;

  const AudioControlsWidget({super.key, this.totalAyahs});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AudioProvider, SettingsProvider>(
      builder: (context, audio, settings, _) {
        if (audio.currentSurah == null) return const SizedBox.shrink();

        final primary = Theme.of(context).primaryColor;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                primary.withOpacity(isDark ? 0.97 : 1.0),
                Color.lerp(primary, isDark ? Colors.black : Colors.white, 0.18)!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: primary.withOpacity(0.45),
                blurRadius: 14,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Slim progress bar at top
                _ProgressBar(audio: audio, primary: Colors.white),

                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Row(
                    children: [
                      // Now-playing info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _reciterLabel(audio),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Surah ${audio.currentSurah}  •  Ayah ${audio.currentAyah}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Repeat toggle
                      _PlayerIconButton(
                        icon: _repeatIcon(audio.repeatMode),
                        isActive: audio.repeatMode != RepeatMode.none,
                        onTap: audio.toggleRepeatMode,
                        size: 22,
                      ),

                      const SizedBox(width: 4),

                      // Previous
                      _PlayerIconButton(
                        icon: Icons.skip_previous_rounded,
                        onTap: (audio.currentAyah != null && audio.currentAyah! > 1)
                            ? audio.playPreviousAyah
                            : null,
                        size: 28,
                      ),

                      const SizedBox(width: 4),

                      // Play / Pause — prominent center button
                      GestureDetector(
                        onTap: () => audio.isPlaying ? audio.pause() : audio.resume(),
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: audio.isLoading
                              ? Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: primary,
                                  ),
                                )
                              : Icon(
                                  audio.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: primary,
                                  size: 32,
                                ),
                        ),
                      ),

                      const SizedBox(width: 4),

                      // Next
                      _PlayerIconButton(
                        icon: Icons.skip_next_rounded,
                        onTap: (totalAyahs != null &&
                                audio.currentAyah != null &&
                                audio.currentAyah! < totalAyahs!)
                            ? audio.playNextAyah
                            : null,
                        size: 28,
                      ),

                      const SizedBox(width: 4),

                      // Speed picker
                      PopupMenuButton<double>(
                        tooltip: 'Playback speed',
                        color: Theme.of(context).cardColor,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${audio.playbackSpeed}×',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        itemBuilder: (context) => audio.availableSpeeds.map((s) {
                          return PopupMenuItem(
                            value: s,
                            child: Row(
                              children: [
                                Text('${s}×'),
                                const Spacer(),
                                if (audio.playbackSpeed == s)
                                  Icon(Icons.check, size: 18,
                                      color: Theme.of(context).primaryColor),
                              ],
                            ),
                          );
                        }).toList(),
                        onSelected: (s) {
                          settings.setPlaybackSpeed(s);
                          audio.setPlaybackSpeed(s);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _repeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.one:
        return Icons.repeat_one_rounded;
      case RepeatMode.all:
        return Icons.repeat_on_rounded;
      default:
        return Icons.repeat_rounded;
    }
  }

  String _reciterLabel(AudioProvider audio) {
    // Show short reciter name if available
    return 'Now Playing';
  }
}

// ─── Slim progress bar ──────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final AudioProvider audio;
  final Color primary;

  const _ProgressBar({required this.audio, required this.primary});

  @override
  Widget build(BuildContext context) {
    final total = audio.duration.inMilliseconds.toDouble();
    final pos = audio.position.inMilliseconds
        .toDouble()
        .clamp(0.0, total > 0 ? total : 1.0);

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 2.5,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        activeTrackColor: Colors.white,
        inactiveTrackColor: Colors.white.withOpacity(0.3),
        thumbColor: Colors.white,
        overlayColor: Colors.white.withOpacity(0.2),
      ),
      child: Slider(
        value: pos,
        min: 0,
        max: total > 0 ? total : 1,
        onChanged: (v) => audio.seek(Duration(milliseconds: v.toInt())),
      ),
    );
  }
}

// ─── Small icon button for player ──────────────────────────────────────────
class _PlayerIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final bool isActive;

  const _PlayerIconButton({
    required this.icon,
    required this.onTap,
    this.size = 24,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: size,
          color: onTap == null
              ? Colors.white.withOpacity(0.3)
              : isActive
                  ? Colors.amber.shade200
                  : Colors.white.withOpacity(0.9),
        ),
      ),
    );
  }
}

