import 'package:flutter/material.dart';
import 'dart:async';
import '../services/prayer_times_service.dart';
import '../widgets/glass_card.dart';

/// A compact, premium prayer times card for the Dashboard
class PrayerTimesMiniCard extends StatefulWidget {
  const PrayerTimesMiniCard({super.key});

  @override
  State<PrayerTimesMiniCard> createState() => _PrayerTimesMiniCardState();
}

class _PrayerTimesMiniCardState extends State<PrayerTimesMiniCard>
    with SingleTickerProviderStateMixin {
  final PrayerTimesService _service = PrayerTimesService();
  Map<String, DateTime>? _times;
  String _locationName = '...';
  bool _loading = true;
  Timer? _timer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // Prayer display order + icons
  static const _prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
  static const _icons = [
    Icons.wb_twilight,
    Icons.wb_sunny,
    Icons.brightness_6,
    Icons.water_drop_outlined,
    Icons.nightlight,
  ];
  static const _colors = [
    Color(0xFF7E57C2),
    Color(0xFFFF9800),
    Color(0xFFFF5722),
    Color(0xFFE91E63),
    Color(0xFF1E88E5),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _load();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final pos = await _service.getCurrentLocationSafe();
      final times = await _service.getPrayerTimes(
        date: DateTime.now(),
        latitude: pos.latitude,
        longitude: pos.longitude,
      );
      final loc = await _service.getLocationName(pos.latitude, pos.longitude);
      if (mounted) {
        setState(() {
          _times = times;
          _locationName = loc;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _nextPrayer {
    if (_times == null) return 'Fajr';
    final now = DateTime.now();
    for (final p in _prayers) {
      final t = _times![p];
      if (t != null && t.isAfter(now)) return p;
    }
    return _prayers.first;
  }

  String _countdown(DateTime t) {
    final diff = t.difference(DateTime.now());
    if (diff.isNegative) return 'Passed';
    if (diff.inHours > 0) return '${diff.inHours}h ${diff.inMinutes % 60}m';
    return '${diff.inMinutes}m left';
  }

  String _fmt(DateTime t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return GlassCard(
        padding: const EdgeInsets.all(16),
        child: const SizedBox(
          height: 80,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      );
    }

    if (_times == null) return const SizedBox.shrink();

    final next = _nextPrayer;
    final nextTime = _times![next]!;
    final nextIdx = _prayers.indexOf(next);
    final nextColor = nextIdx >= 0 ? _colors[nextIdx] : primary;

    return GlassCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.location_on, size: 14, color: primary),
              const SizedBox(width: 4),
              Text(
                _locationName,
                style: TextStyle(
                  fontSize: 12,
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Prayer Times',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Next Prayer highlight
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [nextColor, nextColor.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: nextColor.withOpacity(0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Pulsing icon
                AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (_, __) => Transform.scale(
                    scale: _pulseAnim.value,
                    child: Icon(
                      nextIdx >= 0 ? _icons[nextIdx] : Icons.access_time,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next: $next',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _fmt(nextTime),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _countdown(nextTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // All prayers horizontal scroll
          SizedBox(
            height: 66,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _prayers.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final p = _prayers[i];
                final t = _times![p];
                final isNext = p == next;
                final col = _colors[i];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 70,
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  decoration: BoxDecoration(
                    color: isNext
                        ? col.withOpacity(0.15)
                        : (isDark
                            ? Colors.white.withOpacity(0.05)
                            : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNext ? col : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_icons[i],
                          size: 14, color: isNext ? col : Colors.grey),
                      const SizedBox(height: 2),
                      Text(
                        p,
                        style: TextStyle(
                          fontSize: 9,
                          height: 1,
                          fontWeight:
                              isNext ? FontWeight.bold : FontWeight.normal,
                          color: isNext ? col : Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        t != null ? _fmt(t) : '--:--',
                        style: TextStyle(
                          fontSize: 10,
                          height: 1,
                          fontWeight: FontWeight.w600,
                          color: isNext ? col : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
