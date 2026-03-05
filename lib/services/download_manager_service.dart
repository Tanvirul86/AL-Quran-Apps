import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Download manager for handling all content downloads
class DownloadManagerService {
  final Dio _dio = Dio();
  final Map<String, DownloadTask> _activeTasks = {};

  // Download callbacks
  Function(String id, double progress)? onProgress;
  Function(String id, String path)? onComplete;
  Function(String id, String error)? onError;

  /// Download a file with progress tracking
  Future<String?> downloadFile({
    required String url,
    required String taskId,
    required String fileName,
    required String category, // 'tafsir', 'translation', 'audio', 'reciter'
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get download directory
      final directory = await _getDownloadDirectory(category);
      final filePath = '${directory.path}/$fileName';

      // Check if already exists
      if (await File(filePath).exists()) {
        await _saveMetadata(taskId, filePath, metadata);
        onComplete?.call(taskId, filePath);
        return filePath;
      }

      // Create download task
      final task = DownloadTask(
        id: taskId,
        url: url,
        filePath: filePath,
        category: category,
        progress: 0.0,
        status: DownloadStatus.downloading,
      );
      _activeTasks[taskId] = task;

      // Start download with progress
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total);
            task.progress = progress;
            onProgress?.call(taskId, progress);
          }
        },
      );

      // Mark as complete
      task.status = DownloadStatus.completed;
      await _saveMetadata(taskId, filePath, metadata);
      onComplete?.call(taskId, filePath);

      return filePath;
    } catch (e) {
      _activeTasks[taskId]?.status = DownloadStatus.failed;
      onError?.call(taskId, e.toString());
      return null;
    }
  }

  /// Download multiple files in queue
  Future<void> downloadBatch(List<DownloadRequest> requests) async {
    for (final request in requests) {
      await downloadFile(
        url: request.url,
        taskId: request.taskId,
        fileName: request.fileName,
        category: request.category,
        metadata: request.metadata,
      );
    }
  }

  /// Pause download (if supported)
  Future<void> pauseDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null) {
      task.status = DownloadStatus.paused;
      // Implement pause logic with dio cancellation
    }
  }

  /// Resume download
  Future<void> resumeDownload(String taskId) async {
    final task = _activeTasks[taskId];
    if (task != null && task.status == DownloadStatus.paused) {
      // Implement resume logic
      await downloadFile(
        url: task.url,
        taskId: task.id,
        fileName: task.filePath.split('/').last,
        category: task.category,
      );
    }
  }

  /// Cancel download
  Future<void> cancelDownload(String taskId) async {
    _activeTasks.remove(taskId);
    // Implement cancellation logic
  }

  /// Get download progress
  double? getProgress(String taskId) {
    return _activeTasks[taskId]?.progress;
  }

  /// Check if file is downloaded
  Future<bool> isDownloaded(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = prefs.getString('download_$taskId');
    if (metadata != null) {
      final data = json.decode(metadata);
      final path = data['path'] as String?;
      if (path != null) {
        return await File(path).exists();
      }
    }
    return false;
  }

  /// Get downloaded file path
  Future<String?> getDownloadedPath(String taskId) async {
    final prefs = await SharedPreferences.getInstance();
    final metadata = prefs.getString('download_$taskId');
    if (metadata != null) {
      final data = json.decode(metadata);
      return data['path'] as String?;
    }
    return null;
  }

  /// Delete downloaded file
  Future<bool> deleteDownload(String taskId) async {
    try {
      final path = await getDownloadedPath(taskId);
      if (path != null) {
        final file = File(path);
        if (await file.exists()) {
          await file.delete();
        }
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('download_$taskId');
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get total storage used
  Future<int> getTotalStorageUsed() async {
    int totalSize = 0;
    final categories = ['tafsir', 'translation', 'audio', 'reciter'];
    
    for (final category in categories) {
      final directory = await _getDownloadDirectory(category);
      if (await directory.exists()) {
        final files = directory.listSync();
        for (final file in files) {
          if (file is File) {
            totalSize += await file.length();
          }
        }
      }
    }
    
    return totalSize;
  }

  /// Get download directory based on category
  Future<Directory> _getDownloadDirectory(String category) async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/downloads/$category');
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// Save metadata about downloaded file
  Future<void> _saveMetadata(
    String taskId,
    String path,
    Map<String, dynamic>? metadata,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final data = {
      'path': path,
      'downloadedAt': DateTime.now().toIso8601String(),
      ...?metadata,
    };
    await prefs.setString('download_$taskId', json.encode(data));
  }
}

/// Download task model
class DownloadTask {
  final String id;
  final String url;
  final String filePath;
  final String category;
  double progress;
  DownloadStatus status;

  DownloadTask({
    required this.id,
    required this.url,
    required this.filePath,
    required this.category,
    required this.progress,
    required this.status,
  });
}

/// Download request model
class DownloadRequest {
  final String url;
  final String taskId;
  final String fileName;
  final String category;
  final Map<String, dynamic>? metadata;

  DownloadRequest({
    required this.url,
    required this.taskId,
    required this.fileName,
    required this.category,
    this.metadata,
  });
}

enum DownloadStatus {
  pending,
  downloading,
  paused,
  completed,
  failed,
}
