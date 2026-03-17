import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'notification_service.dart';
import '../models/notification_model.dart';

/// Prayer times calculation service using Aladhan API + local calculations
class PrayerTimesService {
  static final PrayerTimesService _instance = PrayerTimesService._internal();
  factory PrayerTimesService() => _instance;
  PrayerTimesService._internal();

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  // Location and athan settings
  bool _isLocationEnabled = false;
  bool _athanAlertsEnabled = true;
  Map<String, bool> _prayerAthanEnabled = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  /// Check location service status
  Future<bool> checkLocationService() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _isLocationEnabled = false;
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _isLocationEnabled = false;
          return false;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _isLocationEnabled = false;
        return false;
      }

      _isLocationEnabled = true;
      return true;
    } catch (e) {
      print('Error checking location service: $e');
      _isLocationEnabled = false;
      return false;
    }
  }

  /// Request location permission explicitly
  Future<bool> requestLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Try to open location settings
        await Geolocator.openLocationSettings();
        return false;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        // Open app settings for permission
        await Geolocator.openAppSettings();
        return false;
      }

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return false;
        }
      }

      _isLocationEnabled = true;
      return true;
    } catch (e) {
      print('Error requesting location permission: $e');
      return false;
    }
  }

  /// Get current location with fallback to saved location
  Future<Position> getCurrentLocationSafe() async {
    bool locationOk = await checkLocationService();
    
    if (locationOk) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 10),
        );
        await _saveLastLocation(position);
        return position;
      } catch (e) {
        // Fall back to saved location
        return await _getLastSavedLocation();
      }
    } else {
      // Use last saved location
      return await _getLastSavedLocation();
    }
  }

  /// Save last known location
  Future<void> _saveLastLocation(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_location', json.encode({
      'latitude': position.latitude,
      'longitude': position.longitude,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  /// Get last saved location
  Future<Position> _getLastSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final locationStr = prefs.getString('last_location');
    
    if (locationStr != null) {
      final locationData = json.decode(locationStr);
      return Position(
        latitude: locationData['latitude'],
        longitude: locationData['longitude'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(locationData['timestamp']),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
    }
    
    // Default to Mecca if no saved location
    return Position(
      latitude: 21.4225,
      longitude: 39.8262,
      timestamp: DateTime.now(),
      accuracy: 0,
      altitude: 0,
      heading: 0,
      speed: 0,
      speedAccuracy: 0,
      altitudeAccuracy: 0,
      headingAccuracy: 0,
    );
  }

  /// Enable/disable athan alerts
  Future<void> setAthanAlertsEnabled(bool enabled) async {
    _athanAlertsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('athan_alerts_enabled', enabled);
    
    if (enabled) {
      await scheduleAthanAlerts();
    } else {
      await _cancelAllAthanAlerts();
    }
  }

  /// Enable/disable specific prayer athan
  Future<void> setPrayerAthanEnabled(String prayer, bool enabled) async {
    _prayerAthanEnabled[prayer] = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('prayer_athan_settings', json.encode(_prayerAthanEnabled));
  }

  /// Schedule athan alerts for all prayers
  Future<void> scheduleAthanAlerts() async {
    if (!_athanAlertsEnabled) return;
    
    try {
      // Check notification permission
      final notificationService = NotificationService();
      final hasPermission = await notificationService.requestPermissions();
      
      if (!hasPermission) {
        print('Notification permission not granted');
        return;
      }
      
      final position = await getCurrentLocationSafe();
      final prayerTimes = await getPrayerTimes(
        date: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      // Cancel existing athan notifications first
      await _cancelAllAthanAlerts();
      
      for (final entry in prayerTimes.entries) {
        if (_prayerAthanEnabled[entry.key] == true && entry.value.isAfter(DateTime.now())) {
          await notificationService.scheduleNotification(
            QuranNotification(
              id: 'athan_${entry.key}',
              title: '🕌 ${entry.key} Prayer Time',
              body: 'It\'s time for ${entry.key} prayer. Allahu Akbar!',
              type: NotificationType.prayerReminder,
              scheduledTime: entry.value,
              payload: {'prayer': entry.key, 'type': 'athan'},
              isRepeating: false, // Schedule daily manually
            ),
          );
        }
      }
      
      print('Athan alerts scheduled successfully');
    } catch (e) {
      print('Error scheduling athan alerts: $e');
    }
  }

  /// Cancel all athan alerts
  Future<void> _cancelAllAthanAlerts() async {
    final notificationService = NotificationService();
    for (final prayer in _prayerAthanEnabled.keys) {
      await notificationService.cancelNotification('athan_$prayer');
    }
  }

  /// Get location service status message
  String getLocationStatusMessage() {
    if (!_isLocationEnabled) {
      return 'Location permission needed. Tap "Enable" to allow access for accurate prayer times.';
    }
    return 'Location enabled ✓ Prayer times are accurate for your current location.';
  }

  /// Calculate prayer times for a given date and location
  Future<Map<String, DateTime>> getPrayerTimes({
    required DateTime date,
    required double latitude,
    required double longitude,
    int calculationMethod = 2, // 2 = ISNA, 1 = MWL, 3 = Egyptian
    int asrMethod = 0, // 0 = Standard (Shafi), 1 = Hanafi
  }) async {
    try {
      // Try to fetch from Aladhan API first
      final response = await _dio.get(
        'https://api.aladhan.com/v1/timings/${date.day}-${date.month}-${date.year}',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'method': calculationMethod,
          'school': asrMethod,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final timings = data['data']['timings'] as Map<String, dynamic>;
        
        return {
          'Fajr': _parseTime(timings['Fajr'], date),
          'Sunrise': _parseTime(timings['Sunrise'], date),
          'Dhuhr': _parseTime(timings['Dhuhr'], date),
          'Asr': _parseTime(timings['Asr'], date),
          'Maghrib': _parseTime(timings['Maghrib'], date),
          'Isha': _parseTime(timings['Isha'], date),
        };
      }
    } catch (e) {
      // If API fails, use local calculation
      print('Aladhan API failed, using local calculation: $e');
    }

    // Fallback to local calculation
    return _calculateLocalPrayerTimes(date, latitude, longitude, calculationMethod, asrMethod);
  }

  DateTime _parseTime(String timeStr, DateTime date) {
    // Time format from API: "HH:mm" or "HH:mm (Timezone)"
    final cleanTime = timeStr.split(' ').first;
    final parts = cleanTime.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  Map<String, DateTime> _calculateLocalPrayerTimes(
    DateTime date,
    double latitude,
    double longitude,
    int method,
    int asrMethod,
  ) {
    // Proper astronomical calculation
    final julianDate = _gregorianToJulian(date.year, date.month, date.day);
    final sunPosition = _calculateSunPosition(julianDate);
    final equationOfTime = sunPosition['equationOfTime']!;
    final sunDeclination = sunPosition['declination']!;
    
    // Calculate noon (Dhuhr)
    final noonTime = 12.0 + (-longitude / 15.0) - (equationOfTime / 60.0);
    
    // Sun angle for various prayers
    double fajrAngle = -18.0; // Default
    double ishaAngle = -17.0; // Default
    
    // Adjust angles based on calculation method
    switch (method) {
      case 1: // MWL
        fajrAngle = -18.0;
        ishaAngle = -17.0;
        break;
      case 2: // ISNA
        fajrAngle = -15.0;
        ishaAngle = -15.0;
        break;
      case 3: // Egyptian
        fajrAngle = -19.5;
        ishaAngle = -17.5;
        break;
      case 4: // Umm al-Qura
        fajrAngle = -18.5;
        ishaAngle = -90.0; // 90 mins after Maghrib
        break;
    }
    
    // Calculate prayer times
    final sunrise = noonTime - _calculateTimeForAngle(-0.833, latitude, sunDeclination);
    final sunset = noonTime + _calculateTimeForAngle(-0.833, latitude, sunDeclination);
    final fajr = noonTime - _calculateTimeForAngle(fajrAngle, latitude, sunDeclination);
    
    double isha;
    if (method == 4) {
      isha = sunset + 1.5; // 90 minutes after Maghrib for Umm al-Qura
    } else {
      isha = noonTime + _calculateTimeForAngle(ishaAngle, latitude, sunDeclination);
    }
    
    // Asr calculation
    final asrFactor = asrMethod == 1 ? 2.0 : 1.0; // Hanafi vs Shafi
    final asrAngle = -math.atan(1.0 / (asrFactor + math.tan((latitude - sunDeclination).abs() * math.pi / 180))) * 180 / math.pi;
    final asr = noonTime + _calculateTimeForAngle(asrAngle, latitude, sunDeclination);
    
    return {
      'Fajr': _timeToDateTime(date, fajr),
      'Sunrise': _timeToDateTime(date, sunrise),
      'Dhuhr': _timeToDateTime(date, noonTime + (5.0 / 60.0)), // Add 5 min after noon
      'Asr': _timeToDateTime(date, asr),
      'Maghrib': _timeToDateTime(date, sunset),
      'Isha': _timeToDateTime(date, isha),
    };
  }

  double _gregorianToJulian(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() + 
           (30.6001 * (month + 1)).floor() + 
           day + b - 1524.5;
  }

  Map<String, double> _calculateSunPosition(double julianDate) {
    final d = julianDate - 2451545.0;
    final g = (357.529 + 0.98560028 * d) % 360;
    final q = (280.459 + 0.98564736 * d) % 360;
    final l = (q + 1.915 * math.sin(g * math.pi / 180) + 0.020 * math.sin(2 * g * math.pi / 180)) % 360;
    final e = 23.439 - 0.00000036 * d;
    final ra = math.atan2(math.cos(e * math.pi / 180) * math.sin(l * math.pi / 180), math.cos(l * math.pi / 180)) * 180 / math.pi;
    final dec = math.asin(math.sin(e * math.pi / 180) * math.sin(l * math.pi / 180)) * 180 / math.pi;
    
    var eqt = q / 15 - (ra / 15);
    if (eqt > 12) eqt -= 24;
    if (eqt < -12) eqt += 24;
    
    return {
      'equationOfTime': eqt * 60,
      'declination': dec,
    };
  }

  double _calculateTimeForAngle(double angle, double latitude, double declination) {
    final latRad = latitude * math.pi / 180;
    final decRad = declination * math.pi / 180;
    final angleRad = angle * math.pi / 180;
    
    var cosHour = (math.sin(angleRad) - math.sin(latRad) * math.sin(decRad)) /
                  (math.cos(latRad) * math.cos(decRad));
    
    // Clamp to valid range
    if (cosHour > 1) cosHour = 1;
    if (cosHour < -1) cosHour = -1;
    
    return math.acos(cosHour) * 180 / math.pi / 15;
  }

  DateTime _timeToDateTime(DateTime date, double time) {
    // Normalize time to 0-24 range
    while (time < 0) time += 24;
    while (time >= 24) time -= 24;
    
    final hours = time.floor();
    final minutes = ((time - hours) * 60).round();
    
    return DateTime(date.year, date.month, date.day, hours, minutes);
  }

  Future<Position> getCurrentLocation() async {
    return await getCurrentLocationSafe();
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final city = place.locality ?? place.subAdministrativeArea ?? '';
        final country = place.country ?? '';
        if (city.isNotEmpty && country.isNotEmpty) {
          return '$city, $country';
        } else if (country.isNotEmpty) {
          return country;
        }
      }
    } catch (e) {
      print('Error getting location name: $e');
    }
    return 'Lat: ${latitude.toStringAsFixed(2)}, Lon: ${longitude.toStringAsFixed(2)}';
  }
}
