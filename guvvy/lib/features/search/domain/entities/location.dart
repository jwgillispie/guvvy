// lib/features/search/domain/entities/location.dart
import 'package:equatable/equatable.dart';

class Location extends Equatable {
  final double latitude;
  final double longitude;
  final String? formattedAddress;

  const Location({
    required this.latitude,
    required this.longitude,
    this.formattedAddress,
  });

  @override
  List<Object?> get props => [latitude, longitude, formattedAddress];
}