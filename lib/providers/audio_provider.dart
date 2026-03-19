import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

enum RepeatMode { none, one, all }
enum SleepTimerPreset { fifteenMin, thirtyMin, oneHour, endOfSurah }

/// Provider for audio playback state with advanced features
class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  static bool _audioServiceInitialized = false;
  static const String _defaultReciterId = 'mishary_alafasy';
  static const Map<String, String> _reciterBases = <String, String>{
    'mishary_alafasy': 'https://everyayah.com/data/Alafasy_128kbps/',
    'abdul_basit_murattal': 'https://everyayah.com/data/Abdul_Basit_Murattal_128kbps/',
    'mahmoud_hussary': 'https://everyayah.com/data/Husary_128kbps/',
    'saad_alghamdi': 'https://everyayah.com/data/Ghamadi_40kbps/',
    'abdurrahman_sudais': 'https://everyayah.com/data/Abdurrahmaan_As-Sudais_192kbps/',
  };

  bool _isPlaying = false;
  bool _isLoading = false;
  int? _currentSurah;
  int? _currentAyah;
  int? _playlistStartAyah;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = AppConstants.defaultPlaybackSpeed;
  RepeatMode _repeatMode = RepeatMode.none;
  bool _autoPlayNext = false;
  int? _totalAyahsInCurrentSurah;
  int _loopCount = 1;
  int _currentLoopIdx = 0;
  bool _waitForRecitation = false;
  bool _isPracticeMode = false;
  Timer? _sleepTimer;
  DateTime? _sleepTimerEnd;
  bool _stopAtEndOfSurah = false;
  String _selectedReciterId = _defaultReciterId;

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
  int get loopCount => _loopCount;
  bool get waitForRecitation => _waitForRecitation;
  bool get isSleepTimerActive => _sleepTimer?.isActive ?? false;
  String get selectedReciterId => _selectedReciterId;

  String get sleepTimerRemainingFormatted {
    if (_sleepTimerEnd == null) return '--:--';
    final remaining = _sleepTimerEnd!.difference(DateTime.now());
    if (remaining.isNegative) return '00:00';

    final hours = remaining.inHours;
    final minutes = remaining.inMinutes.remainder(60);
    final seconds = remaining.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  AudioProvider() {
    _initAudioPlayer();
    initializeAudioService();
  }

  void _initAudioPlayer() {
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

      if (state.processingState == ProcessingState.completed) {
        _handlePlaybackCompleted();
      }

      notifyListeners();
    });

    // Keep current ayah in sync with active index in concatenated playlist.
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && _playlistStartAyah != null) {
        _currentAyah = _playlistStartAyah! + index;
        notifyListeners();
      }
    });
  }

  Future<void> _loadSelectedReciter() async {
    final prefs = await SharedPreferences.getInstance();
    final rawId = prefs.getString('selected_reciter_id') ?? _defaultReciterId;

    const legacy = {
      'Abdul_Basit_Murattal': 'abdul_basit_murattal',
      'Mishary_Rashid': 'mishary_alafasy',
      'Saad_Al_Ghamdi': 'saad_alghamdi',
    };

    final normalized = legacy[rawId] ?? rawId;
    _selectedReciterId = _reciterBases.containsKey(normalized)
        ? normalized
        : _defaultReciterId;

    // Keep persisted value in sync to avoid misleading selection labels.
    if (_selectedReciterId != rawId) {
      await prefs.setString('selected_reciter_id', _selectedReciterId);
    }
  }

  String _getAudioUrlForCurrentReciter(int surahNumber, int ayahNumber) {
    final surah = surahNumber.toString().padLeft(3, '0');
    final ayah = ayahNumber.toString().padLeft(3, '0');

    final base = _reciterBases[_selectedReciterId] ?? AppConstants.audioBaseUrl;
    return '$base$surah$ayah.mp3';
  }

  /// Handle what happens when audio playback completes
  void _handlePlaybackCompleted() async {
    if (_stopAtEndOfSurah) {
      _stopAtEndOfSurah = false;
      await stop();
      return;
    }

    if (_isPracticeMode) {
      _currentLoopIdx++;
      if (_currentLoopIdx < _loopCount) {
        await playAyah(_currentSurah!, _currentAyah!, totalAyahs: _totalAyahsInCurrentSurah);
      } else {
        _currentLoopIdx = 0;
        if (_waitForRecitation) {
          final waitTime = Duration(milliseconds: (_duration.inMilliseconds * 1.2).toInt());
          _isLoading = true;
          notifyListeners();
          await Future.delayed(waitTime);
          _isLoading = false;
        }

        if (_currentAyah! < (_totalAyahsInCurrentSurah ?? _currentAyah!)) {
          await playAyah(_currentSurah!, _currentAyah! + 1, totalAyahs: _totalAyahsInCurrentSurah);
        } else {
          await stop();
        }
      }
      return;
    }

    if (_repeatMode == RepeatMode.one && _currentSurah != null && _currentAyah != null) {
      playAyah(_currentSurah!, _currentAyah!);
    } else if ((_repeatMode == RepeatMode.all || _autoPlayNext) &&
        _currentSurah != null &&
        _currentAyah != null) {
      playNextAyah();
    }
  }

  /// Start practice mode
  void startPractice({int loopCount = 1, bool wait = false}) {
    _isPracticeMode = true;
    _loopCount = loopCount;
    _waitForRecitation = wait;
    _currentLoopIdx = 0;
    notifyListeners();
  }

  /// Play ayah audio with gapless support
  Future<void> playAyah(int surahNumber, int ayahNumber, {int? totalAyahs}) async {
    try {
      await _loadSelectedReciter();

      _currentSurah = surahNumber;
      _currentAyah = ayahNumber;
      _playlistStartAyah = ayahNumber;
      if (totalAyahs != null) {
        _totalAyahsInCurrentSurah = totalAyahs;
      }

      final List<AudioSource> sources = [];
      final int endAyah = _totalAyahsInCurrentSurah ?? ayahNumber;

      for (int i = ayahNumber; i <= endAyah; i++) {
        final String audioUrl = _getAudioUrlForCurrentReciter(surahNumber, i);
        sources.add(
          AudioSource.uri(
            Uri.parse(audioUrl),
            tag: MediaItem(
              id: 'surah_${surahNumber}_ayah_$i',
              title: 'Surah $surahNumber - Ayah $i',
              artist: 'Quran Recitation',
              album: 'Al-Quran Pro',
              artUri: Uri.parse('https://images.unsplash.com/photo-1584281723351-954999953d71?q=80&w=200&h=200&auto=format&fit=crop'),
            ),
          ),
        );
      }

      final playlist = ConcatenatingAudioSource(children: sources);

      _isLoading = true;
      notifyListeners();

      await _audioPlayer.setAudioSource(playlist);
      await _audioPlayer.setSpeed(_playbackSpeed);
      await _audioPlayer.play();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      debugPrint('Error playing audio: $e');
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
  }

  Future<void> resume() async {
    await _audioPlayer.play();
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentSurah = null;
    _currentAyah = null;
    _playlistStartAyah = null;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed.clamp(
      AppConstants.minPlaybackSpeed,
      AppConstants.maxPlaybackSpeed,
    );
    await _audioPlayer.setSpeed(_playbackSpeed);
    notifyListeners();
  }

  Future<void> repeatAyah() async {
    if (_currentSurah != null && _currentAyah != null) {
      await playAyah(_currentSurah!, _currentAyah!);
    }
  }

  Future<void> playNextAyah() async {
    if (_currentSurah != null && _currentAyah != null && _totalAyahsInCurrentSurah != null) {
      if (_currentAyah! < _totalAyahsInCurrentSurah!) {
        await playAyah(_currentSurah!, _currentAyah! + 1, totalAyahs: _totalAyahsInCurrentSurah);
      } else {
        await stop();
      }
    }
  }

  Future<void> playPreviousAyah() async {
    if (_currentSurah != null && _currentAyah != null && _currentAyah! > 1) {
      await playAyah(_currentSurah!, _currentAyah! - 1, totalAyahs: _totalAyahsInCurrentSurah);
    }
  }

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

  void setRepeatMode(RepeatMode mode) {
    _repeatMode = mode;
    notifyListeners();
  }

  void toggleAutoPlayNext() {
    _autoPlayNext = !_autoPlayNext;
    notifyListeners();
  }

  void setSleepTimer(Duration duration) {
    cancelSleepTimer(notify: false);
    _stopAtEndOfSurah = false;
    _sleepTimerEnd = DateTime.now().add(duration);
    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (_sleepTimerEnd == null) {
        timer.cancel();
        return;
      }
      if (DateTime.now().isAfter(_sleepTimerEnd!)) {
        timer.cancel();
        _sleepTimer = null;
        _sleepTimerEnd = null;
        await stop();
      }
      notifyListeners();
    });
    notifyListeners();
  }

  void setSleepTimerPreset(SleepTimerPreset preset) {
    switch (preset) {
      case SleepTimerPreset.fifteenMin:
        setSleepTimer(const Duration(minutes: 15));
        break;
      case SleepTimerPreset.thirtyMin:
        setSleepTimer(const Duration(minutes: 30));
        break;
      case SleepTimerPreset.oneHour:
        setSleepTimer(const Duration(hours: 1));
        break;
      case SleepTimerPreset.endOfSurah:
        cancelSleepTimer(notify: false);
        _stopAtEndOfSurah = true;
        notifyListeners();
        break;
    }
  }

  void cancelSleepTimer({bool notify = true}) {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _sleepTimerEnd = null;
    _stopAtEndOfSurah = false;
    if (notify) {
      notifyListeners();
    }
  }

  List<double> get availableSpeeds => [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  Future<void> initializeAudioService() async {
    if (_audioServiceInitialized) return;
    try {
      await AudioService.init(
        builder: () => AudioPlayerHandler(_audioPlayer),
        config: const AudioServiceConfig(
          androidNotificationChannelId: 'com.quran.app.audio',
          androidNotificationChannelName: 'Quran Audio Playback',
          androidNotificationOngoing: false,
          androidStopForegroundOnPause: false,
        ),
      );
      _audioServiceInitialized = true;
    } catch (e) {
      debugPrint('Error initializing audio service: $e');
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
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

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();
}
