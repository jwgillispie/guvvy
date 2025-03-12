// lib/features/search/domain/bloc/search_event.dart
import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchAddressSubmitted extends SearchEvent {
  final String address;

  const SearchAddressSubmitted(this.address);

  @override
  List<Object?> get props => [address];
}

class SearchResultsCleared extends SearchEvent {}

class SearchHistoryRequested extends SearchEvent {}

class SearchHistoryItemDeleted extends SearchEvent {
  final String id;

  const SearchHistoryItemDeleted(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchHistoryCleared extends SearchEvent {}