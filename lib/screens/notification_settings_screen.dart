import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../services/prayer_times_service.dart';

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
  final PrayerTimesService _prayerTimesService = PrayerTimesService();

  // Notification toggles
  bool _dailyAyahEnabled = true;
  bool _readingReminderEnabled = false;
  bool _prayerReminderEnabled = false;
  bool _memorizationReminderEnabled = false;
  bool _streakReminderEnabled = true;
  bool _useAdhanSound = false;

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
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyAyahEnabled = prefs.getBool('notif_daily_ayah_enabled') ?? true;
      _readingReminderEnabled =
          prefs.getBool('notif_reading_enabled') ?? false;
      _prayerReminderEnabled =
          prefs.getBool('notif_prayer_enabled') ?? false;
      _memorizationReminderEnabled =
          prefs.getBool('notif_memorization_enabled') ?? false;
      _streakReminderEnabled = prefs.getBool('notif_streak_enabled') ?? true;
      _useAdhanSound = prefs.getBool('notif_use_adhan_sound') ?? false;

      _dailyAyahTime = TimeOfDay(
        hour: prefs.getInt('notif_daily_h') ?? 8,
        minute: prefs.getInt('notif_daily_m') ?? 0,
      );
      _readingReminderTime = TimeOfDay(
        hour: prefs.getInt('notif_reading_h') ?? 20,
        minute: prefs.getInt('notif_reading_m') ?? 0,
      );
      _memorizationReminderTime = TimeOfDay(
        hour: prefs.getInt('notif_mem_h') ?? 18,
        minute: prefs.getInt('notif_mem_m') ?? 0,
      );
      _streakReminderTime = TimeOfDay(
        hour: prefs.getInt('notif_streak_h') ?? 21,
        minute: prefs.getInt('notif_streak_m') ?? 0,
      );
    });

    if (_prayerReminderEnabled) {
      await _refreshPrayerTimesForDisplay();
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_daily_ayah_enabled', _dailyAyahEnabled);
    await prefs.setBool('notif_reading_enabled', _readingReminderEnabled);
    await prefs.setBool('notif_prayer_enabled', _prayerReminderEnabled);
    await prefs.setBool('notif_memorization_enabled', _memorizationReminderEnabled);
    await prefs.setBool('notif_streak_enabled', _streakReminderEnabled);
    await prefs.setBool('notif_use_adhan_sound', _useAdhanSound);

    await prefs.setInt('notif_daily_h', _dailyAyahTime.hour);
    await prefs.setInt('notif_daily_m', _dailyAyahTime.minute);
    await prefs.setInt('notif_reading_h', _readingReminderTime.hour);
    await prefs.setInt('notif_reading_m', _readingReminderTime.minute);
    await prefs.setInt('notif_mem_h', _memorizationReminderTime.hour);
    await prefs.setInt('notif_mem_m', _memorizationReminderTime.minute);
    await prefs.setInt('notif_streak_h', _streakReminderTime.hour);
    await prefs.setInt('notif_streak_m', _streakReminderTime.minute);
  }

  Future<void> _refreshPrayerTimesForDisplay() async {
    try {
      final position = await _prayerTimesService.getCurrentLocationSafe();
      final times = await _prayerTimesService.getPrayerTimes(
        date: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _prayerTimes
          ..clear()
          ..addAll({
            'Fajr': TimeOfDay.fromDateTime(times['Fajr']!),
            'Dhuhr': TimeOfDay.fromDateTime(times['Dhuhr']!),
            'Asr': TimeOfDay.fromDateTime(times['Asr']!),
            'Maghrib': TimeOfDay.fromDateTime(times['Maghrib']!),
            'Isha': TimeOfDay.fromDateTime(times['Isha']!),
          });
      });
    } catch (_) {
      // Keep existing fallback display times.
    }
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
              } else {
                _notificationService.cancelNotification('daily_ayah');
              }
              _saveSettings();
            },
            onTimeChanged: (time) {
              setState(() => _dailyAyahTime = time);
              if (_dailyAyahEnabled) {
                _scheduleDailyAyah();
              }
              _saveSettings();
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
              } else {
                _notificationService.cancelNotification('reading_reminder');
              }
              _saveSettings();
            },
            onTimeChanged: (time) {
              setState(() => _readingReminderTime = time);
              if (_readingReminderEnabled) {
                _scheduleReadingReminder();
              }
              _saveSettings();
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
              } else {
                _notificationService.cancelNotification('memorization_reminder');
              }
              _saveSettings();
            },
            onTimeChanged: (time) {
              setState(() => _memorizationReminderTime = time);
              if (_memorizationReminderEnabled) {
                _scheduleMemorizationReminder();
              }
              _saveSettings();
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
              } else {
                _notificationService.cancelNotification('streak_reminder');
              }
              _saveSettings();
            },
            onTimeChanged: (time) {
              setState(() => _streakReminderTime = time);
              if (_streakReminderEnabled) {
                _scheduleStreakReminder();
              }
              _saveSettings();
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
                    } else {
                      for (final prayer in _prayerTimes.keys) {
                        _notificationService.cancelNotification('prayer_$prayer');
                      }
                    }
                    _saveSettings();
                  },
                ),
              ],
            ),
            if (_prayerReminderEnabled) ...[
              const Divider(),
              SwitchListTile(
                title: const Text('Use Adhan Sound (Optional)'),
                subtitle: const Text('Requires adhan sound resource in app'),
                value: _useAdhanSound,
                onChanged: (value) async {
                  setState(() => _useAdhanSound = value);
                  await _saveSettings();
                  await _schedulePrayerReminders();
                },
              ),
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
    await _saveSettings();
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
    await _saveSettings();
    _showSnackBar('Reading reminder scheduled');
  }

  Future<void> _schedulePrayerReminders() async {
    await _refreshPrayerTimesForDisplay();
    final position = await _prayerTimesService.getCurrentLocationSafe();
    final prayers = await _prayerTimesService.getPrayerTimes(
      date: DateTime.now(),
      latitude: position.latitude,
      longitude: position.longitude,
    );

    for (final entry in prayers.entries) {
      if (entry.key == 'Sunrise') continue;
      await _notificationService.schedulePrayerReminder(
        prayerName: entry.key,
        time: entry.value,
        useAdhanSound: _useAdhanSound,
      );
    }
    await _saveSettings();
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
    await _saveSettings();
    _showSnackBar('Memorization reminder scheduled');
  }

  Future<void> _scheduleStreakReminder() async {
    await _notificationService.scheduleStreakReminder();
    await _saveSettings();
    _showSnackBar('Streak reminder scheduled');
  }

  Future<void> _sendTestNotification() async {
    await _notificationService.showInstantNotification(
      title: _useAdhanSound ? '🕌 Test Adhan Reminder' : '🔔 Test Reminder',
      body: 'If you received this, local notifications are working.',
      useAdhanSound: _useAdhanSound,
    );
    _showSnackBar('Test notification sent');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
