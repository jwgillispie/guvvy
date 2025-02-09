 // lib/features/representatives/domain/usecases/get_saved_representatives.dart
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/representatives/domain/repositories/representatives_repository.dart';

class GetSavedRepresentatives {
  final RepresentativesRepository repository;

  GetSavedRepresentatives(this.repository);

  Future<List<Representative>> call() {
    return repository.getSavedRepresentatives();
  }
}
