import 'package:geolocator/geolocator.dart';
import 'dart:math' as math;

/// Qibla direction service with accurate worldwide calculations
class QiblaService {
  static final QiblaService _instance = QiblaService._internal();
  factory QiblaService() => _instance;
  QiblaService._internal();

  // Kaaba coordinates (verified accurate coordinates)
  static const double kaabaLatitude = 21.4225241;
  static const double kaabaLongitude = 39.8261818;
  
  // Earth radius in kilometers
  static const double earthRadius = 6371.0;

  /// Calculate Qibla direction using great circle bearing formula
  /// This works accurately anywhere on Earth
  double calculateQiblaDirection(double latitude, double longitude) {
    // Convert to radians
    final lat1 = _degreesToRadians(latitude);
    final lat2 = _degreesToRadians(kaabaLatitude);
    final lon1 = _degreesToRadians(longitude);
    final lon2 = _degreesToRadians(kaabaLongitude);
    
    final deltaLon = lon2 - lon1;
    
    // Great circle bearing formula (accurate for all locations)
    // Formula: θ = atan2(sin(Δlong)⋅cos(lat2), cos(lat1)⋅sin(lat2) − sin(lat1)⋅cos(lat2)⋅cos(Δlong))
    final y = math.sin(deltaLon) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) - 
              math.sin(lat1) * math.cos(lat2) * math.cos(deltaLon);
    
    // Calculate bearing in radians
    final bearingRad = math.atan2(y, x);
    
    // Convert to degrees and normalize to 0-360
    final bearingDeg = _radiansToDegrees(bearingRad);
    final normalizedBearing = (bearingDeg + 360) % 360;
    
    return normalizedBearing;
  }
  
  /// Get distance to Kaaba using Haversine formula (accurate for spherical Earth)
  double getDistanceToKaaba(double latitude, double longitude) {
    // Using geolocator's built-in Haversine formula which is accurate
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      kaabaLatitude,
      kaabaLongitude,
    ) / 1000; // Convert to kilometers
  }
  
  /// Alternative: Calculate distance using Haversine formula manually
  /// This gives the great circle distance between two points
  double calculateDistanceHaversine(double lat1, double lon1, double lat2, double lon2) {
    final lat1Rad = _degreesToRadians(lat1);
    final lat2Rad = _degreesToRadians(lat2);
    final deltaLat = _degreesToRadians(lat2 - lat1);
    final deltaLon = _degreesToRadians(lon2 - lon1);
    
    final a = math.sin(deltaLat / 2) * math.sin(deltaLat / 2) +
              math.cos(lat1Rad) * math.cos(lat2Rad) *
              math.sin(deltaLon / 2) * math.sin(deltaLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadius * c; // Distance in kilometers
  }
  
  /// Convert degrees to radians
  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180.0;
  }
  
  /// Convert radians to degrees
  double _radiansToDegrees(double radians) {
    return radians * 180.0 / math.pi;
  }
  
  /// Get cardinal direction name from bearing
  String getCardinalDirection(double bearing) {
    const directions = [
      'N', 'NNE', 'NE', 'ENE', 'E', 'ESE', 'SE', 'SSE',
      'S', 'SSW', 'SW', 'WSW', 'W', 'WNW', 'NW', 'NNW'
    ];
    final index = ((bearing + 11.25) / 22.5).floor() % 16;
    return directions[index];
  }

  /// Check if device has compass support
  Future<bool> hasCompass() async {
    // Check if device supports compass
    // This is a placeholder - actual implementation depends on sensor support
    return true;
  }
}
