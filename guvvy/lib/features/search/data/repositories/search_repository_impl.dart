// lib/features/search/data/repositories/search_repository_impl.dart
import 'dart:convert';
import 'package:guvvy/features/search/data/models/search_history_item_model.dart';
import 'package:guvvy/features/search/domain/search_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';
import 'package:guvvy/features/search/domain/entities/search_history_item.dart';


class SearchRepositoryImpl implements SearchRepository {
  static const String _historyKey = 'SEARCH_HISTORY';
  final SharedPreferences sharedPreferences;
  
  SearchRepositoryImpl({
    required this.sharedPreferences,
  });

  @override
  Future<Location> geocodeAddress(String address) async {
    // In a real app, you would use a geocoding service like Google Maps API
    // For now, we'll return mock data
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock coordinates for the address
    // In a real implementation, this would come from an API
    return Location(
      latitude: 37.7749, 
      longitude: -122.4194,
      formattedAddress: address,
    );
  }

  @override
  Future<void> saveSearchToHistory({
    required String address,
    required Location location,
  }) async {
    final history = await getSearchHistory();
    
    // Create a new history item
    final newItem = SearchHistoryItemModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      address: address,
      location: location,
      timestamp: DateTime.now(),
    );
    
    // Add to history (at the beginning)
    history.insert(0, newItem);
    
    // Limit history to 10 items
    if (history.length > 10) {
      history.removeLast();
    }
    
    // Convert to JSON and save
    final jsonList = history.map((item) {
      if (item is SearchHistoryItemModel) {
        return item.toJson();
      } else {
        // Convert the entity to a model for serialization
        return SearchHistoryItemModel(
          id: item.id,
          address: item.address,
          location: item.location,
          timestamp: item.timestamp,
        ).toJson();
      }
    }).toList();
    
    await sharedPreferences.setString(
      _historyKey,
      jsonEncode(jsonList),
    );
  }

  @override
  Future<List<SearchHistoryItem>> getSearchHistory() async {
    final jsonString = sharedPreferences.getString(_historyKey);
    
    if (jsonString == null) {
      return [];
    }
    
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList
          .map((json) => SearchHistoryItemModel.fromJson(json))
          .toList();
    } catch (e) {
      // Handle parsing errors
      return [];
    }
  }

  @override
  Future<void> deleteSearchHistoryItem(String id) async {
    final history = await getSearchHistory();
    final updatedHistory = history.where((item) => item.id != id).toList();
    
    final jsonList = updatedHistory.map((item) {
      if (item is SearchHistoryItemModel) {
        return item.toJson();
      } else {
        return SearchHistoryItemModel(
          id: item.id,
          address: item.address,
          location: item.location,
          timestamp: item.timestamp,
        ).toJson();
      }
    }).toList();
    
    await sharedPreferences.setString(
      _historyKey,
      jsonEncode(jsonList),
    );
  }

  @override
  Future<void> clearSearchHistory() async {
    await sharedPreferences.remove(_historyKey);
  }
}