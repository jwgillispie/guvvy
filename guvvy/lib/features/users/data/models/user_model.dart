// lib/features/user/data/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guvvy/features/users/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    String? firstName,
    String? lastName,
    Address? address,
    required List<String> districtIds,
    required DateTime createdAt,
    required DateTime updatedAt,
    required DateTime lastLoginAt,
  }) : super(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    address: address,
    districtIds: districtIds,
    createdAt: createdAt,
    updatedAt: updatedAt,
    lastLoginAt: lastLoginAt,
  );
  
  // CopyWith method to create a new instance with updated fields
  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    Address? address,
    List<String>? districtIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      address: address ?? this.address,
      districtIds: districtIds ?? this.districtIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  // Create a UserModel from a JSON map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      address: json['address'] != null 
          ? AddressModel.fromJson(json['address']) 
          : null,
      districtIds: List<String>.from(json['districtIds'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      updatedAt: (json['updatedAt'] as Timestamp).toDate(),
      lastLoginAt: (json['lastLoginAt'] as Timestamp).toDate(),
    );
  }

  // Convert a UserModel to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'address': address != null 
          ? (address as AddressModel).toJson() 
          : null,
      'districtIds': districtIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
    };
  }
}

class AddressModel extends Address {
  const AddressModel({
    required String street,
    required String city,
    required String state,
    required String zipCode,
    CoordinatesModel? coordinates,
  }) : super(
    street: street,
    city: city,
    state: state,
    zipCode: zipCode,
    coordinates: coordinates,
  );

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      street: json['street'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zipCode'] as String,
      coordinates: json['coordinates'] != null 
          ? CoordinatesModel.fromJson(json['coordinates']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'zipCode': zipCode,
      'coordinates': coordinates != null 
          ? (coordinates as CoordinatesModel).toJson() 
          : null,
    };
  }
}

class CoordinatesModel extends Coordinates {
  const CoordinatesModel({
    required double latitude,
    required double longitude,
  }) : super(
    latitude: latitude,
    longitude: longitude,
  );

  factory CoordinatesModel.fromJson(Map<String, dynamic> json) {
    return CoordinatesModel(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

