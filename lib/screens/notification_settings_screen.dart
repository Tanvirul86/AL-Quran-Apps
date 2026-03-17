import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Notification Settings Screen - Configure all notification types
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late NotificationService _notificationService;

  // Notification toggles
  bool _dailyAyahEnabled = true;
  bool _readingReminderEnabled = false;
  bool _prayerReminderEnabled = false;
  bool _memorizationReminderEnabled = false;
  bool _streakReminderEnabled = true;

  // Time settings
  TimeOfDay _dailyAyahTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _readingReminderTime = const TimeOfDay(hour: 20, minute: 0);
  TimeOfDay _memorizationReminderTime = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _streakReminderTime = const TimeOfDay(hour: 21, minute: 0);

  // Prayer times (for demo purposes)
  final Map<String, TimeOfDay> _prayerTimes = {
    'Fajr': const TimeOfDay(hour: 5, minute: 30),
    'Dhuhr': const TimeOfDay(hour: 12, minute: 30),
    'Asr': const TimeOfDay(hour: 16, minute: 0),
    'Maghrib': const TimeOfDay(hour: 18, minute: 30),
    'Isha': const TimeOfDay(hour: 20, minute: 0),
  };

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationService();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    // Load saved settings from SharedPreferences
    // For now using defaults
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Daily Ayah Notification
          _buildNotificationCard(
            title: 'Daily Ayah',
            subtitle: 'Receive a verse every day',
            icon: Icons.auto_stories,
            color: Colors.blue,
            enabled: _dailyAyahEnabled,
            time: _dailyAyahTime,
            onToggle: (value) {
              setState(() => _dailyAyahEnabled = value);
              if (value) {
                _scheduleDailyAyah();
              }
            },
            onTimeChanged: (time) {
              setState(() => _dailyAyahTime = time);
              if (_dailyAyahEnabled) {
                _scheduleDailyAyah();
              }
            },
          ),

          const SizedBox(height: 12),

          // Reading Reminder
          _buildNotificationCard(
            title: 'Reading Reminder',
            subtitle: 'Daily reminder to read Quran',
            icon: Icons.menu_book,
            color: Colors.green,
            enabled: _readingReminderEnabled,
            time: _readingReminderTime,
            onToggle: (value) {
              setState(() => _readingReminderEnabled = value);
              if (value) {
                _scheduleReadingReminder();
              }
            },
            onTimeChanged: (time) {
              setState(() => _readingReminderTime = time);
              if (_readingReminderEnabled) {
                _scheduleReadingReminder();
              }
            },
          ),

          const SizedBox(height: 12),

          // Prayer Reminders
          _buildPrayerReminderCard(),

          const SizedBox(height: 12),

          // Memorization Reminder
          _buildNotificationCard(
            title: 'Memorization Reminder',
            subtitle: 'Practice your Hifz daily',
            icon: Icons.psychology,
            color: Colors.purple,
            enabled: _memorizationReminderEnabled,
            time: _memorizationReminderTime,
            onToggle: (value) {
              setState(() => _memorizationReminderEnabled = value);
              if (value) {
                _scheduleMemorizationReminder();
              }
            },
            onTimeChanged: (time) {
              setState(() => _memorizationReminderTime = time);
              if (_memorizationReminderEnabled) {
                _scheduleMemorizationReminder();
              }
            },
          ),

          const SizedBox(height: 12),

          // Streak Reminder
          _buildNotificationCard(
            title: 'Streak Reminder',
            subtitle: "Don't break your reading streak!",
            icon: Icons.local_fire_department,
            color: Colors.orange,
            enabled: _streakReminderEnabled,
            time: _streakReminderTime,
            onToggle: (value) {
              setState(() => _streakReminderEnabled = value);
              if (value) {
                _scheduleStreakReminder();
              }
            },
            onTimeChanged: (time) {
              setState(() => _streakReminderTime = time);
              if (_streakReminderEnabled) {
                _scheduleStreakReminder();
              }
            },
          ),

          const SizedBox(height: 24),

          // Test Notification Button
          ElevatedButton.icon(
            onPressed: _sendTestNotification,
            icon: const Icon(Icons.notifications_active),
            label: const Text('Send Test Notification'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool enabled,
    required TimeOfDay time,
    required Function(bool) onToggle,
    required Function(TimeOfDay) onTimeChanged,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: enabled,
                  onChanged: onToggle,
                ),
              ],
            ),
            if (enabled) ...[
              const Divider(),
              InkWell(
                onTap: () => _selectTime(context, time, onTimeChanged),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        'Time: ${time.format(context)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerReminderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.mosque, color: Colors.teal),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prayer Reminders',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Notify before prayer times',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _prayerReminderEnabled,
                  onChanged: (value) {
                    setState(() => _prayerReminderEnabled = value);
                    if (value) {
                      _schedulePrayerReminders();
                    }
                  },
                ),
              ],
            ),
            if (_prayerReminderEnabled) ...[
              const Divider(),
              ..._prayerTimes.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ),
                      Text(entry.value.format(context)),
                      const Spacer(),
                      const Icon(Icons.notifications, size: 16, color: Colors.teal),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(
    BuildContext context,
    TimeOfDay currentTime,
    Function(TimeOfDay) onTimeChanged,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (picked != null) {
      onTimeChanged(picked);
    }
  }

  Future<void> _scheduleDailyAyah() async {
    await _notificationService.scheduleDailyAyah(
      hour: _dailyAyahTime.hour,
      minute: _dailyAyahTime.minute,
    );
    _showSnackBar('Daily Ayah scheduled for ${_dailyAyahTime.format(context)}');
  }

  Future<void> _scheduleReadingReminder() async {
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day,
        _readingReminderTime.hour, _readingReminderTime.minute);
    await _notificationService.scheduleReadingReminder(
      title: '📖 Time to Read Quran',
      body: 'Continue your daily Quran reading',
      time: time,
    );
    _showSnackBar('Reading reminder scheduled');
  }

  Future<void> _schedulePrayerReminders() async {
    final now = DateTime.now();
    final prayers = {
      'Fajr': DateTime(now.year, now.month, now.day, 5, 0),
      'Dhuhr': DateTime(now.year, now.month, now.day, 12, 30),
      'Asr': DateTime(now.year, now.month, now.day, 15, 30),
      'Maghrib': DateTime(now.year, now.month, now.day, 18, 0),
      'Isha': DateTime(now.year, now.month, now.day, 19, 30),
    };
    for (final entry in prayers.entries) {
      await _notificationService.schedulePrayerReminder(
        prayerName: entry.key,
        time: entry.value,
      );
    }
    _showSnackBar('Prayer reminders scheduled');
  }

  Future<void> _scheduleMemorizationReminder() async {
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day,
        _memorizationReminderTime.hour, _memorizationReminderTime.minute);
    await _notificationService.scheduleMemorizationReminder(
      time: time,
      message: 'Time for your daily Quran memorization session',
    );
    _showSnackBar('Memorization reminder scheduled');
  }

  Future<void> _scheduleStreakReminder() async {
    await _notificationService.scheduleStreakReminder();
    _showSnackBar('Streak reminder scheduled');
  }

  Future<void> _sendTestNotification() async {
    // Send immediate test notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notification sent!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
