import 'dart:io';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../utils/app_logger.dart';

class AudioRecordingService {
  static final AudioRecordingService _instance = AudioRecordingService._internal();
  factory AudioRecordingService() => _instance;
  AudioRecordingService._internal();

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  String? _currentRecordingPath;

  bool get isRecording => _isRecording;
  String? get currentRecordingPath => _currentRecordingPath;

  Future<bool> hasPermission() async {
    return await _audioRecorder.hasPermission();
  }

  Future<String?> startRecording() async {
    try {
      if (await hasPermission()) {
        final dir = await getApplicationDocumentsDirectory();
        final recordingsDir = Directory('${dir.path}/recordings');
        if (!await recordingsDir.exists()) {
          await recordingsDir.create(recursive: true);
        }

        final fileName = 'hifz_${const Uuid().v4()}.m4a';
        _currentRecordingPath = '${recordingsDir.path}/$fileName';

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: _currentRecordingPath!,
        );

        _isRecording = true;
        return _currentRecordingPath;
      }
      return null;
    } catch (e, stack) {
      AppLogger.error('Failed to start recording', error: e, stackTrace: stack);
      return null;
    }
  }

  Future<String?> stopRecording() async {
    try {
      final path = await _audioRecorder.stop();
      _isRecording = false;
      return path ?? _currentRecordingPath;
    } catch (e, stack) {
      AppLogger.error('Failed to stop recording', error: e, stackTrace: stack);
      _isRecording = false;
      return null;
    }
  }

  Future<void> dispose() async {
    await _audioRecorder.dispose();
  }
}
