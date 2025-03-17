// lib/features/user/data/repositories/user_repository_factory.dart
import 'package:guvvy/core/config/app_config.dart';
import 'package:guvvy/features/users/data/repositories/api_user_repository.dart';
import 'package:guvvy/features/users/data/repositories/firebase_user_repository.dart';
import 'package:guvvy/features/users/data/repositories/user_repository.dart';

/// Factory for creating UserRepository implementations
class UserRepositoryFactory {
  /// Factory method to get the appropriate user repository based on config
  static UserRepository getRepository() {
    // Switch between implementations based on config
    if (AppConfig.useApiBackend) {
      return ApiUserRepository() as UserRepository;
    } else {
      return FirebaseUserRepository() as UserRepository;
    }
  }
}