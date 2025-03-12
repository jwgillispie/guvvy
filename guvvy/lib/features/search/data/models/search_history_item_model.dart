// lib/features/search/data/models/search_history_item_model.dart
import 'package:guvvy/features/search/domain/entities/search_history_item.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';
import 'package:guvvy/features/search/data/models/location_model.dart';

class SearchHistoryItemModel extends SearchHistoryItem {
  const SearchHistoryItemModel({
    required String id,
    required String address,
    required Location location,
    required DateTime timestamp,
  }) : super(
          id: id,
          address: address,
          location: location,
          timestamp: timestamp,
        );

  factory SearchHistoryItemModel.fromJson(Map<String, dynamic> json) {
    return SearchHistoryItemModel(
      id: json['id'],
      address: json['address'],
      location: LocationModel.fromJson(json['location']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'location': location is LocationModel
          ? (location as LocationModel).toJson()
          : LocationModel(
              latitude: location.latitude,
              longitude: location.longitude,
              formattedAddress: location.formattedAddress,
            ).toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }
}