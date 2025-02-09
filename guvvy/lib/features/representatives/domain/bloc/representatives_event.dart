// lib/features/representatives/presentation/bloc/representatives_event.dart
import 'package:equatable/equatable.dart';

abstract class RepresentativesEvent extends Equatable {
  const RepresentativesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRepresentatives extends RepresentativesEvent {
  final double latitude;
  final double longitude;

  const LoadRepresentatives({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}

class LoadRepresentativeDetails extends RepresentativesEvent {
  final String representativeId;

  const LoadRepresentativeDetails(this.representativeId);

  @override
  List<Object?> get props => [representativeId];
}

class SaveRepresentativeEvent extends RepresentativesEvent {
  final String representativeId;

  const SaveRepresentativeEvent(this.representativeId);

  @override
  List<Object?> get props => [representativeId];
}

class UnsaveRepresentativeEvent extends RepresentativesEvent {
  final String representativeId;

  const UnsaveRepresentativeEvent(this.representativeId);

  @override
  List<Object?> get props => [representativeId];
}

class FilterRepresentatives extends RepresentativesEvent {
  final String level; // 'federal', 'state', or 'local'

  const FilterRepresentatives(this.level);

  @override
  List<Object?> get props => [level];
}

class LoadSavedRepresentatives extends RepresentativesEvent {}