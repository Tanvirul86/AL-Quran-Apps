import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';

/// Notification service for Quran app
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) return;

    // Timezone init is required for zonedSchedule to fire at local prayer times.
    await _initializeTimezone();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Ensure any persisted reminders are restored after app restart/upgrade.
    await rescheduleSavedNotifications();
    _initialized = true;
  }

  Future<void> _initializeTimezone() async {
    try {
      tzdata.initializeTimeZones();
      final localName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localName));
    } catch (_) {
      // Fallback to UTC if local zone detection fails.
      tz.setLocalLocation(tz.UTC);
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    final androidImplementation =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    
    final result = await androidImplementation?.requestNotificationsPermission();
    return result ?? false;
  }

  /// Schedule a notification
  Future<void> scheduleNotification(
    QuranNotification notification, {
    bool useAdhanSound = false,
  }) async {
    Future<void> doSchedule(AndroidScheduleMode mode) {
      return _notifications.zonedSchedule(
        notification.hashCode,
        notification.title,
        notification.body,
        tz.TZDateTime.from(notification.scheduledTime, tz.local),
        _notificationDetails(useAdhanSound: useAdhanSound),
        androidScheduleMode: mode,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: json.encode(notification.payload),
        matchDateTimeComponents: notification.isRepeating
            ? DateTimeComponents.time
            : null,
      );
    }

    try {
      await doSchedule(AndroidScheduleMode.exactAllowWhileIdle);
    } on PlatformException catch (e) {
      if (e.code == 'exact_alarms_not_permitted') {
        await doSchedule(AndroidScheduleMode.inexactAllowWhileIdle);
      } else {
        rethrow;
      }
    }

    // Save notification to preferences
    await _saveNotification(notification);
  }

  /// Schedule daily Ayah of the Day
  Future<void> scheduleDailyAyah({
    required int hour,
    required int minute,
  }) async {
    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    final notification = QuranNotification(
      id: 'daily_ayah',
      title: '📖 Ayah of the Day',
      body: 'Discover today\'s inspiring verse from the Quran',
      type: NotificationType.ayahOfTheDay,
      scheduledTime: scheduledTime,
      isRepeating: true,
    );

    await scheduleNotification(notification);
  }

  /// Schedule reading reminder
  Future<void> scheduleReadingReminder({
    required String title,
    required String body,
    required DateTime time,
    bool isRepeating = true,
  }) async {
    final notification = QuranNotification(
      id: 'reading_reminder',
      title: title,
      body: body,
      type: NotificationType.readingReminder,
      scheduledTime: time,
      isRepeating: isRepeating,
    );

    await scheduleNotification(notification);
  }

  /// Schedule prayer reminder
  Future<void> schedulePrayerReminder({
    required String prayerName,
    required DateTime time,
    bool useAdhanSound = false,
  }) async {
    final notification = QuranNotification(
      id: 'prayer_$prayerName',
      title: '🕌 $prayerName Prayer Time',
      body: 'It\'s time for $prayerName prayer',
      type: NotificationType.prayerReminder,
      scheduledTime: time,
      isRepeating: true,
    );

    await scheduleNotification(notification, useAdhanSound: useAdhanSound);
  }

  /// Schedule memorization reminder
  Future<void> scheduleMemorizationReminder({
    required DateTime time,
    required String message,
  }) async {
    final notification = QuranNotification(
      id: 'memorization_reminder',
      title: '📚 Memorization Time',
      body: message,
      type: NotificationType.memorizationReminder,
      scheduledTime: time,
      isRepeating: true,
    );

    await scheduleNotification(notification);
  }

  /// Schedule daily tasbih reminder
  Future<void> scheduleTasbihReminder({
    required DateTime time,
    required String message,
  }) async {
    final notification = QuranNotification(
      id: 'tasbih_reminder',
      title: 'SubhanAllah Reminder',
      body: message,
      type: NotificationType.readingReminder,
      scheduledTime: time,
      isRepeating: true,
    );

    await scheduleNotification(notification);
  }

  /// Schedule streak reminder
  Future<void> scheduleStreakReminder() async {
    final now = DateTime.now();
    var reminderTime = DateTime(now.year, now.month, now.day, 20, 0);
    if (reminderTime.isBefore(now)) {
      reminderTime = reminderTime.add(const Duration(days: 1));
    }
    
    final notification = QuranNotification(
      id: 'streak_reminder',
      title: '🔥 Keep Your Streak!',
      body: 'Don\'t forget to read Quran today to maintain your streak',
      type: NotificationType.streakReminder,
      scheduledTime: reminderTime,
      isRepeating: true,
    );

    await scheduleNotification(notification);
  }

  /// Fire an immediate local notification for verification.
  Future<void> showInstantNotification({
    required String title,
    required String body,
    bool useAdhanSound = false,
  }) async {
    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      _notificationDetails(useAdhanSound: useAdhanSound),
      payload: json.encode({'type': 'test'}),
    );
  }

  /// Rehydrate persisted notifications (helps after reboot/app restart).
  Future<void> rescheduleSavedNotifications() async {
    final notifications = await getScheduledNotifications();
    final now = DateTime.now();
    for (final n in notifications.where((n) => n.isEnabled)) {
      final scheduleTime = n.isRepeating && n.scheduledTime.isBefore(now)
          ? DateTime(now.year, now.month, now.day, n.scheduledTime.hour, n.scheduledTime.minute)
          : n.scheduledTime;
      final normalized = scheduleTime.isBefore(now) && n.isRepeating
          ? scheduleTime.add(const Duration(days: 1))
          : scheduleTime;

      await scheduleNotification(
        n.copyWith(scheduledTime: normalized),
        useAdhanSound: n.payload?['useAdhanSound'] == true,
      );
    }
  }

  /// Cancel a notification
  Future<void> cancelNotification(String notificationId) async {
    await _notifications.cancel(notificationId.hashCode);
    await _removeNotification(notificationId);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('scheduled_notifications');
  }

  /// Get all scheduled notifications
  Future<List<QuranNotification>> getScheduledNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('scheduled_notifications');
    
    if (data != null) {
      final List<dynamic> list = json.decode(data);
      return list.map((json) => QuranNotification.fromJson(json)).toList();
    }
    
    return [];
  }

  /// Check if notification is enabled
  Future<bool> isNotificationEnabled(String notificationId) async {
    final notifications = await getScheduledNotifications();
    final notification = notifications.where((n) => n.id == notificationId).firstOrNull;
    return notification?.isEnabled ?? false;
  }

  /// Toggle notification
  Future<void> toggleNotification(String notificationId, bool enabled) async {
    final notifications = await getScheduledNotifications();
    final index = notifications.indexWhere((n) => n.id == notificationId);
    
    if (index != -1) {
      final notification = notifications[index];
      if (enabled) {
        await scheduleNotification(notification);
      } else {
        await cancelNotification(notificationId);
      }
    }
  }

  // Private helper methods

  NotificationDetails _notificationDetails({bool useAdhanSound = false}) {
    final android = AndroidNotificationDetails(
      useAdhanSound ? 'quran_adhan_channel' : 'quran_app_channel',
      useAdhanSound ? 'Quran Athan Alerts' : 'Quran Notifications',
      channelDescription: useAdhanSound
          ? 'Athan alerts for prayer times'
          : 'Notifications for Quran reading and reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
      sound: useAdhanSound
          ? const RawResourceAndroidNotificationSound('adhan')
          : null,
    );

    final ios = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: useAdhanSound ? 'adhan.aiff' : null,
    );

    return NotificationDetails(android: android, iOS: ios);
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Navigate to appropriate screen based on payload
    if (response.payload != null) {
      // Handle navigation based on payload
    }
  }

  Future<void> _saveNotification(QuranNotification notification) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getScheduledNotifications();
    
    // Remove old notification with same ID
    notifications.removeWhere((n) => n.id == notification.id);
    
    // Add new notification
    notifications.add(notification);
    
    await prefs.setString(
      'scheduled_notifications',
      json.encode(notifications.map((n) => n.toJson()).toList()),
    );
  }

  Future<void> _removeNotification(String notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final notifications = await getScheduledNotifications();
    
    notifications.removeWhere((n) => n.id == notificationId);
    
    await prefs.setString(
      'scheduled_notifications',
      json.encode(notifications.map((n) => n.toJson()).toList()),
    );
  }
}
