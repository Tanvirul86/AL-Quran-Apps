import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/memorization_provider.dart';
import '../models/memorization_session.dart';
import 'package:intl/intl.dart';

/// Memorization Dashboard - Hifz tracking and progress
class MemorizationDashboardScreen extends StatefulWidget {
  const MemorizationDashboardScreen({super.key});

  @override
  State<MemorizationDashboardScreen> createState() =>
      _MemorizationDashboardScreenState();
}

class _MemorizationDashboardScreenState
    extends State<MemorizationDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memorization'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Sessions', icon: Icon(Icons.history)),
            Tab(text: 'Goals', icon: Icon(Icons.flag)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _DashboardTab(),
          _SessionsTab(),
          _GoalsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showStartSessionDialog(context),
        icon: const Icon(Icons.play_arrow),
        label: const Text('Start Session'),
      ),
    );
  }

  void _showStartSessionDialog(BuildContext context) {
    final surahController = TextEditingController();
    final startAyahController = TextEditingController();
    final endAyahController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Start Memorization Session',
          style: TextStyle(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: surahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Surah Number (1-114)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: startAyahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Start Ayah',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: endAyahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'End Ayah',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final surah = int.tryParse(surahController.text);
              final start = int.tryParse(startAyahController.text);
              final end = int.tryParse(endAyahController.text);

              if (surah != null && start != null && end != null) {
                if (surah < 1 || surah > 114) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Surah number must be between 1-114'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                if (start > end) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Start ayah must be less than end ayah'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                Provider.of<MemorizationProvider>(context, listen: false)
                    .startSession(
                  surahNumber: surah,
                  startAyah: start,
                  endAyah: end,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Session started! Good luck with your memorization!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please fill all fields'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Start'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Dashboard Tab
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MemorizationProvider>(
      builder: (context, provider, _) {
        final stats = provider.getStatistics();
        final weakAyahs = provider.getWeakAyahs();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Current Session Card
            if (provider.hasActiveSession) _buildActiveSessionCard(provider),

            // Statistics Grid
            _buildStatisticsGrid(stats),

            const SizedBox(height: 16),

            // Weak Ayahs
            if (weakAyahs.isNotEmpty) ...[
              const Text(
                'Ayahs Need Practice',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...weakAyahs.entries.take(5).map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: Text('Surah ${entry.key}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${entry.value} mistakes',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }

  Widget _buildActiveSessionCard(MemorizationProvider provider) {
    final session = provider.currentSession!;
    final elapsed = DateTime.now().difference(session.startTime);

    return Card(
      color: Colors.green.shade50,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.play_circle, color: Colors.green, size: 32),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Active Session',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${elapsed.inMinutes} min',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Surah ${session.surahNumber}: Ayah ${session.startAyah}-${session.endAyah}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Builder(
                    builder: (context) => ElevatedButton.icon(
                      onPressed: () => _showEndSessionDialog(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.stop, size: 18),
                      label: const Text('End Session'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEndSessionDialog(BuildContext context, MemorizationProvider provider) {
    final repetitionController = TextEditingController();
    final confidenceController = TextEditingController();
    final mistakesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'End Session',
          style: TextStyle(fontSize: 18),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: repetitionController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'How many times did you repeat?',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: confidenceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confidence (0-100%)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: mistakesController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(
                  labelText: 'Mistake Ayah Numbers (comma separated)',
                  hintText: 'e.g., 1,3,5',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final repetitions = int.tryParse(repetitionController.text) ?? 0;
              final confidence = double.tryParse(confidenceController.text) ?? 0.0;
              final mistakesText = mistakesController.text.trim();
              final mistakes = mistakesText.isEmpty
                  ? <int>[]
                  : mistakesText.split(',').map((s) => int.tryParse(s.trim())).where((n) => n != null).cast<int>().toList();

              provider.endSession(
                repetitionCount: repetitions,
                confidenceScore: confidence.clamp(0, 100),
                mistakeAyahs: mistakes,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session completed! Keep up the great work!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsGrid(Map<String, dynamic> stats) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total Sessions',
          '${stats['totalSessions']}',
          Icons.history,
          Colors.blue,
        ),
        _buildStatCard(
          'Total Time',
          '${stats['totalTime']} min',
          Icons.timer,
          Colors.green,
        ),
        _buildStatCard(
          'Avg Confidence',
          '${stats['averageConfidence'].toStringAsFixed(1)}%',
          Icons.star,
          Colors.orange,
        ),
        _buildStatCard(
          'Active Goals',
          '${stats['activeGoals']}',
          Icons.flag,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Sessions Tab
class _SessionsTab extends StatelessWidget {
  const _SessionsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MemorizationProvider>(
      builder: (context, provider, _) {
        final sessions = provider.sessions;

        if (sessions.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No sessions yet'),
                Text('Start your first memorization session!'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[sessions.length - 1 - index];
            return _buildSessionCard(session);
          },
        );
      },
    );
  }

  Widget _buildSessionCard(MemorizationSession session) {
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: Icon(
          Icons.book,
          color: session.confidenceScore >= 80
              ? Colors.green
              : session.confidenceScore >= 60
                  ? Colors.orange
                  : Colors.red,
        ),
        title: Text(
          'Surah ${session.surahNumber}: ${session.startAyah}-${session.endAyah}',
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          dateFormat.format(session.startTime),
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _getConfidenceColor(session.confidenceScore).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '${session.confidenceScore.toInt()}%',
            style: TextStyle(
              color: _getConfidenceColor(session.confidenceScore),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Duration', '${session.duration.inMinutes} minutes'),
                _buildInfoRow('Repetitions', '${session.repetitionCount}'),
                _buildInfoRow('Mistakes', '${session.mistakeAyahs.length} ayahs'),
                if (session.mistakeAyahs.isNotEmpty)
                  _buildInfoRow(
                    'Mistake Ayahs',
                    session.mistakeAyahs.join(', '),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getConfidenceColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }
}

// Goals Tab
class _GoalsTab extends StatelessWidget {
  const _GoalsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<MemorizationProvider>(
      builder: (context, provider, _) {
        final goals = provider.goals;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ElevatedButton.icon(
              onPressed: () => _showCreateGoalDialog(context),
              icon: const Icon(Icons.add),
              label: const Text('Create New Goal'),
            ),
            const SizedBox(height: 16),
            if (goals.isEmpty)
              const Center(
                child: Column(
                  children: [
                    SizedBox(height: 32),
                    Icon(Icons.flag, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No goals set'),
                    Text('Create a goal to track your progress!'),
                  ],
                ),
              )
            else
              ...goals.map((goal) => _buildGoalCard(context, goal, provider)),
          ],
        );
      },
    );
  }

  Widget _buildGoalCard(
    BuildContext context,
    MemorizationGoal goal,
    MemorizationProvider provider,
  ) {
    final progress = goal.progress;
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                if (goal.isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Surah ${goal.targetSurahNumber}: ${goal.startAyah}-${goal.endAyah}',
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation(
                goal.isCompleted ? Colors.green : Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toInt()}% complete'),
                Text(
                  daysLeft > 0 ? '$daysLeft days left' : 'Overdue',
                  style: TextStyle(
                    color: daysLeft > 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateGoalDialog(BuildContext context) {
    // Implementation for creating goals
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Goal creation coming soon!')),
    );
  }
}
