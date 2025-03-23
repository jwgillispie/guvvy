// lib/core/services/api_keys.dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiKeys {
  static String get googleMapsKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get openStatesKey => dotenv.env['OPEN_STATES_API_KEY'] ?? '';
  
  // Helper to check if keys are configured
  static bool get isConfigured => 
      googleMapsKey.isNotEmpty && openStatesKey.isNotEmpty;
}