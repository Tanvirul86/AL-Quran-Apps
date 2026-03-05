import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'dart:math' as math;
import '../services/qibla_service.dart';
import '../services/prayer_times_service.dart';

class QiblaCompassScreen extends StatefulWidget {
  const QiblaCompassScreen({super.key});

  @override
  State<QiblaCompassScreen> createState() => _QiblaCompassScreenState();
}

class _QiblaCompassScreenState extends State<QiblaCompassScreen> 
    with SingleTickerProviderStateMixin {
  final QiblaService _qiblaService = QiblaService();
  final PrayerTimesService _locationService = PrayerTimesService();
  
  double _qiblaDirection = 0.0;
  double _deviceHeading = 0.0;
  double _smoothedHeading = 0.0;
  double? _latitude;
  double? _longitude;
  String? _locationName;
  double? _distanceToKaaba;
  bool _isLoading = true;
  String? _error;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  
  // For smoothing the compass
  List<double> _headingHistory = [];
  static const int _smoothingFactor = 10;
  
  // Accelerometer values for tilt compensation
  double _ax = 0, _ay = 0, _az = 0;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _startCompass();
  }

  @override
  void dispose() {
    _magnetometerSubscription?.cancel();
    _accelerometerSubscription?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final position = await _locationService.getCurrentLocation();
      final locationName = await _locationService.getLocationName(
        position.latitude,
        position.longitude,
      );
      final qiblaDirection = _qiblaService.calculateQiblaDirection(
        position.latitude,
        position.longitude,
      );
      final distance = _qiblaService.getDistanceToKaaba(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _locationName = locationName;
        _qiblaDirection = qiblaDirection;
        _distanceToKaaba = distance;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  void _startCompass() {
    // Listen to accelerometer for tilt compensation
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      _ax = event.x;
      _ay = event.y;
      _az = event.z;
    });
    
    // Listen to magnetometer for heading
    _magnetometerSubscription = magnetometerEventStream().listen((event) {
      // Get raw magnetometer readings
      final mx = event.x;
      final my = event.y;
      final mz = event.z;
      
      // Normalize accelerometer values
      final accelNorm = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
      if (accelNorm == 0) return; // Avoid division by zero
      
      final ax = _ax / accelNorm;
      final ay = _ay / accelNorm;
      final az = _az / accelNorm;
      
      // Tilt compensation using rotation matrix method
      // This properly compensates for device tilt in 3D space
      final pitch = math.asin(-ax);
      final roll = math.atan2(ay, az);
      
      // Compensate magnetic field for tilt
      final magX = mx * math.cos(pitch) + 
                   mz * math.sin(pitch);
      final magY = mx * math.sin(roll) * math.sin(pitch) + 
                   my * math.cos(roll) - 
                   mz * math.sin(roll) * math.cos(pitch);
      
      // Calculate heading (azimuth) from compensated magnetic field
      // Heading is in degrees clockwise from North
      double heading = math.atan2(magY, magX) * 180 / math.pi;
      
      // Normalize to 0-360 degrees
      heading = (heading + 360) % 360;
      
      // Apply smoothing using circular mean (proper for angular values)
      _headingHistory.add(heading);
      if (_headingHistory.length > _smoothingFactor) {
        _headingHistory.removeAt(0);
      }
      
      // Calculate circular mean for smooth rotation
      double sinSum = 0, cosSum = 0;
      for (final h in _headingHistory) {
        final radians = h * math.pi / 180;
        sinSum += math.sin(radians);
        cosSum += math.cos(radians);
      }
      
      final avgHeading = math.atan2(sinSum / _headingHistory.length, 
                                     cosSum / _headingHistory.length) * 180 / math.pi;
      
      setState(() {
        _deviceHeading = heading;
        _smoothedHeading = (avgHeading + 360) % 360;
      });
    });
  }

  double _getQiblaAngle() {
    // Calculate the angle to rotate the Qibla indicator
    return (_qiblaDirection - _smoothedHeading + 360) % 360;
  }
  
  bool _isPointingToQibla() {
    final angle = _getQiblaAngle();
    // Consider pointing to Qibla if within ±5 degrees (tighter tolerance)
    return angle.abs() < 5 || (360 - angle).abs() < 5;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qibla Compass'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeLocation,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your location...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Unable to get location',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: _initializeLocation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Qibla direction info
                      Card(
                        margin: const EdgeInsets.all(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on, color: Colors.green),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Your Location',
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
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.mosque, color: Colors.amber),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Distance to Kaaba',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        Text(
                                          _distanceToKaaba != null
                                              ? '${_distanceToKaaba!.toStringAsFixed(1)} km'
                                              : 'Unknown',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'Qibla Direction',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        '${_qiblaDirection.toStringAsFixed(1)}°',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Compass
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: _buildCompass(),
                      ),
                      
                      // Status indicator
                      if (_isPointingToQibla())
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green, width: 2),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.check_circle, color: Colors.green, size: 28),
                              SizedBox(width: 12),
                              Text(
                                'You are facing Qibla!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Instructions
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'How to use',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildInstruction(
                                  Icons.mosque,
                                  Colors.green,
                                  'Kaaba icon shows Qibla direction',
                                ),
                                const SizedBox(height: 8),
                                _buildInstruction(
                                  Icons.smartphone,
                                  Colors.blue,
                                  'Hold phone flat and rotate until Kaaba is at top',
                                ),
                                const SizedBox(height: 8),
                                _buildInstruction(
                                  Icons.warning_amber,
                                  Colors.orange,
                                  'Keep away from metal objects for accuracy',
                                ),
                                const SizedBox(height: 8),
                                _buildInstruction(
                                  Icons.refresh,
                                  Colors.purple,
                                  'If compass seems stuck, wave phone in figure-8 pattern to calibrate',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
  
  Widget _buildInstruction(IconData icon, Color color, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildCompass() {
    final qiblaAngle = _getQiblaAngle();
    final isOnTarget = _isPointingToQibla();
    
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ring with gradient
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[100]!,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          
          // Inner compass circle
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isOnTarget ? Colors.green : Colors.grey[300]!,
                width: 3,
              ),
            ),
          ),
          
          // Compass rose (rotates with device)
          Transform.rotate(
            angle: -_smoothedHeading * math.pi / 180,
            child: CustomPaint(
              size: const Size(240, 240),
              painter: CompassPainter(),
            ),
          ),
          
          // Qibla indicator (Kaaba icon)
          Transform.rotate(
            angle: qiblaAngle * math.pi / 180,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isOnTarget ? Colors.green : Colors.green[700],
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mosque,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Container(
                  width: 4,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green[700]!, Colors.green[300]!],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          
          // Center circle
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).primaryColor,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
          
          // North indicator (fixed at top)
          Positioned(
            top: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'N',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = Colors.grey[400]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw cardinal directions
    final directions = ['N', 'E', 'S', 'W'];
    final directionColors = [Colors.red, Colors.black, Colors.black, Colors.black];
    final angles = [0, 90, 180, 270];

    for (int i = 0; i < directions.length; i++) {
      final angle = angles[i] * math.pi / 180;
      final x = center.dx + (radius - 25) * math.sin(angle);
      final y = center.dy - (radius - 25) * math.cos(angle);

      final textPainter = TextPainter(
        text: TextSpan(
          text: directions[i],
          style: TextStyle(
            color: directionColors[i],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // Draw degree markers
    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      double startRadius, endRadius;
      
      if (i % 90 == 0) {
        startRadius = radius - 18;
        endRadius = radius - 5;
        paint.strokeWidth = 2;
        paint.color = Colors.grey[600]!;
      } else if (i % 30 == 0) {
        startRadius = radius - 12;
        endRadius = radius - 5;
        paint.strokeWidth = 1.5;
        paint.color = Colors.grey[500]!;
      } else {
        startRadius = radius - 8;
        endRadius = radius - 5;
        paint.strokeWidth = 1;
        paint.color = Colors.grey[400]!;
      }

      canvas.drawLine(
        Offset(
          center.dx + startRadius * math.sin(angle),
          center.dy - startRadius * math.cos(angle),
        ),
        Offset(
          center.dx + endRadius * math.sin(angle),
          center.dy - endRadius * math.cos(angle),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
