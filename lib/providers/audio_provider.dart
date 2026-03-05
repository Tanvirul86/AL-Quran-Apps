import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../utils/constants.dart';

enum RepeatMode { none, one, all }

/// Provider for audio playback state with advanced features
class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isPlaying = false;
  bool _isLoading = false;
  int? _currentSurah;
  int? _currentAyah;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = AppConstants.defaultPlaybackSpeed;
  RepeatMode _repeatMode = RepeatMode.none;
  bool _autoPlayNext = false;
  int? _totalAyahsInCurrentSurah;

  AudioPlayer get audioPlayer => _audioPlayer;
  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  int? get currentSurah => _currentSurah;
  int? get currentAyah => _currentAyah;
  Duration get position => _position;
  Duration get duration => _duration;
  double get playbackSpeed => _playbackSpeed;
  RepeatMode get repeatMode => _repeatMode;
  bool get autoPlayNext => _autoPlayNext;

  AudioProvider() {
    _initAudioPlayer();
  }

  void _initAudioPlayer() {
    // Set audio session for background playback
    _audioPlayer.setAudioSource(
      AudioSource.uri(Uri.parse(''), tag: const MediaItem(
        id: 'quran_audio',
        title: 'Quran Recitation',
        artist: 'Al-Quran Pro',
      )),
    ).catchError((error) {
      // Initial setup - will be replaced when actual audio plays
    });
    
    _audioPlayer.positionStream.listen((position) {
      _position = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      _duration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
      _isPlaying = state.playing;
      _isLoading = state.processingState == ProcessingState.loading;
      
      // Handle playback completion
      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }
      
      notifyListeners();
    });
  }

  /// Handle what happens when audio playback completes
  void _handlePlaybackCompleted() {
    if (_repeatMode == RepeatMode.one && _currentSurah != null && _currentAyah != null) {
      // Repeat current ayah
      playAyah(_currentSurah!, _currentAyah!);
    } else if ((_repeatMode == RepeatMode.all || _autoPlayNext) && 
               _currentSurah != null && 
               _currentAyah != null) {
      // Play next ayah
      playNextAyah();
    }
  }

  /// Play ayah audio
  Future<void> playAyah(int surahNumber, int ayahNumber, {int? totalAyahs}) async {
    try {
      _currentSurah = surahNumber;
      _currentAyah = ayahNumber;
      if (totalAyahs != null) {
        _totalAyahsInCurrentSurah = totalAyahs;
      }
      
      // Use the audio URL helper from constants
      final String audioUrl = AppConstants.getAudioUrl(surahNumber, ayahNumber);
      
      // Set audio source with media item for background playback
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.parse(audioUrl),
          tag: MediaItem(
            id: 'surah_${surahNumber}_ayah_$ayahNumber',
            title: 'Surah $surahNumber - Ayah $ayahNumber',
            artist: 'Quran Recitation',
            album: 'Al-Quran Pro',
            artUri: Uri.parse('https://via.placeholder.com/200'),
          ),
        ),
      );
      await _audioPlayer.setSpeed(_playbackSpeed);
      await _audioPlayer.play();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      // You can add fallback audio sources here if needed
    }
  }

  /// Pause playback
  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  /// Resume playback
  Future<void> resume() async {
    await _audioPlayer.play();
  }

  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSurah = null;
    _currentAyah = null;
    notifyListeners();
  }

  /// Seek to position
  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  /// Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(
      AppConstants.minPlaybackSpeed,
      AppConstants.maxPlaybackSpeed,
    );
    await _audioPlayer.setSpeed(_playbackSpeed);
    notifyListeners();
  }

  /// Repeat current ayah
  Future<void> repeatAyah() async {
    if (_currentSurah != null && _currentAyah != null) {
      await playAyah(_currentSurah!, _currentAyah!);
    }
  }

  /// Play next ayah in sequence
  Future<void> playNextAyah() async {
    if (_currentSurah != null && _currentAyah != null && _totalAyahsInCurrentSurah != null) {
      if (_currentAyah! < _totalAyahsInCurrentSurah!) {
        await playAyah(_currentSurah!, _currentAyah! + 1, totalAyahs: _totalAyahsInCurrentSurah);
      } else {
        // End of surah - stop or move to next surah based on settings
        await stop();
      }
    }
  }

  /// Play previous ayah in sequence
  Future<void> playPreviousAyah() async {
    if (_currentSurah != null && _currentAyah != null && _currentAyah! > 1) {
      await playAyah(_currentSurah!, _currentAyah! - 1, totalAyahs: _totalAyahsInCurrentSurah);
    }
  }

  /// Toggle repeat mode (none -> one -> all)
  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.none:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.none;
        break;
    }
    notifyListeners();
  }

  /// Set repeat mode
  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    notifyListeners();
  }

  /// Toggle auto-play next
  void toggleAutoPlayNext() {
    _autoPlayNext = !_autoPlayNext;
    notifyListeners();
  }

  /// Get available playback speeds
  List<double> get availableSpeeds => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  /// Initialize audio service for background playback
  Future<void> initializeAudioService() async {
    try {
      await AudioService.init(
        builder: () => AudioPlayerHandler(_audioPlayer),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.quran.app.audio',
          androidNotificationChannelName: 'Quran Audio Playback',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: true,
        ),
      );
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Audio handler for background playback
class AudioPlayerHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  AudioPlayerHandler(this._player) {
    _player.playbackEventStream.listen((event) {
      playbackState.add(playbackState.value.copyWith(
        playing: _player.playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
      ));
    });
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> setSpeed(double speed) => _player.setSpeed(speed);
}
