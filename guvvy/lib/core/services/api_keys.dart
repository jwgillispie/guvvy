// Update this in lib/core/services/api_keys.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  // Adds validation and debug output
  static String get googleMapsKey {
    final key = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
    if (key.isEmpty) {
      print('WARNING: GOOGLE_MAPS_API_KEY is not set in .env file');
    } else {
      print('Google Maps API key successfully loaded');
    }
    return key;
  }
  
  static String get openStatesKey {
    final key = dotenv.env['OPEN_STATES_API_KEY'] ?? '';
    if (key.isEmpty) {
      print('WARNING: OPEN_STATES_API_KEY is not set in .env file');
    }
    return key;
  }
  
  // Helper to check if keys are configured
  static bool get isConfigured {
    final hasMapsKey = googleMapsKey.isNotEmpty;
    final hasStatesKey = openStatesKey.isNotEmpty;
    
    print('API Keys configured: Google Maps ($hasMapsKey), Open States ($hasStatesKey)');
    return hasMapsKey && hasStatesKey;
  }
}