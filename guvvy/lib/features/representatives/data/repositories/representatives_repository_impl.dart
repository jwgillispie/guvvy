// lib/features/representatives/data/repositories/representatives_repository_impl.dart
import 'package:guvvy/core/services/mock_data_service.dart';
import '../../domain/repositories/representatives_repository.dart';
import '../../domain/entities/representative.dart';
import '../datasources/representatives_remote_datasource.dart';

class RepresentativesRepositoryImpl implements RepresentativesRepository {
  final RepresentativesRemoteDataSource remoteDataSource;

  RepresentativesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Representative>> getRepresentativesByLocation(
    double latitude,
    double longitude,
  ) async {
    // For mock data, we'll ignore the coordinates
    return Future.delayed(
      const Duration(seconds: 1),
      () => MockDataService.getMockRepresentatives(),
    );
  }

  @override
  Future<Representative> getRepresentativeById(String id) async {
    final allReps = MockDataService.getMockRepresentatives();
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => allReps.firstWhere((rep) => rep.id == id),
    );
  }

  @override
  Future<List<Representative>> getSavedRepresentatives() async {
    return Future.delayed(
      const Duration(milliseconds: 500),
      () => MockDataService.getMockSavedRepresentatives(),
    );
  }

  @override
  Future<void> saveRepresentative(String representativeId) async {
    // In a real app, this would save to local storage or backend
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<void> removeSavedRepresentative(String representativeId) async {
    // In a real app, this would remove from local storage or backend
    await Future.delayed(const Duration(milliseconds: 500));
  }
}