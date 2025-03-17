// lib/features/user/data/repositories/api_user_repository.dart
import 'dart:convert';
import 'package:guvvy/core/config/api_config.dart';
import 'package:guvvy/features/users/data/models/user_model.dart';
import 'package:guvvy/features/users/data/repositories/user_repository.dart';
import 'package:guvvy/features/users/domain/entities/user.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class ApiUserRepository implements UserRepository {
  final http.Client _httpClient;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  ApiUserRepository({
    http.Client? httpClient,
    firebase_auth.FirebaseAuth? firebaseAuth,
  })  : _httpClient = httpClient ?? http.Client(),
        _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  // Helper method to get auth token
  Future<String?> _getAuthToken() async {
    return await _firebaseAuth.currentUser?.getIdToken();
  }

  // Helper method to create authorized headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Create a new user in the database
  @override
  Future<void> createUser(UserModel user) async {
    try {
      final headers = await _getAuthHeaders();
      print("Creating user in API: ${user.email}"); // Add logging

      final response = await _httpClient.post(
        Uri.parse(ApiConfig.usersEndpoint),
        headers: headers,
        body: jsonEncode({
          'firebase_uid': user.id,
          'email': user.email,
          'first_name': user.firstName,
          'last_name': user.lastName,
        }),
      );

      print(
          "API Response: ${response.statusCode} - ${response.body}"); // Add logging

      if (response.statusCode != 201) {
        throw Exception('Failed to create user: ${response.body}');
      }
    } catch (e) {
      print("Error in createUser: $e"); // Add error logging
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by Firebase UID
  @override
  Future<UserModel?> getUserById(String userId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _httpClient.get(
        Uri.parse(ApiConfig.userEndpoint(userId)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to get user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get the current user data
  @override
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }

    return getUserById(currentUser.uid);
  }

  // Update user data
  @override
  Future<void> updateUser(UserModel user) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _httpClient.put(
        Uri.parse(ApiConfig.userEndpoint(user.id)),
        headers: headers,
        body: jsonEncode({
          'first_name': user.firstName,
          'last_name': user.lastName,
          'district_ids': user.districtIds,
          'updated_at': user.updatedAt.toIso8601String(),
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Update user address
  @override
  Future<void> updateUserAddress(String userId, Address address) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _httpClient.put(
        Uri.parse(ApiConfig.userAddressEndpoint(userId)),
        headers: headers,
        body: jsonEncode({
          'street': address.street,
          'city': address.city,
          'state': address.state,
          'zip_code': address.zipCode, // Note the difference in field name
          'coordinates': address.coordinates != null
              ? {
                  'latitude': address.coordinates!.latitude,
                  'longitude': address.coordinates!.longitude,
                }
              : null,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update user address: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update user address: $e');
    }
  }

  // Delete user
  @override
  Future<void> deleteUser(String userId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _httpClient.delete(
        Uri.parse(ApiConfig.userEndpoint(userId)),
        headers: headers,
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete user: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Update login timestamp
  Future<UserModel> updateLoginTimestamp(String userId) async {
    try {
      final headers = await _getAuthHeaders();

      final response = await _httpClient.post(
        Uri.parse(ApiConfig.userLoginEndpoint(userId)),
        headers: headers,
      );

      if (response.statusCode == 200) {
        return UserModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update login timestamp: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to update login timestamp: $e');
    }
  }

  // Create a new user from Firebase Auth User
  @override
  Future<UserModel> createUserFromFirebaseUser(
      firebase_auth.User firebaseUser) async {
    try {
      // Check if user already exists
      final existingUser = await getUserById(firebaseUser.uid);
      if (existingUser != null) {
        // If user exists, update login timestamp
        return await updateLoginTimestamp(firebaseUser.uid);
      }

      // Create new user model
      final user = UserModel(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        firstName: firebaseUser.displayName?.split(' ').first,
        lastName: firebaseUser.displayName?.split(' ').skip(1).join(' '),
        address: null,
        districtIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      // Create user in database
      await createUser(user);
      return user;
    } catch (e) {
      throw Exception('Failed to create user from Firebase user: $e');
    }
  }
}
