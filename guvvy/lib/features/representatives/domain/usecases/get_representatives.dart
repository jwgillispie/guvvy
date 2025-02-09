// lib/features/representatives/domain/usecases/get_representatives.dart
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';

class GetRepresentativesByLocation {
  final RepresentativesRepository repository;

  GetRepresentativesByLocation(this.repository);

  Future<List<Representative>> call(double latitude, double longitude) {
    return repository.getRepresentativesByLocation(latitude, longitude);
  }
}

