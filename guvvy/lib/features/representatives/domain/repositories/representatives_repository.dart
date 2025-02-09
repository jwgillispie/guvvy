// lib/features/representatives/domain/repositories/representatives_repository.dart
import 'package:guvvy/features/representatives/domain/entities/representative.dart';

abstract class RepresentativesRepository {
  Future<List<Representative>> getRepresentativesByLocation(double latitude, double longitude);
  Future<Representative> getRepresentativeById(String id);
  Future<List<Representative>> getSavedRepresentatives();
  Future<void> saveRepresentative(String representativeId);
  Future<void> removeSavedRepresentative(String representativeId);
}
