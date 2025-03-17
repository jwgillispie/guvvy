// lib/features/user/domain/repositories/user_repository.dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guvvy/features/users/data/models/user_model.dart';
import 'package:guvvy/features/users/domain/entities/user.dart';

abstract class UserRepository {
  /// Create a new user in the database
  Future<void> createUser(UserModel user);
  
  /// Get a user by their ID
  Future<UserModel?> getUserById(String userId);
  
  /// Get the currently logged in user
  Future<UserModel?> getCurrentUser();
  
  /// Update a user's information
  Future<void> updateUser(UserModel user);
  
  /// Update a user's address
  Future<void> updateUserAddress(String userId, Address address);
  
  /// Delete a user from the database
  Future<void> deleteUser(String userId);
  
  /// Create a new user from a Firebase Auth user
  Future<UserModel> createUserFromFirebaseUser(firebase_auth.User firebaseUser);
}