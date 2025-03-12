// lib/features/representatives/data/repositories/representatives_repository_impl.dart
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import '../datasources/representatives_remote_datasource.dart';
import '../datasources/representatives_local_datasource.dart';

class RepresentativesRepositoryImpl implements RepresentativesRepository {
  final RepresentativesRemoteDataSource remoteDataSource;
  final RepresentativesLocalDataSource localDataSource;

  RepresentativesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Representative>> getRepresentativesByLocation(double latitude, double longitude) async {
    try {
      // Try to fetch from remote API first
      final representatives = await remoteDataSource.getRepresentativesByLocation(latitude, longitude);
      
      // Cache results locally for offline access
      await localDataSource.cacheRepresentatives(representatives);
      
      return representatives;
    } catch (e) {
      // If remote fetch fails, try to get from local cache
      final cachedRepresentatives = await localDataSource.getLastRepresentatives();
      if (cachedRepresentatives.isNotEmpty) {
        return cachedRepresentatives;
      }
      
      // If no cached data, rethrow the error
      rethrow;
    }
  }

  @override
  Future<List<Representative>> getSavedRepresentatives() async {
    return localDataSource.getSavedRepresentatives();
  }

  @override
  Future<void> saveRepresentative(String representativeId) async {
    await localDataSource.saveRepresentative(representativeId);
  }

  @override
  Future<void> removeSavedRepresentative(String representativeId) async {
    await localDataSource.removeSavedRepresentative(representativeId);
  }
  
  @override
  Future<Representative> getRepresentativeById(String id) async {
    try {
      // Try to get from remote API
      final representative = await remoteDataSource.getRepresentativeById(id);
      return representative;
    } catch (e) {
      // Try to get from local cache if remote fails
      final cachedRepresentative = await localDataSource.getRepresentativeById(id);
      if (cachedRepresentative != null) {
        return cachedRepresentative;
      }
      
      // If no data found, rethrow the error
      rethrow;
    }
  }
}