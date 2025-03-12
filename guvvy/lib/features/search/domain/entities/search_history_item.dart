// lib/features/search/domain/entities/search_history_item.dart
import 'package:equatable/equatable.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';

class SearchHistoryItem extends Equatable {
  final String id;
  final String address;
  final Location location;
  final DateTime timestamp;

  const SearchHistoryItem({
    required this.id,
    required this.address,
    required this.location,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, address, location, timestamp];
}