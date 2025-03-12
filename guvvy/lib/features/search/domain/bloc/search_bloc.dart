// lib/features/search/domain/bloc/search_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/search/domain/bloc/search_event.dart';
import 'package:guvvy/features/search/domain/bloc/search_state.dart';
import 'package:guvvy/features/search/domain/search_repository.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchRepository searchRepository;

  SearchBloc({required this.searchRepository}) : super(SearchInitial()) {
    on<SearchAddressSubmitted>(_onSearchAddressSubmitted);
    on<SearchResultsCleared>(_onSearchResultsCleared);
    on<SearchHistoryRequested>(_onSearchHistoryRequested);
    on<SearchHistoryItemDeleted>(_onSearchHistoryItemDeleted);
    on<SearchHistoryCleared>(_onSearchHistoryCleared);
  }

  Future<void> _onSearchAddressSubmitted(
    SearchAddressSubmitted event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    try {
      // Geocoding the address to get coordinates
      final location = await searchRepository.geocodeAddress(event.address);
      
      // Save search to history
      await searchRepository.saveSearchToHistory(
        address: event.address,
        location: location,
      );

      emit(SearchResultsFound(
        location: location,
        address: event.address,
      ));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  void _onSearchResultsCleared(
    SearchResultsCleared event,
    Emitter<SearchState> emit,
  ) {
    emit(SearchInitial());
  }

  Future<void> _onSearchHistoryRequested(
    SearchHistoryRequested event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());

    try {
      final historyItems = await searchRepository.getSearchHistory();
      emit(SearchHistoryLoaded(historyItems));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchHistoryItemDeleted(
    SearchHistoryItemDeleted event,
    Emitter<SearchState> emit,
  ) async {
    if (state is SearchHistoryLoaded) {
      final currentState = state as SearchHistoryLoaded;
      
      try {
        await searchRepository.deleteSearchHistoryItem(event.id);
        
        final updatedHistory = currentState.historyItems
            .where((item) => item.id != event.id)
            .toList();
        
        emit(SearchHistoryLoaded(updatedHistory));
      } catch (e) {
        emit(SearchError(e.toString()));
      }
    }
  }

  Future<void> _onSearchHistoryCleared(
    SearchHistoryCleared event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    
    try {
      await searchRepository.clearSearchHistory();
      emit(const SearchHistoryLoaded([]));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}