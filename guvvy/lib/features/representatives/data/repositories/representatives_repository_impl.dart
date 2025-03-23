// lib/features/representatives/data/repositories/representatives_repository_impl.dart
import 'package:guvvy/features/representatives/data/datasources/mock_representative_datasource.dart';
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import '../datasources/representatives_remote_datasource.dart';
import '../datasources/representatives_local_datasource.dart';
import 'package:guvvy/core/services/geocoding_service.dart';
import 'package:guvvy/core/config/app_config.dart';
import 'package:guvvy/core/services/connectivity_service.dart';

class RepresentativesRepositoryImpl implements RepresentativesRepository {
  final RepresentativesRemoteDataSource remoteDataSource;
  final RepresentativesLocalDataSource localDataSource;

  RepresentativesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
@override
Future<List<Representative>> getRepresentativesByLocation(double latitude, double longitude) async {
  try {
    // Try to get data from real API
    final representatives = await remoteDataSource.getRepresentativesByLocation(
      latitude, 
      longitude,
    );
    
    // Cache results locally
    await localDataSource.cacheRepresentatives(representatives);
    
    return representatives;
  } catch (e) {
    print('Error fetching representatives: $e');
    
    // Try to get data from cache first
    try {
      final cachedReps = await localDataSource.getLastRepresentatives();
      if (cachedReps.isNotEmpty) {
        return cachedReps;
      }
    } catch (cacheError) {
      print('Cache error: $cacheError');
    }
    
    // If all else fails, use mock data as a fallback
    print('Falling back to mock data');
    final mockDataSource = MockRepresentativeDataSource();
    return mockDataSource.getRepresentativesByLocation(latitude, longitude);
  }
}

  @override
  Future<Representative> getRepresentativeById(String id) async {
    try {
      // Check for internet connectivity
      final isConnected = await ConnectivityService.hasInternetConnection();
      
      if (isConnected || !AppConfig.enableOfflineMode) {
        final representative = await remoteDataSource.getRepresentativeById(id);
        // Cache this representative for offline access
        await localDataSource.cacheRepresentative(representative);
        return representative;
      } else {
        // If offline mode is enabled and we're not connected, use cached data
        final representative = await localDataSource.getRepresentativeById(id);
        if (representative != null) {
          return representative;
        }
        throw Exception('No internet connection and no cached data available');
      }
    } catch (e) {
      // If remote fetch fails, try to get from local cache
      if (AppConfig.enableOfflineMode) {
        final representative = await localDataSource.getRepresentativeById(id);
        if (representative != null) {
          return representative;
        }
      }
      
      // If no cached data or offline mode is disabled, rethrow the error
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