// lib/core/config/app_config.dart
import 'package:flutter/foundation.dart';

class AppConfig {
  // Enable/disable API backend usage
  // In production, this would be true to use the MongoDB backend
  // In development, you might switch between implementations
  static const bool useApiBackend = true;
  
  // Feature flags for gradual rollout
  static const bool enableOfflineMode = true;
  static const bool enablePushNotifications = false;
  
  // Environment configuration
  static const String environment = kReleaseMode ? 'production' : 'development';
  
  // Analytics configuration
  static const bool analyticsEnabled = kReleaseMode;
  
  // Cache configuration
  static const Duration cacheDuration = Duration(hours: 1);
}