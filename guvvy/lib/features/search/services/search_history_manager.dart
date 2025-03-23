// lib/features/search/services/search_history_manager.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryItem {
  final String id;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  
  SearchHistoryItem({
    required this.id,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory SearchHistoryItem.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItem(
      id: json['id'],
      address: json['address'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class SearchHistoryManager {
  static const String _prefsKey = 'SEARCH_HISTORY';
  static const int _maxHistoryItems = 10;
  
  // In-memory cache during app lifecycle
  static List<SearchHistoryItem> _cachedHistory = [];
  static bool _initialized = false;
  
  // Save a search to history
  static Future<void> saveSearch({
    required String address,
    required double latitude,
    required double longitude,
  }) async {
    await _ensureInitialized();
    
    // Create new history item
    final newItem = SearchHistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: address,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
    );
    
    // Remove duplicate addresses
    _cachedHistory.removeWhere((item) => 
      item.address.toLowerCase() == address.toLowerCase());
    
    // Add to the beginning of the list
    _cachedHistory.insert(0, newItem);
    
    // Trim to max history size
    if (_cachedHistory.length > _maxHistoryItems) {
      _cachedHistory = _cachedHistory.sublist(0, _maxHistoryItems);
    }
    
    // Persist to storage
    await _saveToPrefs();
  }
  
  // Get search history
  static Future<List<SearchHistoryItem>> getSearchHistory() async {
    await _ensureInitialized();
    return List.from(_cachedHistory);
  }
  
  // Delete a history item
  static Future<void> deleteHistoryItem(String id) async {
    await _ensureInitialized();
    _cachedHistory.removeWhere((item) => item.id == id);
    await _saveToPrefs();
  }
  
  // Clear all history
  static Future<void> clearHistory() async {
    _cachedHistory = [];
    await _saveToPrefs();
  }
  
  // Make sure the history is loaded from storage
  static Future<void> _ensureInitialized() async {
    if (_initialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_prefsKey);
      
      if (historyJson != null) {
        final List<dynamic> jsonList = json.decode(historyJson);
        _cachedHistory = jsonList
            .map((item) => SearchHistoryItem.fromJson(item))
            .toList();
      }
    } catch (e) {
      // If there's an error, start with empty history
      _cachedHistory = [];
      print('Error loading search history: $e');
    }
    
    _initialized = true;
  }
  
  // Save current history to SharedPreferences
  static Future<void> _saveToPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _cachedHistory.map((item) => item.toJson()).toList();
      await prefs.setString(_prefsKey, json.encode(jsonList));
    } catch (e) {
      print('Error saving search history: $e');
    }
  }
}