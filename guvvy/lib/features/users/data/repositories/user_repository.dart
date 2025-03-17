// lib/features/user/data/repositories/user_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:guvvy/features/users/data/models/user_model.dart';
import 'package:guvvy/features/users/domain/entities/user.dart';


class UserRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  UserRepository({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : 
    _firestore = firestore ?? FirebaseFirestore.instance,
    _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  // Collection reference
  CollectionReference<Map<String, dynamic>> get _usersCollection => 
      _firestore.collection('users');

  // Create a new user in Firestore after Firebase Auth registration
  Future<void> createUser(UserModel user) async {
    try {
      // Check if user already exists
      final userDoc = await _usersCollection.doc(user.id).get();
      
      if (userDoc.exists) {
        throw Exception('User already exists in database');
      }
      
      // Create user document
      await _usersCollection.doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user: $e');
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final userDoc = await _usersCollection.doc(userId).get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        return null;
      }
      
      return UserModel.fromJson(userDoc.data()!..['id'] = userId);
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get the current user data
  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) {
      return null;
    }
    
    return getUserById(currentUser.uid);
  }

  // Update user data
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user data
  Future<void> deleteUser(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }
  Future<void> updateUserAddress(String userId, Address address) async {
    try {
      // Convert Address to JSON manually if it's not an AddressModel
      final addressData = address is AddressModel 
          ? address.toJson() 
          : address.toJson();
      
      await _usersCollection.doc(userId).update({
        'address': addressData,
      });
    } catch (e) {
      throw Exception('Failed to update user address: $e');
    }
  }

  // Create a new user from Firebase Auth User
  Future<UserModel> createUserFromFirebaseUser(firebase_auth.User firebaseUser) async {
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
    
    await createUser(user);
    return user;
  }
}