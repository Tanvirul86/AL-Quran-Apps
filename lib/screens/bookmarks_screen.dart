import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/bookmark_provider.dart';
import '../providers/quran_provider.dart';
import '../models/bookmark.dart';
import 'ayah_reading_screen.dart';
import 'bookmark_folders_screen.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/skeleton_loading.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookmarkProvider>().loadBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookmarkFoldersScreen()),
              );
            },
            tooltip: 'Manage Folders',
          ),
        ],
      ),
      body: Consumer<BookmarkProvider>(
        builder: (context, bookmarkProvider, _) {
          if (bookmarkProvider.isLoading) {
            return const LoadingSkeletons(type: 'ayah', count: 5);
          }

          final bookmarks = bookmarkProvider.bookmarks;
          if (bookmarks.isEmpty) {
            return EmptyStates.noBookmarks(
              context,
              onAction: () => Navigator.pop(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: bookmarks.length,
            itemBuilder: (context, index) {
              final bookmark = bookmarks[index];
              return _BookmarkItem(
                bookmark: bookmark,
                onTap: () async {
                  final quranProvider = context.read<QuranProvider>();
                  final surah = quranProvider.getSurah(bookmark.surahNumber);
                  if (surah != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AyahReadingScreen(surah: surah),
                      ),
                    );
                  }
                },
                onDelete: () async {
                  await bookmarkProvider.removeBookmark(
                    bookmark.surahNumber,
                    bookmark.ayahNumber,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _BookmarkItem extends StatelessWidget {
  final Bookmark bookmark;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _BookmarkItem({
    required this.bookmark,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: Text(
            '${bookmark.surahNumber}:${bookmark.ayahNumber}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text('Surah ${bookmark.surahNumber}, Ayah ${bookmark.ayahNumber}'),
        subtitle: bookmark.note != null
            ? Text(
                bookmark.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                'Bookmarked on ${_formatDate(bookmark.createdAt)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
