import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/bookmark.dart';
import '../utils/constants.dart';

/// Database service for local storage
class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), AppConstants.dbName);
    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Bookmarks table
    await db.execute('''
      CREATE TABLE bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surahNumber INTEGER NOT NULL,
        ayahNumber INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        note TEXT
      )
    ''');

    // Notes table (separate from bookmarks for flexibility)
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surahNumber INTEGER NOT NULL,
        ayahNumber INTEGER NOT NULL,
        note TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Reading progress table
    await db.execute('''
      CREATE TABLE reading_progress (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surahNumber INTEGER NOT NULL,
        ayahNumber INTEGER NOT NULL,
        lastReadAt TEXT NOT NULL
      )
    ''');
  }

  // Bookmarks
  Future<int> insertBookmark(Bookmark bookmark) async {
    final db = await database;
    return await db.insert('bookmarks', bookmark.toJson());
  }

  Future<List<Bookmark>> getBookmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('bookmarks', orderBy: 'createdAt DESC');
    return List.generate(maps.length, (i) => Bookmark.fromJson(maps[i]));
  }

  Future<bool> isBookmarked(int surahNumber, int ayahNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'bookmarks',
      where: 'surahNumber = ? AND ayahNumber = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
    return maps.isNotEmpty;
  }

  Future<int> deleteBookmark(int surahNumber, int ayahNumber) async {
    final db = await database;
    return await db.delete(
      'bookmarks',
      where: 'surahNumber = ? AND ayahNumber = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
  }

  // Notes
  Future<int> saveNote(int surahNumber, int ayahNumber, String note) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    // Check if note exists
    final existing = await db.query(
      'notes',
      where: 'surahNumber = ? AND ayahNumber = ?',
      whereArgs: [surahNumber, ayahNumber],
    );

    if (existing.isNotEmpty) {
      return await db.update(
        'notes',
        {
          'note': note,
          'updatedAt': now,
        },
        where: 'surahNumber = ? AND ayahNumber = ?',
        whereArgs: [surahNumber, ayahNumber],
      );
    } else {
      return await db.insert('notes', {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'note': note,
        'createdAt': now,
        'updatedAt': now,
      });
    }
  }

  Future<String?> getNote(int surahNumber, int ayahNumber) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'notes',
      where: 'surahNumber = ? AND ayahNumber = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
    if (maps.isEmpty) return null;
    return maps.first['note'] as String?;
  }

  Future<int> deleteNote(int surahNumber, int ayahNumber) async {
    final db = await database;
    return await db.delete(
      'notes',
      where: 'surahNumber = ? AND ayahNumber = ?',
      whereArgs: [surahNumber, ayahNumber],
    );
  }

  // Reading Progress
  Future<void> saveReadingProgress(int surahNumber, int ayahNumber) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    
    await db.insert(
      'reading_progress',
      {
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'lastReadAt': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, int>?> getLastReadAyah() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'reading_progress',
      orderBy: 'lastReadAt DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return {
      'surahNumber': maps.first['surahNumber'] as int,
      'ayahNumber': maps.first['ayahNumber'] as int,
    };
  }
}
