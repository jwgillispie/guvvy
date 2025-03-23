// lib/core/services/permissions_service.dart
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  // Check if location permission is granted
  static Future<bool> checkLocationPermission(BuildContext context) async {
    final status = await Permission.location.status;
    
    if (status.isGranted) {
      return true;
    }
    
    // If permission is denied but can be requested
    if (status.isDenied) {
      return _requestLocationPermission(context);
    }
    
    // If permission is permanently denied
    if (status.isPermanentlyDenied) {
      _showPermanentlyDeniedDialog(context);
      return false;
    }
    
    return false;
  }
  
  // Request location permission
  static Future<bool> _requestLocationPermission(BuildContext context) async {
    final status = await Permission.location.request();
    return status.isGranted;
  }
  
  // Show dialog when permission is permanently denied
  static void _showPermanentlyDeniedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
          'Location permission is required to find representatives in your area. '
          'Please enable location in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
}