/// Simplified word highlighting that tracks position within ayah without needing exact word timings
class SimpleWordHighlighter {
  /// Split ayah text into words (Arabic words separated by spaces)
  static List<String> splitIntoWords(String arabicText) {
    return arabicText.split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
  }

  /// Get current word index based on playback position and total duration
  /// Uses simple proportional calculation: (position / duration) * wordCount
  static int getCurrentWordIndex(
    Duration position,
    Duration duration,
    int wordCount,
  ) {
    if (wordCount <= 0 || duration.inMilliseconds <= 0) {
      return -1;
    }

    final progressRatio = position.inMilliseconds / duration.inMilliseconds;
    
    // Clamp between 0 and wordCount - 1
    final wordIndex = (progressRatio * wordCount).floor();
    return wordIndex.clamp(0, wordCount - 1);
  }

  /// Check if we're currently in a word's estimated time range
  /// This provides a smoother highlight that adjusts as position changes
  static bool isWordCurrentlyPlaying(
    int wordIndex,
    int totalWords,
    Duration position,
    Duration duration,
  ) {
    if (totalWords <= 0 || duration.inMilliseconds <= 0) {
      return false;
    }

    // Estimate time per word
    final msPerWord = duration.inMilliseconds / totalWords;
    
    // Calculate the time range for this word
    final wordStartMs = wordIndex * msPerWord;
    final wordEndMs = (wordIndex + 1) * msPerWord;
    
    final currentMs = position.inMilliseconds.toDouble();
    
    return currentMs >= wordStartMs && currentMs < wordEndMs;
  }
}
