// lib/features/representatives/presentation/bloc/representatives_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representative_details.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/get_saved_representatives.dart';
import 'package:guvvy/features/representatives/domain/usecases/remove_saved_representative.dart';
import 'package:guvvy/features/representatives/domain/usecases/save_representative.dart';

class RepresentativesBloc extends Bloc<RepresentativesEvent, RepresentativesState> {
  final GetRepresentativesByLocation getRepresentativesByLocation;
  final GetRepresentativeDetails getRepresentativeDetails;
  final SaveRepresentative saveRepresentative;
  final GetSavedRepresentatives getSavedRepresentatives;
  final RemoveSavedRepresentative removeSavedRepresentative;

  RepresentativesBloc({
    required this.getRepresentativesByLocation,
    required this.getRepresentativeDetails,
    required this.saveRepresentative,
    required this.getSavedRepresentatives,
    required this.removeSavedRepresentative,
  }) : super(RepresentativesInitial()) {
    on<LoadRepresentatives>(_onLoadRepresentatives);
    on<LoadRepresentativeDetails>(_onLoadRepresentativeDetails);
    on<SaveRepresentativeEvent>(_onSaveRepresentative);
    on<UnsaveRepresentativeEvent>(_onUnsaveRepresentative);
    on<FilterRepresentatives>(_onFilterRepresentatives);
    on<LoadSavedRepresentatives>(_onLoadSavedRepresentatives);
  }

  Future<void> _onLoadRepresentatives(
    LoadRepresentatives event,
    Emitter<RepresentativesState> emit,
  ) async {
    emit(RepresentativesLoading());
    try {
      final representatives = await getRepresentativesByLocation(
        event.latitude,
        event.longitude,
      );
      final savedRepresentatives = await getSavedRepresentatives();

      emit(RepresentativesLoaded(
        representatives: representatives,
        savedRepresentatives: savedRepresentatives,
      ));
    } catch (e) {
      emit(RepresentativesError(e.toString()));
    }
  }

  Future<void> _onLoadRepresentativeDetails(
    LoadRepresentativeDetails event,
    Emitter<RepresentativesState> emit,
  ) async {
    emit(RepresentativesLoading());
    try {
      final representative = await getRepresentativeDetails(event.representativeId);
      final savedRepresentatives = await getSavedRepresentatives();
      final isSaved = savedRepresentatives.any((rep) => rep.id == event.representativeId);

      emit(RepresentativeDetailsLoaded(
        representative: representative,
        isSaved: isSaved,
      ));
    } catch (e) {
      emit(RepresentativesError(e.toString()));
    }
  }

  Future<void> _onSaveRepresentative(
    SaveRepresentativeEvent event,
    Emitter<RepresentativesState> emit,
  ) async {
    try {
      await saveRepresentative(event.representativeId);
      
      if (state is RepresentativeDetailsLoaded) {
        final currentState = state as RepresentativeDetailsLoaded;
        emit(RepresentativeDetailsLoaded(
          representative: currentState.representative,
          isSaved: true,
        ));
      }
    } catch (e) {
      emit(RepresentativesError(e.toString()));
    }
  }

  Future<void> _onUnsaveRepresentative(
    UnsaveRepresentativeEvent event,
    Emitter<RepresentativesState> emit,
  ) async {
    try {
      await removeSavedRepresentative(event.representativeId);
      
      if (state is RepresentativeDetailsLoaded) {
        final currentState = state as RepresentativeDetailsLoaded;
        emit(RepresentativeDetailsLoaded(
          representative: currentState.representative,
          isSaved: false,
        ));
      }
    } catch (e) {
      emit(RepresentativesError(e.toString()));
    }
  }

  Future<void> _onFilterRepresentatives(
    FilterRepresentatives event,
    Emitter<RepresentativesState> emit,
  ) async {
    if (state is RepresentativesLoaded) {
      final currentState = state as RepresentativesLoaded;
      emit(currentState.copyWith(activeFilter: event.level));
    }
  }

  Future<void> _onLoadSavedRepresentatives(
    LoadSavedRepresentatives event,
    Emitter<RepresentativesState> emit,
  ) async {
    emit(RepresentativesLoading());
    try {
      final savedRepresentatives = await getSavedRepresentatives();
      emit(RepresentativesLoaded(
        representatives: savedRepresentatives,
        savedRepresentatives: savedRepresentatives,
      ));
    } catch (e) {
      emit(RepresentativesError(e.toString()));
    }
  }
}