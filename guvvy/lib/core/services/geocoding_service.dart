// lib/core/services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guvvy/core/services/api_keys.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';
import 'package:guvvy/core/config/app_config.dart';

class GeocodingService {
  static final _client = http.Client();
  static const _mockEnabled = AppConfig.environment == 'development';
  
  // Get place suggestions based on user input
  static Future<List<GeocodingResult>> searchAddressSuggestions(String query) async {
    if (query.isEmpty) return [];
    
    // Use mock data in development if API key isn't configured
    if (_mockEnabled && ApiKeys.googleMapsKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate network delay
      return _getMockSuggestions(query);
    }
    
    try {
      final response = await _client.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '?types=address'
          '&components=country:us'
          '&key=${ApiKeys.googleMapsKey}'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final List<dynamic> predictions = data['predictions'];
          
          return predictions.map((prediction) {
            final structured = prediction['structured_formatting'];
            return GeocodingResult(
              placeId: prediction['place_id'],
              description: prediction['description'],
              primaryText: structured['main_text'] ?? prediction['description'],
              secondaryText: structured['secondary_text'] ?? '',
            );
          }).toList();
        } else if (data['status'] == 'ZERO_RESULTS') {
          return [];
        } else {
          throw Exception('Place autocomplete error: ${data['status']}');
        }
      } else {
        throw Exception('Network error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if there's an error and we're in development
      if (_mockEnabled) {
        return _getMockSuggestions(query);
      }
      throw Exception('Failed to get address suggestions: $e');
    }
  }
  
  // Get coordinates for a place ID
  static Future<Location> getCoordinatesForPlace(String placeId) async {
    // Use mock data in development if API key isn't configured
    if (_mockEnabled && ApiKeys.googleMapsKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      return _getMockLocationForPlaceId(placeId);
    }
    
    try {
      final response = await _client.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&fields=geometry,formatted_address'
          '&key=${ApiKeys.googleMapsKey}'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['result'] != null) {
          final result = data['result'];
          final location = result['geometry']['location'];
          
          return Location(
            latitude: location['lat'],
            longitude: location['lng'],
            formattedAddress: result['formatted_address'],
          );
        } else {
          throw Exception('Place details error: ${data['status']}');
        }
      } else {
        throw Exception('Network error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if there's an error and we're in development
      if (_mockEnabled) {
        return _getMockLocationForPlaceId(placeId);
      }
      throw Exception('Failed to get coordinates: $e');
    }
  }
  
