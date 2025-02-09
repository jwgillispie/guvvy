
// lib/features/representatives/domain/usecases/save_representative.dart
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';

class SaveRepresentative {
  final RepresentativesRepository repository;

  SaveRepresentative(this.repository);

  Future<void> call(String representativeId) {
    return repository.saveRepresentative(representativeId);
  }
}