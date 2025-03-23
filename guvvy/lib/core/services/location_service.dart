// lib/core/services/location_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';

class LocationService {
  // Get current user location
  static Future<Location> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }
      
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      // Convert to our Location model
      return Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      throw Exception('Could not get current location: $e');
    }
  }
}