// lib/core/services/geocoding_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:guvvy/core/services/api_keys.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';

class GeocodingService {
  static final _client = http.Client();
  
  // Get place suggestions based on user input
  static Future<List<GeocodingResult>> searchAddressSuggestions(String query) async {
    if (query.isEmpty) return [];
    
    try {
      final response = await _client.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(query)}'
          '&types=address'
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
        } else {
          throw Exception('Place autocomplete error: ${data['status']}');
        }
      } else {
        throw Exception('Network error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to get address suggestions: $e');
    }
  }
  
  // Get coordinates for a place ID
  static Future<Location> getCoordinatesForPlace(String placeId) async {
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
      throw Exception('Failed to get coordinates: $e');
    }
  }
  
  // Get coordinates for an address string
  static Future<Location> getCoordinatesForAddress(String address) async {
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
      throw Exception('Failed to get coordinates: $e');
    }
  }
  
  // Reverse geocoding (coordinates to address)
  static Future<String> getAddressForCoordinates(double latitude, double longitude) async {
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
      throw Exception('Failed to get address: $e');
    }
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