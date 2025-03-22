// lib/features/users/data/repositories/user_repository_factory.dart
import 'package:guvvy/core/config/app_config.dart';
import 'package:guvvy/features/users/data/repositories/api_user_repository.dart';
import 'package:guvvy/features/users/data/repositories/firebase_user_repository.dart';
import 'package:guvvy/features/users/domain/repositories/user_repository.dart';

class UserRepositoryFactory {
  static UserRepository getRepository() {
    if (AppConfig.useApiBackend) {
      return ApiUserRepository();
    } else {
      return FirebaseUserRepository();
    }
  }
}