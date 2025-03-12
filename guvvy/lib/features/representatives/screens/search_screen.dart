// lib/features/search/presentation/screens/search_screen.dart
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

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    _animationController.forward();
    
    // Load search history when screen is mounted
    context.read<SearchBloc>().add(SearchHistoryRequested());
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Your Representatives'),
        elevation: 0,
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
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const SizedBox(height: 8),
              EnhancedAddressSearch(
                onAddressSelected: (latitude, longitude) {
                  // Load representatives with the coordinates
                  context.read<RepresentativesBloc>().add(
                    LoadRepresentatives(
                      latitude: latitude,
                      longitude: longitude,
                    ),
                  );
                  
                  // Navigate to representatives screen
                  Navigator.pushNamed(context, '/representatives');
                },
              ),
              
              // Recent searches list
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchHistoryLoaded && state.historyItems.isNotEmpty) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history,
                                    size: 16, 
                                    color: GuvvyTheme.textSecondary
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Recent Searches',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: ListView.separated(
                                itemCount: state.historyItems.length,
                                separatorBuilder: (context, index) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final item = state.historyItems[index];
                                  return Dismissible(
                                    key: Key(item.id),
                                    background: Container(
                                      color: Colors.red.shade700,
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.only(right: 20.0),
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    direction: DismissDirection.endToStart,
                                    onDismissed: (direction) {
                                      context.read<SearchBloc>().add(
                                        SearchHistoryItemDeleted(item.id),
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: const Text('Search removed'),
                                          action: SnackBarAction(
                                            label: 'UNDO',
                                            onPressed: () {
                                              // Load history again to restore the item
                                              // (In a real app, you'd have a more elegant solution)
                                              context.read<SearchBloc>().add(
                                                SearchHistoryRequested(),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    },
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 8.0,
                                      ),
                                      leading: CircleAvatar(
                                        backgroundColor: GuvvyTheme.primary.withOpacity(0.1),
                                        foregroundColor: GuvvyTheme.primary,
                                        child: const Icon(Icons.place_outlined),
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
                                        // Load representatives with the saved coordinates
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
                    
                    // Empty or initial state
                    return Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Enter an address to find your representatives',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
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