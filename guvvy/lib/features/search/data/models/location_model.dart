// lib/features/search/data/models/location_model.dart
import 'package:guvvy/features/search/domain/entities/location.dart';

class LocationModel extends Location {
  const LocationModel({
    required double latitude,
    required double longitude,
    String? formattedAddress,
  }) : super(
          latitude: latitude,
          longitude: longitude,
          formattedAddress: formattedAddress,
        );

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      formattedAddress: json['formattedAddress'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'formattedAddress': formattedAddress,
    };
  }
}