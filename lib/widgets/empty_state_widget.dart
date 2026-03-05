import 'package:flutter/material.dart';

/// Beautiful empty state widget with illustration
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon with gradient background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withOpacity(0.2),
                    Theme.of(context).primaryColor.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            
            // Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            
            // Message
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel!),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Predefined empty states
class EmptyStates {
  static Widget noBookmarks(BuildContext context, {VoidCallback? onAction}) {
    return EmptyStateWidget(
      icon: Icons.bookmark_outline,
      title: 'No Bookmarks Yet',
      message: 'Start bookmarking your favorite ayahs to find them easily later.',
      actionLabel: 'Browse Quran',
      onAction: onAction,
    );
  }

  static Widget noSearchResults(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.search_off,
      title: 'No Results Found',
      message: 'Try adjusting your search terms or filters.',
    );
  }

  static Widget noNotes(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.note_outlined,
      title: 'No Notes Yet',
      message: 'Add personal notes to ayahs to help with your understanding and memorization.',
    );
  }

  static Widget error(BuildContext context, {required String message, VoidCallback? onRetry}) {
    return EmptyStateWidget(
      icon: Icons.error_outline,
      title: 'Oops! Something went wrong',
      message: message,
      actionLabel: 'Try Again',
      onAction: onRetry,
    );
  }

  static Widget offline(BuildContext context) {
    return EmptyStateWidget(
      icon: Icons.wifi_off,
      title: 'No Internet Connection',
      message: 'Some features require an internet connection. Please check your connection and try again.',
    );
  }
}
