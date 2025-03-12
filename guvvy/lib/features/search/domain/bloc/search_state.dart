// lib/features/search/domain/bloc/search_state.dart
import 'package:equatable/equatable.dart';
import 'package:guvvy/features/search/domain/entities/search_history_item.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';

abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchResultsFound extends SearchState {
  final Location location;
  final String address;

  const SearchResultsFound({
    required this.location,
    required this.address,
  });

  @override
  List<Object?> get props => [location, address];
}

class SearchHistoryLoaded extends SearchState {
  final List<SearchHistoryItem> historyItems;

  const SearchHistoryLoaded(this.historyItems);

  @override
  List<Object?> get props => [historyItems];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}