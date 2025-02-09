// lib/features/representatives/domain/bloc/representatives_state.dart
import 'package:equatable/equatable.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
abstract class RepresentativesState extends Equatable {
  const RepresentativesState();

  @override
  List<Object?> get props => [];
}

class RepresentativesInitial extends RepresentativesState {}

class RepresentativesLoading extends RepresentativesState {}

class RepresentativesLoaded extends RepresentativesState {
  final List<Representative> representatives;
  final String? activeFilter;
  final List<Representative> savedRepresentatives;

  const RepresentativesLoaded({
    required this.representatives,
    this.activeFilter,
    this.savedRepresentatives = const [],
  });

  @override
  List<Object?> get props => [representatives, activeFilter, savedRepresentatives];

  RepresentativesLoaded copyWith({
    List<Representative>? representatives,
    String? activeFilter,
    List<Representative>? savedRepresentatives,
  }) {
    return RepresentativesLoaded(
      representatives: representatives ?? this.representatives,
      activeFilter: activeFilter ?? this.activeFilter,
      savedRepresentatives: savedRepresentatives ?? this.savedRepresentatives,
    );
  }

  List<Representative> get filteredRepresentatives {
    if (activeFilter == null) return representatives;
    return representatives.where((rep) => rep.level == activeFilter).toList();
  }
}

class RepresentativeDetailsLoaded extends RepresentativesState {
  final Representative representative;
  final bool isSaved;

  const RepresentativeDetailsLoaded({
    required this.representative,
    required this.isSaved,
  });

  @override
  List<Object?> get props => [representative, isSaved];
}

class RepresentativesError extends RepresentativesState {
  final String message;

  const RepresentativesError(this.message);

  @override
  List<Object?> get props => [message];
}
