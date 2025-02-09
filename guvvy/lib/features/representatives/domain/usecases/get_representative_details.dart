// lib/features/representatives/domain/usecases/get_representative_details.dart
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';

class GetRepresentativeDetails {
  final RepresentativesRepository repository;

  GetRepresentativeDetails(this.repository);

  Future<Representative> call(String id) {
    return repository.getRepresentativeById(id);
  }
}
