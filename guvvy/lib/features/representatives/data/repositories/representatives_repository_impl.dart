// lib/features/representatives/data/repositories/representatives_repository_impl.dart
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import '../datasources/representatives_api_datasource.dart';
import '../datasources/representatives_local_datasource.dart';
import 'package:guvvy/core/services/geocoding_service.dart';

class RepresentativesRepositoryImpl implements RepresentativesRepository {
  final RepresentativesApiDataSource remoteDataSource;
  final RepresentativesLocalDataSource localDataSource;

  RepresentativesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Representative>> getRepresentativesByLocation(double latitude, double longitude) async {
    try {
      // First, get the address string from the coordinates
      final address = await GeocodingService.getAddressForCoordinates(latitude, longitude);
      
      // Then fetch representatives using both the coordinates and address
      final representatives = await remoteDataSource.getRepresentativesByLocation(
        latitude, 
        longitude,
        address,
      );
      
      // Cache results locally for offline access
      await localDataSource.cacheRepresentatives(representatives);
      
      return representatives;
    } catch (e) {
      // If remote fetch fails, try to get from local cache
      try {
        final cachedRepresentatives = await localDataSource.getLastRepresentatives();
        if (cachedRepresentatives.isNotEmpty) {
          return cachedRepresentatives;
        }
      } catch (cacheError) {
        // Ignore cache errors and throw the original error
      }
      
      // If no cached data, rethrow the error
      rethrow;
    }
  }

  @override
  Future<Representative> getRepresentativeById(String id) async {
    try {
      return await remoteDataSource.getRepresentativeById(id);
    } catch (e) {
      // If remote fetch fails, try to get from local cache
      final representative = await localDataSource.getRepresentativeById(id);
      if (representative != null) {
        return representative;
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
}