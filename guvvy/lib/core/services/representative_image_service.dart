// lib/core/services/representative_image_service.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:guvvy/core/services/api_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RepresentativeImageService {
  // Cache duration
  static const Duration _cacheDuration = Duration(days: 7);
  
  // Image cache keys prefix
  static const String _imageCacheKeyPrefix = 'REP_IMG_';
  
  // Helper function to get Google Custom Search API image for a person
  static Future<String?> getRepresentativeImageUrl(String name, String role) async {
    try {
      // First check cache
      final cachedUrl = await _getCachedImageUrl(name);
      if (cachedUrl != null) {
        return cachedUrl;
      }
      
      // Get API key from environment
      final apiKey = ApiKeys.googleSearchApiKey;
      if (apiKey.isEmpty) {
        return _getFallbackImageUrl(name, role);
      }
      
      // Google Custom Search Engine ID 
      final searchEngineId = ApiKeys.googleSearchEngineId;
      if (searchEngineId.isEmpty) {
        return _getFallbackImageUrl(name, role);
      }
      
      // Create search query - include role for better results
      final query = Uri.encodeComponent('$name $role official portrait');
      
      // Make API request to Google Custom Search API
      final response = await http.get(
        Uri.parse(
          'https://www.googleapis.com/customsearch/v1'
          '?key=$apiKey'
          '&cx=$searchEngineId'
          '&q=$query'
          '&searchType=image'
          '&imgSize=medium'
          '&imgType=face'
          '&num=1'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.containsKey('items') && data['items'].isNotEmpty) {
          final imageUrl = data['items'][0]['link'];
          
          // Cache the URL
          await _cacheImageUrl(name, imageUrl);
          
          return imageUrl;
        }
      }
      
      // If no results, try fallback methods
      return _getFallbackImageUrl(name, role);
    } catch (e) {
      print('Error fetching representative image: $e');
      return _getFallbackImageUrl(name, role);
    }
  }
  
  // Get image from cache
  static Future<String?> _getCachedImageUrl(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _imageCacheKeyPrefix + _normalizeNameForKey(name);
      
      if (prefs.containsKey(key)) {
        final cacheData = json.decode(prefs.getString(key) ?? '{}');
        final timestamp = DateTime.parse(cacheData['timestamp']);
        final now = DateTime.now();
        
        // Check if cache is still valid
        if (now.difference(timestamp) < _cacheDuration) {
          return cacheData['url'];
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting cached image: $e');
      return null;
    }
  }
  
  // Save image URL to cache
  static Future<void> _cacheImageUrl(String name, String url) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _imageCacheKeyPrefix + _normalizeNameForKey(name);
      
      final cacheData = {
        'url': url,
        'timestamp': DateTime.now().toIso8601String()
      };
      
      await prefs.setString(key, json.encode(cacheData));
    } catch (e) {
      print('Error caching image: $e');
    }
  }
  
  // Helper to normalize name for cache key
  static String _normalizeNameForKey(String name) {
    return name.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
  
  // Get a fallback image for the representative
  static String? _getFallbackImageUrl(String name, String role) {
    // First try with UI-Avatars API - generates initials-based avatar
    final initials = _getInitials(name);
    final encodedName = Uri.encodeComponent(name);
    
    // Return a nice looking avatar with initials
    return 'https://ui-avatars.com/api/?name=$encodedName&background=random&color=fff&size=256';
  }
  
  // Extract initials from name
  static String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      return parts[0][0];
    }
    return 'NA';
  }
  
  // Get widget that handles image loading with fallbacks
  static Widget getRepresentativeImage({
    required String name, 
    required String role,
    String? party,
    double radius = 40,
    bool circular = true,
  }) {
    // Choose background color based on party if provided
    Color backgroundColor = _getColorForParty(party);
    
    return FutureBuilder<String?>(
      future: getRepresentativeImageUrl(name, role),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading state with circular progress
          return CircleAvatar(
            radius: radius,
            backgroundColor: backgroundColor,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 2,
            ),
          );
        }
        
        if (snapshot.hasData && snapshot.data != null) {
          // Show the actual image with error handling
          return circular
            ? CircleAvatar(
                radius: radius,
                backgroundColor: backgroundColor,
                backgroundImage: NetworkImage(snapshot.data!),
                onBackgroundImageError: (_, __) {
                  // This callback doesn't return anything - it's an error handler
                  print('Error loading representative image for $name');
                },
                child: Text(
                  _getInitials(name),
                  style: TextStyle(
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  snapshot.data!,
                  width: radius * 2,
                  height: radius * 2,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    // On error, fall back to CircleAvatar with initials
                    return Container(
                      width: radius * 2,
                      height: radius * 2,
                      color: backgroundColor,
                      child: Center(
                        child: Text(
                          _getInitials(name),
                          style: TextStyle(
                            fontSize: radius * 0.6,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
        }
        
        // Fallback to initials avatar if no image URL is available
        return CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          child: Text(
            _getInitials(name),
            style: TextStyle(
              fontSize: radius * 0.6,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
  
  // Helper to determine color based on party
  static Color _getColorForParty(String? party) {
    if (party == null) return Colors.grey;
    
    switch (party.toLowerCase()) {
      case 'democratic':
        return const Color(0xFF3B82F6); // Blue
      case 'republican':
        return const Color(0xFFEF4444); // Red
      case 'independent':
        return const Color(0xFF8B5CF6); // Purple
      default:
        return Colors.grey;
    }
  }
}