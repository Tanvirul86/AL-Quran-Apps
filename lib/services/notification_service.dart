import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
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

    _initialized = true;
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
  Future<void> scheduleNotification(QuranNotification notification) async {
    await _notifications.zonedSchedule(
      notification.hashCode,
      notification.title,
      notification.body,
      tz.TZDateTime.from(notification.scheduledTime, tz.local),
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: json.encode(notification.payload),
      matchDateTimeComponents: notification.isRepeating
          ? DateTimeComponents.time
          : null,
    );

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
      id: 'reading_reminder_${time.millisecondsSinceEpoch}',
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
  }) async {
    final notification = QuranNotification(
      id: 'prayer_$prayerName',
      title: '🕌 $prayerName Prayer Time',
      body: 'It\'s time for $prayerName prayer',
      type: NotificationType.prayerReminder,
      scheduledTime: time,
      isRepeating: true,
    );

    await scheduleNotification(notification);
  }

  /// Schedule memorization reminder
  Future<void> scheduleMemorizationReminder({
    required DateTime time,
    required String message,
  }) async {
    final notification = QuranNotification(
      id: 'memorization_${time.millisecondsSinceEpoch}',
      title: '📚 Memorization Time',
      body: message,
      type: NotificationType.memorizationReminder,
      scheduledTime: time,
      isRepeating: true,
    );

    await scheduleNotification(notification);
  }

  /// Schedule streak reminder
  Future<void> scheduleStreakReminder() async {
    final now = DateTime.now();
    final reminderTime = DateTime(now.year, now.month, now.day, 20, 0);
    
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

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'quran_app_channel',
        'Quran Notifications',
        channelDescription: 'Notifications for Quran reading and reminders',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // Navigate to appropriate screen based on payload
    if (response.payload != null) {
      final payload = json.decode(response.payload!);
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
