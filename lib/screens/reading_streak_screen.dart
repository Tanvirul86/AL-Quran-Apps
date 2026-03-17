import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reading_progress.dart';
import '../services/database_service.dart';

class ReadingStreakScreen extends StatefulWidget {
  const ReadingStreakScreen({super.key});

  @override
  State<ReadingStreakScreen> createState() => _ReadingStreakScreenState();
}

class _ReadingStreakScreenState extends State<ReadingStreakScreen> {
  final DatabaseService _db = DatabaseService();
  ReadingProgress? _progress;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final lastRead = await _db.getLastReadAyah();
      if (lastRead != null) {
        // Calculate streak and progress
        final progress = await _calculateProgress(lastRead);
        setState(() {
          _progress = progress;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<ReadingProgress> _calculateProgress(Map<String, int> lastRead) async {
    // This is a simplified calculation
    // In production, you'd track daily readings more accurately
    
    final now = DateTime.now();
    final lastReadDate = now; // Should come from database
    
    // Calculate streak (simplified)
    int streak = 1; // Placeholder
    
    return ReadingProgress(
      surahNumber: lastRead['surahNumber']!,
      ayahNumber: lastRead['ayahNumber']!,
      lastReadAt: lastReadDate,
      totalAyahsRead: 100, // Placeholder
      currentStreak: streak,
      streakStartDate: now.subtract(Duration(days: streak)),
      surahProgress: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading Progress'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _progress == null
              ? const Center(child: Text('No reading progress yet'))
              : RefreshIndicator(
                  onRefresh: _loadProgress,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Streak card
                      _buildStreakCard(),
                      const SizedBox(height: 16),
                      
                      // Statistics
                      _buildStatisticsCard(),
                      const SizedBox(height: 16),
                      
                      // Last read
                      _buildLastReadCard(),
                      const SizedBox(height: 16),
                      
                      // Progress chart (placeholder)
                      _buildProgressChart(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStreakCard() {
    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text(
              'Current Streak',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${_progress!.currentStreak}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'days',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            if (_progress!.streakStartDate != null) ...[
              const SizedBox(height: 16),
              Text(
                'Started ${DateFormat('MMM d, yyyy').format(_progress!.streakStartDate!)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Ayahs Read', '${_progress!.totalAyahsRead}'),
            const Divider(),
            _buildStatRow('Last Read', DateFormat('MMM d, yyyy').format(_progress!.lastReadAt)),
            const Divider(),
            _buildStatRow(
              'Last Position',
              'Surah ${_progress!.surahNumber}, Ayah ${_progress!.ayahNumber}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastReadCard() {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor,
          child: const Icon(Icons.book, color: Colors.white),
        ),
        title: const Text('Continue Reading'),
        subtitle: Text(
          'Surah ${_progress!.surahNumber}, Ayah ${_progress!.ayahNumber}',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // Navigate to reading screen
        },
      ),
    );
  }

  Widget _buildProgressChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weekly Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            // Placeholder for chart
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Progress chart coming soon'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
