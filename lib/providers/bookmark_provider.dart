import 'package:flutter/foundation.dart';
import '../models/bookmark.dart';
import '../models/bookmark_folder.dart';
import '../services/database_service.dart';

/// Provider for bookmarks state management
class BookmarkProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Bookmark> _bookmarks = [];
  List<BookmarkFolder> _folders = [];
  bool _isLoading = false;

  List<Bookmark> get bookmarks => _bookmarks;
  List<BookmarkFolder> get folders => _folders;
  bool get isLoading => _isLoading;

  /// Load all bookmarks
  Future<void> loadBookmarks() async {
    _isLoading = true;
    notifyListeners();

    try {
      _bookmarks = await _databaseService.getBookmarks();
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add bookmark
  Future<void> addBookmark(int surahNumber, int ayahNumber, {String? note}) async {
    try {
      final bookmark = Bookmark(
        id: 0, // Will be auto-generated
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        createdAt: DateTime.now(),
        note: note,
      );
      await _databaseService.insertBookmark(bookmark);
      await loadBookmarks();
    } catch (e) {
      debugPrint('Error adding bookmark: $e');
    }
  }

  /// Remove bookmark
  Future<void> removeBookmark(int surahNumber, int ayahNumber) async {
    try {
      await _databaseService.deleteBookmark(surahNumber, ayahNumber);
      await loadBookmarks();
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }

  /// Check if ayah is bookmarked
  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    return await _databaseService.isBookmarked(surahNumber, ayahNumber);
  }

  /// Toggle bookmark
  Future<void> toggleBookmark(int surahNumber, int ayahNumber) async {
    final isBookmarked = await this.isBookmarked(surahNumber, ayahNumber);
    if (isBookmarked) {
      await removeBookmark(surahNumber, ayahNumber);
    } else {
      await addBookmark(surahNumber, ayahNumber);
    }
  }

  /// Load all folders
  Future<void> loadFolders() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: Implement database method to load folders
      // For now, using empty list
      _folders = [];
    } catch (e) {
      debugPrint('Error loading folders: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new folder
  Future<void> createFolder({
    required String name,
    String? description,
    required int colorValue,
  }) async {
    try {
      final folder = BookmarkFolder(
        id: DateTime.now().millisecondsSinceEpoch, // Temporary ID generation
        name: name,
        description: description,
        colorValue: colorValue,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      _folders.add(folder);
      notifyListeners();
      
      // TODO: Save to database
    } catch (e) {
      debugPrint('Error creating folder: $e');
    }
  }

  /// Update an existing folder
  Future<void> updateFolder(BookmarkFolder folder) async {
    try {
      final index = _folders.indexWhere((f) => f.id == folder.id);
      if (index != -1) {
        _folders[index] = folder;
        notifyListeners();
        
        // TODO: Update in database
      }
    } catch (e) {
      debugPrint('Error updating folder: $e');
    }
  }

  /// Delete a folder
  Future<void> deleteFolder(int folderId) async {
    try {
      _folders.removeWhere((f) => f.id == folderId);
      notifyListeners();
      
      // TODO: Delete from database
    } catch (e) {
      debugPrint('Error deleting folder: $e');
    }
  }
}
