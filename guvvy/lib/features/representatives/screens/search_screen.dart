// lib/features/search/screens/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/search/domain/bloc/search_bloc.dart';
import 'package:guvvy/features/search/domain/bloc/search_event.dart';
import 'package:guvvy/features/search/domain/bloc/search_state.dart';
import 'package:guvvy/features/search/widgets/enhanced_address_search.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  @override
  void initState() {
    super.initState();
    // Load search history when screen mounts
    context.read<SearchBloc>().add(SearchHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Representatives'),
        actions: [
          BlocBuilder<SearchBloc, SearchState>(
            builder: (context, state) {
              if (state is SearchHistoryLoaded && state.historyItems.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Clear search history',
                  onPressed: () {
                    _showClearHistoryConfirmation(context);
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Enhanced address search
            EnhancedAddressSearchField(
              onAddressSelected: (location) {
                // Save search to history
                context.read<SearchBloc>().add(
                  SearchAddressSubmitted(
                    location.formattedAddress ?? 'Unknown Address',
                  ),
                );
                
                // Load representatives with the coordinates
                context.read<RepresentativesBloc>().add(
                  LoadRepresentatives(
                    latitude: location.latitude,
                    longitude: location.longitude,
                  ),
                );
                
                // Navigate to representatives screen
                Navigator.pushNamed(context, '/representatives');
              },
              hintText: 'Enter an address to find representatives',
            ),
            
            const SizedBox(height: 24),
            
            // Recent searches
            BlocBuilder<SearchBloc, SearchState>(
              builder: (context, state) {
                if (state is SearchHistoryLoaded) {
                  if (state.historyItems.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search,
                              size: 80,
                              color: Colors.grey.shade300,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No recent searches',
                              style: TextStyle(
                                fontSize: 16, 
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  return Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history,
                              size: 18,
                              color: GuvvyTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Recent Searches',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.separated(
                            itemCount: state.historyItems.length,
                            separatorBuilder: (context, index) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final item = state.historyItems[index];
                              return Dismissible(
                                key: Key(item.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  color: Colors.red,
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 16.0),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                onDismissed: (direction) {
                                  context.read<SearchBloc>().add(
                                    SearchHistoryItemDeleted(item.id),
                                  );
                                },
                                child: ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: GuvvyTheme.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.location_on_outlined,
                                      color: GuvvyTheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  title: Text(
                                    item.address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    'Searched on ${_formatDate(item.timestamp)}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () {
                                    // Load representatives with saved coordinates
                                    context.read<RepresentativesBloc>().add(
                                      LoadRepresentatives(
                                        latitude: item.location.latitude,
                                        longitude: item.location.longitude,
                                      ),
                                    );
                                    
                                    // Navigate to representatives screen
                                    Navigator.pushNamed(context, '/representatives');
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                } else if (state is SearchLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  void _showClearHistoryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text('Are you sure you want to clear all search history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<SearchBloc>().add(SearchHistoryCleared());
              Navigator.of(context).pop();
            },
            child: const Text('CLEAR'),
          ),
        ],
      ),
    );
  }
}