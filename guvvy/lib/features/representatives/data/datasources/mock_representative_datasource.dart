// Create this file at lib/features/representatives/data/datasources/mock_representative_datasource.dart
import 'package:guvvy/core/services/mock_data_service.dart';
import 'package:guvvy/features/representatives/data/datasources/representatives_remote_datasource.dart';
import 'package:guvvy/features/representatives/data/models/representative_model.dart';

class MockRepresentativeDataSource implements RepresentativesRemoteDataSource {
  @override
  Future<List<RepresentativeModel>> getRepresentativesByLocation(
    double latitude,
    double longitude,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Return mock data
    return MockDataService.getMockRepresentatives();
  }

  @override
  Future<RepresentativeModel> getRepresentativeById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Return the detailed mock data
    return MockDataService.getMockRepresentativeDetails(id);
  }
}
