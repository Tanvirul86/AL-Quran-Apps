import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Analytics Dashboard - Reading statistics and insights
class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  Map<String, dynamic> _analyticsData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Load reading time data
    final readingTime = prefs.getInt('total_reading_time') ?? 0;
    final readingSessions = prefs.getInt('reading_sessions') ?? 0;
    final completedSurahs = prefs.getStringList('completed_surahs') ?? [];
    
    // Load favorite surahs (most read)
    final surahReads = prefs.getString('surah_reads') ?? '{}';
    final surahReadsMap = Map<String, int>.from(
      json.decode(surahReads).map((k, v) => MapEntry(k.toString(), v as int)),
    );

    // Load weekly reading data
    final weeklyData = _getWeeklyReadingData(prefs);
    
    setState(() {
      _analyticsData = {
        'readingTime': readingTime,
        'readingSessions': readingSessions,
        'completedSurahs': completedSurahs,
        'surahReads': surahReadsMap,
        'weeklyData': weeklyData,
        'averageSessionTime': readingSessions > 0
            ? (readingTime / readingSessions).round()
            : 0,
        'completionPercentage': (completedSurahs.length / 114 * 100).round(),
      };
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> _getWeeklyReadingData(SharedPreferences prefs) {
    final today = DateTime.now();
    final weeklyData = <Map<String, dynamic>>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = 'reading_${date.year}_${date.month}_${date.day}';
      final minutes = prefs.getInt(key) ?? 0;
      
      weeklyData.add({
        'day': _getDayName(date.weekday),
        'minutes': minutes,
        'date': date,
      });
    }

    return weeklyData;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadAnalytics,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Summary Cards
            _buildSummaryCards(),

            const SizedBox(height: 24),

            // Weekly Reading Chart
            const Text(
              'Weekly Reading Time',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildWeeklyChart(),

            const SizedBox(height: 24),

            // Completion Progress
            const Text(
              'Quran Completion',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildCompletionChart(),

            const SizedBox(height: 24),

            // Favorite Surahs
            const Text(
              'Most Read Surahs',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFavoriteSurahs(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildSummaryCard(
          'Total Time',
          '${_analyticsData['readingTime']} min',
          Icons.timer,
          Colors.blue,
        ),
        _buildSummaryCard(
          'Sessions',
          '${_analyticsData['readingSessions']}',
          Icons.history,
          Colors.green,
        ),
        _buildSummaryCard(
          'Avg Session',
          '${_analyticsData['averageSessionTime']} min',
          Icons.speed,
          Colors.orange,
        ),
        _buildSummaryCard(
          'Completed',
          '${_analyticsData['completedSurahs'].length}/114',
          Icons.check_circle,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
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

  Widget _buildWeeklyChart() {
    final weeklyData = _analyticsData['weeklyData'] as List<Map<String, dynamic>>;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: weeklyData.map((d) => d['minutes'] as int).reduce((a, b) => a > b ? a : b).toDouble() + 10,
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt()} min',
                      const TextStyle(color: Colors.white),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 && value.toInt() < weeklyData.length) {
                        return Text(
                          weeklyData[value.toInt()]['day'],
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '${value.toInt()}',
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              barGroups: weeklyData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: (data['minutes'] as int).toDouble(),
                      color: Colors.blue,
                      width: 20,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletionChart() {
    final percentage = _analyticsData['completionPercentage'] as int;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 60,
                  sections: [
                    PieChartSectionData(
                      value: percentage.toDouble(),
                      title: '$percentage%',
                      color: Colors.green,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    PieChartSectionData(
                      value: (100 - percentage).toDouble(),
                      title: '${100 - percentage}%',
                      color: Colors.grey.shade300,
                      radius: 50,
                      titleStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${(_analyticsData['completedSurahs'] as List).length} of 114 Surahs completed',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteSurahs() {
    final surahReads = _analyticsData['surahReads'] as Map<String, int>;
    
    if (surahReads.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No reading data yet'),
          ),
        ),
      );
    }

    final sortedSurahs = surahReads.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Column(
        children: sortedSurahs.take(5).map((entry) {
          final surahNumber = int.parse(entry.key);
          final reads = entry.value;
          final maxReads = sortedSurahs.first.value;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Text(
                '$surahNumber',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text('Surah $surahNumber'),
            trailing: SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: reads / maxReads,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('$reads'),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
