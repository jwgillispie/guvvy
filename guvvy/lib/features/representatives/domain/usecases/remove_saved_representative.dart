// lib/features/representatives/domain/usecases/remove_saved_representative.dart
import '../repositories/representatives_repository.dart';

class RemoveSavedRepresentative {
  final RepresentativesRepository repository;

  RemoveSavedRepresentative(this.repository);

  Future<void> call(String representativeId) {
    return repository.removeSavedRepresentative(representativeId);
  }
}