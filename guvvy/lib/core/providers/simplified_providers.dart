// lib/core/providers/simplified_providers.dart

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/auth/data/repositories/auth_repository.dart';
import 'package:guvvy/features/auth/domain/bloc/auth_bloc.dart';
import 'package:guvvy/features/representatives/data/datasources/mock_representative_datasource.dart';
import 'package:guvvy/features/representatives/data/datasources/representatives_local_datasource.dart';
import 'package:guvvy/features/representatives/data/repositories/representatives_repository_impl.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representative_details.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_saved_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/remove_saved_representative.dart';
import 'package:guvvy/features/representatives/domain/usecases/save_representative.dart';
import 'package:guvvy/features/users/data/models/user_model.dart';
import 'package:guvvy/features/users/domain/entities/user.dart';
import 'package:guvvy/features/users/domain/repositories/user_repository.dart';

// Simple factory class to create basic repositories without complex dependencies
class SimplifiedProviders {
  
  // Create a simple representatives repository using mock data
  static RepositoryProvider<RepresentativesRepository> getRepresentativesRepositoryProvider() {
    return RepositoryProvider<RepresentativesRepository>(
      create: (context) {
        // Use mock data source to avoid API dependencies
        final mockDataSource = MockRepresentativeDataSource();
        
        // Create a simplified local data source
        final localDataSource = SimplifiedLocalDataSource();
        
        return RepresentativesRepositoryImpl(
          remoteDataSource: mockDataSource,
          localDataSource: localDataSource,
        );
      },
    );
  }
  
  // Create the representatives bloc with minimal dependencies
  static BlocProvider<RepresentativesBloc> getRepresentativesBlocProvider() {
    return BlocProvider<RepresentativesBloc>(
      create: (context) {
        final repository = context.read<RepresentativesRepository>();
        
        return RepresentativesBloc(
          getRepresentativesByLocation: GetRepresentativesByLocation(repository),
          getRepresentativeDetails: GetRepresentativeDetails(repository),
          saveRepresentative: SaveRepresentative(repository),
          getSavedRepresentatives: GetSavedRepresentatives(repository),
          removeSavedRepresentative: RemoveSavedRepresentative(repository),
        );
      },
    );
  }
  
  // Create auth bloc provider
  // static BlocProvider<AuthBloc> getAuthBlocProvider() {
  //   return BlocProvider<AuthBloc>(
  //     create: (context) {
  //       return AuthBloc(
  //         authRepository: AuthRepository(),
  //         userRepository: SimplifiedUserRepository(),
  //       );
  //     },
  //   );
  // }
  static BlocProvider<AuthBloc> getAuthBlocProvider() {
  return BlocProvider<AuthBloc>(
    create: (context) {
      return SafeAuthBloc(
        authRepository: AuthRepository(),
        userRepository: SimplifiedUserRepository(),
      );
    },
    lazy: false, // Initialize immediately when app starts
  );
}
}

// SimplifiedUserRepository provides a minimal implementation without dependencies
class SimplifiedUserRepository implements UserRepository {
  @override
  Future<void> createUser(UserModel user) async {
    // No-op implementation 
  }
  
  @override
  Future<UserModel?> getUserById(String userId) async {
    // Return a mock user
    return UserModel(
      id: userId,
      email: 'user@example.com',
      firstName: 'Test',
      lastName: 'User',
      address: null,
      districtIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    return null; // Not needed for basic functionality
  }
  
  @override
  Future<void> updateUser(UserModel user) async {
    // No-op implementation
  }
  
  @override
  Future<void> updateUserAddress(String userId, Address address) async {
    // No-op implementation
  }
  
  @override
  Future<void> deleteUser(String userId) async {
    // No-op implementation
  }
  
  @override
  Future<UserModel> createUserFromFirebaseUser(firebase_auth.User firebaseUser) async {
    // Create a basic user model from Firebase User
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? 'user@example.com',
      firstName: firebaseUser.displayName?.split(' ').first,
      lastName: firebaseUser.displayName?.split(' ').skip(1).join(' '),
      address: null,
      districtIds: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }
}

// Simplified local data source that doesn't rely on SharedPreferences
class SimplifiedLocalDataSource implements RepresentativesLocalDataSource {
  // In-memory storage
  final List<Representative> _cachedRepresentatives = [];
  final Set<String> _savedIds = {};
  
  @override
  Future<void> cacheRepresentative(Representative representative) async {
    // Find and replace existing or add new
    final index = _cachedRepresentatives.indexWhere((r) => r.id == representative.id);
    if (index >= 0) {
      _cachedRepresentatives[index] = representative;
    } else {
      _cachedRepresentatives.add(representative);
    }
  }
  
  @override
  Future<void> cacheRepresentatives(List<Representative> representatives) async {
    _cachedRepresentatives.clear();
    _cachedRepresentatives.addAll(representatives);
  }
  
  @override
  Future<Representative?> getRepresentativeById(String id) async {
    try {
      return _cachedRepresentatives.firstWhere((rep) => rep.id == id);
    } catch (e) {
      return null;
    }
  }
  
  @override
  Future<List<Representative>> getLastRepresentatives() async {
    return List.from(_cachedRepresentatives);
  }
  
  @override
  Future<List<Representative>> getSavedRepresentatives() async {
    return _cachedRepresentatives.where((rep) => _savedIds.contains(rep.id)).toList();
  }
  
  @override
  Future<void> saveRepresentative(String representativeId) async {
    _savedIds.add(representativeId);
  }
  
  @override
  Future<void> removeSavedRepresentative(String representativeId) async {
    _savedIds.remove(representativeId);
  }
}

class SafeAuthBloc extends AuthBloc {
  SafeAuthBloc({required super.authRepository, required super.userRepository}) {
    // Initialize with Unauthenticated state to avoid NotInitialized errors
    emit(AuthUnauthenticated());
  }
}