  // Get coordinates for an address string
  static Future<Location> getCoordinatesForAddress(String address) async {
    // Use mock data in development if API key isn't configured
    if (_mockEnabled && ApiKeys.googleMapsKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      return _getMockLocationForAddress(address);
    }
    
    try {
      final response = await _client.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?address=${Uri.encodeComponent(address)}'
          '&components=country:us'
          '&key=${ApiKeys.googleMapsKey}'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];
          
          return Location(
            latitude: location['lat'],
            longitude: location['lng'],
            formattedAddress: result['formatted_address'],
          );
        } else {
          throw Exception('Geocoding error: ${data['status']}');
        }
      } else {
        throw Exception('Network error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if there's an error and we're in development
      if (_mockEnabled) {
        return _getMockLocationForAddress(address);
      }
      throw Exception('Failed to get coordinates: $e');
    }
  }
  
  // Reverse geocoding (coordinates to address)
  static Future<String> getAddressForCoordinates(double latitude, double longitude) async {
    // Use mock data in development if API key isn't configured
    if (_mockEnabled && ApiKeys.googleMapsKey.isEmpty) {
      await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
      return _getMockAddressForCoordinates(latitude, longitude);
    }
    
    try {
      final response = await _client.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json'
          '?latlng=$latitude,$longitude'
          '&key=${ApiKeys.googleMapsKey}'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        } else {
          throw Exception('Reverse geocoding error: ${data['status']}');
        }
      } else {
        throw Exception('Network error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data if there's an error and we're in development
      if (_mockEnabled) {
        return _getMockAddressForCoordinates(latitude, longitude);
      }
      throw Exception('Failed to get address: $e');
    }
  }
  
  // ====== Mock data methods for development ======
  
  // Mock address suggestions
  static List<GeocodingResult> _getMockSuggestions(String query) {
    final List<GeocodingResult> allSuggestions = [
      GeocodingResult(
        placeId: 'mock-1',
        description: '1600 Pennsylvania Avenue NW, Washington, DC 20500, USA',
        primaryText: '1600 Pennsylvania Avenue NW',
        secondaryText: 'Washington, DC 20500, USA',
      ),
      GeocodingResult(
        placeId: 'mock-2',
        description: '350 Fifth Avenue, New York, NY 10118, USA',
        primaryText: '350 Fifth Avenue',
        secondaryText: 'New York, NY 10118, USA',
      ),
      GeocodingResult(
        placeId: 'mock-3',
        description: '221B Baker Street, London, UK',
        primaryText: '221B Baker Street',
        secondaryText: 'London, UK',
      ),
      GeocodingResult(
        placeId: 'mock-4',
        description: '1 Infinite Loop, Cupertino, CA 95014, USA',
        primaryText: '1 Infinite Loop',
        secondaryText: 'Cupertino, CA 95014, USA',
      ),
      GeocodingResult(
        placeId: 'mock-5',
        description: '1 Microsoft Way, Redmond, WA 98052, USA',
        primaryText: '1 Microsoft Way',
        secondaryText: 'Redmond, WA 98052, USA',
      ),
    ];
    
    // Filter suggestions based on query
    if (query.isEmpty) return [];
    
    query = query.toLowerCase();
    return allSuggestions
        .where((s) => s.description.toLowerCase().contains(query))
        .toList();
  }
  
  // Mock location for place ID
  static Location _getMockLocationForPlaceId(String placeId) {
    switch (placeId) {
      case 'mock-1': // White House
        return const Location(
          latitude: 38.8977,
          longitude: -77.0365,
          formattedAddress: '1600 Pennsylvania Avenue NW, Washington, DC 20500, USA',
        );
      case 'mock-2': // Empire State Building
        return const Location(
          latitude: 40.7484,
          longitude: -73.9857,
          formattedAddress: '350 Fifth Avenue, New York, NY 10118, USA',
        );
      case 'mock-3': // Sherlock Holmes
        return const Location(
          latitude: 51.5237,
          longitude: -0.1585,
          formattedAddress: '221B Baker Street, London, UK',
        );
      case 'mock-4': // Apple
        return const Location(
          latitude: 37.3318,
          longitude: -122.0312,
          formattedAddress: '1 Infinite Loop, Cupertino, CA 95014, USA',
        );
      case 'mock-5': // Microsoft
        return const Location(
          latitude: 47.6423,
          longitude: -122.1392,
          formattedAddress: '1 Microsoft Way, Redmond, WA 98052, USA',
        );
      default:
        // Default to San Francisco
        return const Location(
          latitude: 37.7749,
          longitude: -122.4194,
          formattedAddress: 'San Francisco, CA, USA',
        );
    }
  }
  
  // Mock location for address string
  static Location _getMockLocationForAddress(String address) {
    address = address.toLowerCase();
    
    // Check for known addresses in our mock data
    if (address.contains('white house') || address.contains('pennsylvania avenue')) {
      return const Location(
        latitude: 38.8977,
        longitude: -77.0365,
        formattedAddress: '1600 Pennsylvania Avenue NW, Washington, DC 20500, USA',
      );
    } else if (address.contains('empire state') || address.contains('fifth avenue')) {
      return const Location(
        latitude: 40.7484,
        longitude: -73.9857,
        formattedAddress: '350 Fifth Avenue, New York, NY 10118, USA',
      );
    } else if (address.contains('baker street')) {
      return const Location(
        latitude: 51.5237,
        longitude: -0.1585,
        formattedAddress: '221B Baker Street, London, UK',
      );
    } else if (address.contains('apple') || address.contains('infinite loop')) {
      return const Location(
        latitude: 37.3318,
        longitude: -122.0312,
        formattedAddress: '1 Infinite Loop, Cupertino, CA 95014, USA',
      );
    } else if (address.contains('microsoft')) {
      return const Location(
        latitude: 47.6423,
        longitude: -122.1392,
        formattedAddress: '1 Microsoft Way, Redmond, WA 98052, USA',
      );
    } else {
      // Default to San Francisco
      return const Location(
        latitude: 37.7749,
        longitude: -122.4194,
        formattedAddress: 'San Francisco, CA, USA',
      );
    }
  }
  
  // Mock address for coordinates
  static String _getMockAddressForCoordinates(double latitude, double longitude) {
    // White House
    if (_isNearCoordinate(latitude, longitude, 38.8977, -77.0365, 0.01)) {
      return '1600 Pennsylvania Avenue NW, Washington, DC 20500, USA';
    }
    // Empire State Building
    else if (_isNearCoordinate(latitude, longitude, 40.7484, -73.9857, 0.01)) {
      return '350 Fifth Avenue, New York, NY 10118, USA';
    }
    // Sherlock Holmes
    else if (_isNearCoordinate(latitude, longitude, 51.5237, -0.1585, 0.01)) {
      return '221B Baker Street, London, UK';
    }
    // Apple
    else if (_isNearCoordinate(latitude, longitude, 37.3318, -122.0312, 0.01)) {
      return '1 Infinite Loop, Cupertino, CA 95014, USA';
    }
    // Microsoft
    else if (_isNearCoordinate(latitude, longitude, 47.6423, -122.1392, 0.01)) {
      return '1 Microsoft Way, Redmond, WA 98052, USA';
    }
    // US Capitol
    else if (_isNearCoordinate(latitude, longitude, 38.8899, -77.0091, 0.01)) {
      return 'First St SE, Washington, DC 20004, USA';
    }
    // Generic format for other locations
    else {
      return 'Latitude: ${latitude.toStringAsFixed(4)}, Longitude: ${longitude.toStringAsFixed(4)}';
    }
  }
  
  // Helper to check if coordinates are near each other
  static bool _isNearCoordinate(
    double lat1, 
    double lng1, 
    double lat2, 
    double lng2, 
    double tolerance
  ) {
    return (lat1 - lat2).abs() < tolerance && (lng1 - lng2).abs() < tolerance;
  }
}

class GeocodingResult {
  final String placeId;
  final String description;
  final String primaryText;
  final String secondaryText;
  
  GeocodingResult({
    required this.placeId,
    required this.description,
    required this.primaryText,
    required this.secondaryText,
  });
}