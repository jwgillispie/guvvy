// lib/features/search/domain/repositories/search_repository.dart
import 'package:guvvy/features/search/domain/entities/location.dart';
import 'package:guvvy/features/search/domain/entities/search_history_item.dart';

abstract class SearchRepository {
  /// Converts an address string to geographic coordinates
  Future<Location> geocodeAddress(String address);
  
  /// Saves a search to the search history
  Future<void> saveSearchToHistory({
    required String address,
    required Location location,
  });
  
  /// Retrieves the search history
  Future<List<SearchHistoryItem>> getSearchHistory();
  
  /// Deletes a specific search history item
  Future<void> deleteSearchHistoryItem(String id);
  
  /// Clears all search history
  Future<void> clearSearchHistory();
}