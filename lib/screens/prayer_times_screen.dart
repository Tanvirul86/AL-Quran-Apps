import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/prayer_times_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'dart:async';

class PrayerTimesScreen extends StatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerTimesService _prayerService = PrayerTimesService();
  Map<String, DateTime>? _prayerTimes;
  String? _locationName;
  bool _isLoading = true;
  String? _error;
  Timer? _updateTimer;
  bool _locationEnabled = false;
  String _locationStatus = '';

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
    // Update every minute
    _updateTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _loadPrayerTimes();
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadPrayerTimes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Check location service status
      _locationEnabled = await _prayerService.checkLocationService();
      _locationStatus = _prayerService.getLocationStatusMessage();
      
      final position = await _prayerService.getCurrentLocationSafe();
      final locationName = await _prayerService.getLocationName(
        position.latitude,
        position.longitude,
      );
      final prayerTimes = await _prayerService.getPrayerTimes(
        date: DateTime.now(),
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _prayerTimes = prayerTimes;
        _locationName = locationName;
        _isLoading = false;
      });
      
      // Schedule athan alerts if enabled
      await _prayerService.scheduleAthanAlerts();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _getTimeUntil(DateTime prayerTime) {
    final now = DateTime.now();
    if (prayerTime.isBefore(now)) {
      return 'Passed';
    }
    final difference = prayerTime.difference(now);
    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    }
    return '${difference.inMinutes}m';
  }

  String _getNextPrayer() {
    if (_prayerTimes == null) return '';
    
    final now = DateTime.now();
    final prayers = _prayerTimes!.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    
    for (final prayer in prayers) {
      if (prayer.value.isAfter(now)) {
        return prayer.key;
      }
    }
    return prayers.first.key; // Next day's Fajr
  }

  void _showAthanSettings() async {
    // Request notification permission before showing settings
    final notificationService = NotificationService();
    final hasPermission = await notificationService.requestPermissions();
    
    if (!hasPermission && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notification permission is required for Athan alerts'),
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => AthanSettingsSheet(
        prayerService: _prayerService,
        onSettingsChanged: () {
          setState(() {}); // Refresh UI if needed
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prayer Times'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrayerTimes,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPrayerTimes,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _prayerTimes == null
                  ? const Center(child: Text('No prayer times available'))
                  : RefreshIndicator(
                      onRefresh: _loadPrayerTimes,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Location card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.green),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Location',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          _locationName ?? 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_location),
                                    onPressed: () {
                                      // TODO: Allow manual location input
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Location status card
                          Card(
                            color: _locationEnabled ? AppTheme.forestSurface : Colors.orange.shade50,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Icon(
                                    _locationEnabled ? Icons.gps_fixed : Icons.gps_off,
                                    color: _locationEnabled ? AppTheme.primaryGreen : Colors.orange,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _locationStatus,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: _locationEnabled ? AppTheme.darkGreen : Colors.orange.shade700,
                                      ),
                                    ),
                                  ),
                                  if (!_locationEnabled)
                                    TextButton(
                                      onPressed: () async {
                                        // Request location permission
                                        final granted = await _prayerService.requestLocationPermission();
                                        if (granted) {
                                          await _loadPrayerTimes();
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: const Text('Location permission granted!'),
                                                backgroundColor: AppTheme.primaryGreen,
                                              ),
                                            );
                                          }
                                        } else {
                                          if (mounted) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text('Please enable location in device settings'),
                                                duration: Duration(seconds: 3),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      child: const Text('Enable'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Athan alerts card
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.notifications, color: AppTheme.primaryGreen),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Athan Alerts',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      TextButton(
                                        onPressed: () => _showAthanSettings(),
                                        child: const Text('Settings'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Get notified when prayer time arrives with beautiful Athan alerts.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Next prayer highlight
                          _buildNextPrayerCard(),
                          const SizedBox(height: 16),
                          
                          // All prayer times
                          ..._prayerTimes!.entries.map((entry) {
                            final isNext = entry.key == _getNextPrayer();
                            return _buildPrayerCard(
                              entry.key,
                              entry.value,
                              isNext,
                            );
                          }),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildNextPrayerCard() {
    final nextPrayer = _getNextPrayer();
    final nextTime = _prayerTimes![nextPrayer]!;
    final timeUntil = _getTimeUntil(nextTime);

    return Card(
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              'Next Prayer',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              nextPrayer,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatTime(nextTime),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'in $timeUntil',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrayerCard(String name, DateTime time, bool isNext) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isNext ? 4 : 1,
      color: isNext ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isNext
              ? Theme.of(context).primaryColor
              : Colors.grey[300],
          child: Icon(
            _getPrayerIcon(name),
            color: isNext ? Colors.white : Colors.grey[700],
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            fontSize: isNext ? 18 : 16,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _formatTime(time),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isNext ? Theme.of(context).primaryColor : null,
              ),
            ),
            if (isNext)
              Text(
                _getTimeUntil(time),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getPrayerIcon(String prayer) {
    switch (prayer) {
      case 'Fajr':
        return Icons.wb_twilight;
      case 'Sunrise':
        return Icons.wb_sunny;
      case 'Dhuhr':
        return Icons.wb_sunny_outlined;
      case 'Asr':
        return Icons.brightness_6;
      case 'Maghrib':
        return Icons.wb_twilight;
      case 'Isha':
        return Icons.nightlight;
      default:
        return Icons.access_time;
    }
  }
}

class AthanSettingsSheet extends StatefulWidget {
  final PrayerTimesService prayerService;
  final VoidCallback onSettingsChanged;

  const AthanSettingsSheet({
    super.key,
    required this.prayerService,
    required this.onSettingsChanged,
  });

  @override
  State<AthanSettingsSheet> createState() => _AthanSettingsSheetState();
}

class _AthanSettingsSheetState extends State<AthanSettingsSheet> {
  bool _athanEnabled = true;
  Map<String, bool> _prayerSettings = {
    'Fajr': true,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _athanEnabled = prefs.getBool('athan_alerts_enabled') ?? true;
      final savedSettings = prefs.getString('prayer_athan_settings');
      if (savedSettings != null) {
        try {
          final decoded = json.decode(savedSettings) as Map<String, dynamic>;
          _prayerSettings = decoded.map((key, value) => MapEntry(key, value as bool));
        } catch (e) {
          // Use defaults if parsing fails
        }
      }
    });
  }

  Future<void> _saveSettings() async {
    await widget.prayerService.setAthanAlertsEnabled(_athanEnabled);
    for (final entry in _prayerSettings.entries) {
      await widget.prayerService.setPrayerAthanEnabled(entry.key, entry.value);
    }
    widget.onSettingsChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 8, bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Athan Alert Settings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.darkGreen,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                SwitchListTile(
                  title: const Text('Enable Athan Alerts'),
                  subtitle: const Text('Receive notifications at prayer times'),
                  value: _athanEnabled,
                  activeColor: AppTheme.primaryGreen,
                  onChanged: (value) {
                    setState(() {
                      _athanEnabled = value;
                    });
                  },
                ),
                
                const Divider(),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Individual Prayer Alerts',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
                
                ..._prayerSettings.entries.map((entry) {
                  return SwitchListTile(
                    title: Text(entry.key),
                    value: _athanEnabled && entry.value,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: _athanEnabled ? (value) {
                      setState(() {
                        _prayerSettings[entry.key] = value;
                      });
                    } : null,
                  );
                }).toList(),
              ],
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await _saveSettings();
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Athan settings saved'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
