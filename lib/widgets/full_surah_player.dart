import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reciter.dart';
import '../services/enhanced_reciter_service.dart';

/// Full Surah Player with World-Known Qaris
class FullSurahPlayer extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const FullSurahPlayer({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<FullSurahPlayer> createState() => _FullSurahPlayerState();
}

class _FullSurahPlayerState extends State<FullSurahPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final EnhancedReciterService _reciterService = EnhancedReciterService();
  
  List<Reciter> _reciters = [];
  Reciter? _selectedReciter;
  bool _isLoading = true;
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReciters();
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() => _position = position);
      }
    });

    _audioPlayer.durationStream.listen((duration) {
      if (mounted) {
        setState(() => _duration = duration ?? Duration.zero);
      }
    });

    _audioPlayer.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
          _isBuffering = state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering;
        });
      }
    });
  }

  Future<void> _loadReciters() async {
    try {
      // Clear old cached reciters that may have incorrect URLs
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reciters');
      
      final reciters = await _reciterService.getAllReciters();
      final lastReciterId = prefs.getString('last_reciter_id');
      
      setState(() {
        _reciters = reciters;
        _selectedReciter = reciters.firstWhere(
          (r) => r.id == lastReciterId,
          orElse: () => reciters.first,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load reciters';
        _isLoading = false;
      });
    }
  }

  Future<void> _playFullSurah() async {
    if (_selectedReciter == null) return;
    
    try {
      if (mounted) {
        setState(() {
          _error = null;
          _isBuffering = true;
        });
      }
      
      // Get the surah audio URL
      final surahPadded = widget.surahNumber.toString().padLeft(3, '0');
      final audioUrl = _selectedReciter!.audioUrlPattern.replaceAll('{surah}', surahPadded);
      
      debugPrint('Playing full surah from: $audioUrl');
      
      try {
        await _audioPlayer.setUrl(audioUrl);
        await _audioPlayer.play();
        
        // Save last used reciter
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('last_reciter_id', _selectedReciter!.id);
      } catch (primaryError) {
        debugPrint('Primary URL failed: $primaryError');
        
        // Try alternative URL patterns
        final alternativeUrls = _getAlternativeUrls(surahPadded);
        bool played = false;
        
        for (final altUrl in alternativeUrls) {
          try {
            debugPrint('Trying alternative URL: $altUrl');
            await _audioPlayer.setUrl(altUrl);
            await _audioPlayer.play();
            played = true;
            break;
          } catch (e) {
            debugPrint('Alternative URL failed: $e');
          }
        }
        
        if (!played) {
          throw primaryError;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Audio unavailable for this reciter. Try another.';
          _isBuffering = false;
        });
      }
      debugPrint('Audio error: $e');
    }
  }
  
  /// Get alternative URLs to try if primary fails
  List<String> _getAlternativeUrls(String surahPadded) {
    // Fallback to most reliable reciters
    return [
      'https://server8.mp3quran.net/afs/$surahPadded.mp3', // Mishary Alafasy
      'https://server7.mp3quran.net/basit/$surahPadded.mp3', // Abdul Basit
      'https://server11.mp3quran.net/sds/$surahPadded.mp3', // Sudais
      'https://server12.mp3quran.net/maher/$surahPadded.mp3', // Maher Al Muaiqly
    ];
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_duration == Duration.zero) {
        await _playFullSurah();
      } else {
        await _audioPlayer.play();
      }
    }
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.headphones,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Listen Full Surah',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.surahName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _audioPlayer.stop();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
          
          const Divider(height: 24),
          
          // Reciter selection
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Qari',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Reciter>(
                        value: _selectedReciter,
                        isExpanded: true,
                        hint: const Text('Choose a reciter'),
                        items: _reciters.map((reciter) {
                          return DropdownMenuItem<Reciter>(
                            value: reciter,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                  child: Text(
                                    reciter.name[0],
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        reciter.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        '${reciter.style} • ${reciter.country ?? ""}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (reciter) async {
                          final wasPlaying = _isPlaying;
                          
                          // Stop current audio
                          await _audioPlayer.stop();
                          
                          if (mounted) {
                            setState(() {
                              _selectedReciter = reciter;
                              _position = Duration.zero;
                              _duration = Duration.zero;
                              _error = null;
                            });
                          }
                          
                          // If was playing, start playing with new reciter
                          if (wasPlaying && mounted) {
                            await _playFullSurah();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Selected reciter info
            if (_selectedReciter != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Text(
                        _selectedReciter!.nameArabic.isNotEmpty 
                            ? _selectedReciter!.nameArabic[0] 
                            : _selectedReciter!.name[0],
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedReciter!.nameArabic,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _selectedReciter!.bio ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: 20),
            
            // Progress bar
            if (_duration != Duration.zero)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _position.inSeconds.toDouble().clamp(
                          0.0,
                          _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                        ),
                        min: 0,
                        max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                        activeColor: Theme.of(context).primaryColor,
                        inactiveColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        onChanged: (value) {
                          _seekTo(Duration(seconds: value.toInt()));
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_position),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            _formatDuration(_duration),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Error message
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Playback controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Rewind 10s
                IconButton(
                  icon: const Icon(Icons.replay_10),
                  iconSize: 32,
                  onPressed: () {
                    final newPosition = _position - const Duration(seconds: 10);
                    _seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
                  },
                ),
                
                const SizedBox(width: 16),
                
                // Play/Pause button
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: _isBuffering
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                    iconSize: 36,
                    onPressed: _isBuffering ? null : _togglePlayPause,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Forward 10s
                IconButton(
                  icon: const Icon(Icons.forward_10),
                  iconSize: 32,
                  onPressed: () {
                    final newPosition = _position + const Duration(seconds: 10);
                    _seekTo(newPosition > _duration ? _duration : newPosition);
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
          ],
        ],
      ),
    );
  }
}

/// Show full surah player as bottom sheet
void showFullSurahPlayer(BuildContext context, {
  required int surahNumber,
  required String surahName,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => FullSurahPlayer(
      surahNumber: surahNumber,
      surahName: surahName,
    ),
  );
}
