// lib/features/user/domain/entities/user.dart
import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final Address? address;
  final List<String> districtIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLoginAt;

  const User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.address,
    required this.districtIds,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLoginAt,
  });

  @override
  List<Object?> get props => [
    id, 
    email, 
    firstName, 
    lastName, 
    address, 
    districtIds, 
    createdAt, 
    updatedAt, 
    lastLoginAt
  ];
}

class Address extends Equatable {
  final String street;
  final String city;
  final String state;
  final String zipCode;
  final Coordinates? coordinates;

  const Address({
    required this.street,
    required this.city,
    required this.state,
    required this.zipCode,
    this.coordinates,
  });
  
  // Method to convert Address to JSON
  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'coordinates': coordinates?.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    street, 
    city, 
    state, 
    zipCode, 
    coordinates
  ];
}

class Coordinates extends Equatable {
  final double latitude;
  final double longitude;

  const Coordinates({
    required this.latitude,
    required this.longitude,
  });
  
  // Method to convert Coordinates to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  @override
  List<Object?> get props => [latitude, longitude];
}