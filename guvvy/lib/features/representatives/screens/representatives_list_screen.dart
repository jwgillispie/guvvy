// lib/features/representatives/screens/representatives_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/core/widgets/loading_widget.dart';
import 'package:guvvy/core/widgets/error_widget.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representatives_card.dart';

class RepresentativesListScreen extends StatefulWidget {
  const RepresentativesListScreen({Key? key}) : super(key: key);

  @override
  State<RepresentativesListScreen> createState() => _RepresentativesListScreenState();
}

class _RepresentativesListScreenState extends State<RepresentativesListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final List<String> _levelFilters = ['All', 'Federal', 'State', 'Local'];
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // We don't load representatives here anymore - it should have been 
    // loaded before navigating to this screen
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Group representatives by government level
  Map<String, List<Representative>> _groupByLevel(List<Representative> representatives) {
    final grouped = <String, List<Representative>>{
      'federal': [],
      'state': [],
      'local': [],
    };
    
    for (final rep in representatives) {
      final level = rep.level.toLowerCase();
      if (grouped.containsKey(level)) {
        grouped[level]!.add(rep);
      } else {
        grouped['local']!.add(rep); // Default to local if unknown level
      }
    }
    
    return grouped;
  }

  // Filter representatives based on selected filter
  List<Representative> _filterRepresentatives(List<Representative> representatives, String filter) {
    if (filter == 'All') {
      return representatives;
    }
    
    // Convert filter to match the actual level values in the data
    String levelFilter = filter.toLowerCase();
    
    // Debug print to see what's being filtered
    print('Filtering for level: $levelFilter');
    print('Available levels: ${representatives.map((r) => r.level.toLowerCase()).toSet()}');
    
    return representatives.where((rep) => 
      rep.level.toLowerCase() == levelFilter
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuvvyTheme.background,
      appBar: AppBar(
        title: const Text('Your Representatives'),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Information',
            onPressed: () {
              _showInformationDialog(context);
            },
          ),
        ],
      ),
      body: BlocBuilder<RepresentativesBloc, RepresentativesState>(
        builder: (context, state) {
          if (state is RepresentativesLoading) {
            return const LoadingWidget();
          }

          if (state is RepresentativesLoaded) {
            // Start animation when data is loaded
            _animationController.forward();
            
            if (state.representatives.isEmpty) {
              return _buildEmptyState();
            }

            // Group representatives by level for hierarchical display
            final groupedReps = _groupByLevel(state.representatives);
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Level filter chips
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: _levelFilters.map((filter) => 
                      ChoiceChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          }
                        },
                        selectedColor: GuvvyTheme.primary.withOpacity(0.15),
                        labelStyle: TextStyle(
                          color: _selectedFilter == filter 
                            ? GuvvyTheme.primary 
                            : GuvvyTheme.textSecondary,
                          fontWeight: _selectedFilter == filter 
                            ? FontWeight.bold 
                            : FontWeight.normal,
                        ),
                      )
                    ).toList(),
                  ),
                ),
                
                // Representatives list
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    children: [
                      // Info card at the top
                      _buildInfoCard(state.representatives.length),

                      if (_selectedFilter == 'All') ...[
                        // Show all levels grouped by section when "All" is selected
                        if (groupedReps['federal']!.isNotEmpty) 
                          _buildSectionWithReps('Federal', groupedReps['federal']!, state),
                        
                        if (groupedReps['state']!.isNotEmpty) 
                          _buildSectionWithReps('State', groupedReps['state']!, state),
                        
                        if (groupedReps['local']!.isNotEmpty) 
                          _buildSectionWithReps('Local', groupedReps['local']!, state),
                      ] else
                        // Show only the filtered level
                        _buildSectionWithReps(
                          _selectedFilter, 
                          _filterRepresentatives(state.representatives, _selectedFilter), 
                          state
                        ),
                    ],
                  ),
                ),
              ],
            );
          }

          if (state is RepresentativesError) {
            // Use the lastCoordinates from the bloc instead of hardcoded values
            final bloc = context.read<RepresentativesBloc>();
            return ErrorMessageWidget(
              message: state.message,
              onRetry: () {
                bloc.add(
                  LoadRepresentatives(
                    latitude: bloc.lastLatitude ?? 39.8283, 
                    longitude: bloc.lastLongitude ?? -98.5795,
                  ),
                );
              },
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_searching,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Enter an address to find your representatives',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Build a section header with a list of representatives
  Widget _buildSectionWithReps(String title, List<Representative> reps, RepresentativesLoaded state) {
    if (reps.isEmpty) return const SizedBox.shrink();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 24.0, bottom: 12.0, left: 4.0),
          child: Row(
            children: [
              Icon(
                _getLevelIcon(title.toLowerCase()),
                size: 20,
                color: _getLevelColor(title.toLowerCase()),
              ),
              const SizedBox(width: 8),
              Text(
                '$title Representatives',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _getLevelColor(title.toLowerCase()),
                ),
              ),
            ],
          ),
        ),
        // Divider with level color
        Container(
          height: 2,
          margin: const EdgeInsets.only(bottom: 16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _getLevelColor(title.toLowerCase()),
                _getLevelColor(title.toLowerCase()).withOpacity(0.1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        _buildRepsList(reps, state),
      ],
    );
  }

  // Build the list of representative cards with staggered animation
  Widget _buildRepsList(List<Representative> reps, RepresentativesLoaded state) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: reps.length,
      itemBuilder: (context, index) {
        final representative = reps[index];
        final isSaved = state.savedRepresentatives.any(
          (rep) => rep.id == representative.id,
        );

        // Calculate delay for staggered animation
        final delay = index * 0.1;
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay.clamp(0.0, 0.9),
              (delay + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        );

        final fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay.clamp(0.0, 0.9),
              (delay + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        );

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: fadeAnimation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: EnhancedRepresentativeCard(
              representative: representative,
              isSaved: isSaved,
              onTap: () => Navigator.pushNamed(
                context,
                '/representative-details',
                arguments: representative.id,
              ),
              onSave: () {
                if (isSaved) {
                  context.read<RepresentativesBloc>().add(
                        UnsaveRepresentativeEvent(representative.id),
                      );
                } else {
                  context.read<RepresentativesBloc>().add(
                        SaveRepresentativeEvent(representative.id),
                      );
                }
              },
            ),
          ),
        );
      },
    );
  }

  // Build info card that shows at the top
  Widget _buildInfoCard(int totalReps) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 8, bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: GuvvyTheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'We found $totalReps representatives for you',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap on a card to view detailed information',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build empty state when no representatives are found
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_search,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            const Text(
              'No Representatives Found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'We couldn\'t find any representatives for this location. Try searching with a different address.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/map-search');
              },
              icon: const Icon(Icons.search),
              label: const Text('Search Again'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show information dialog
  void _showInformationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Your Representatives'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Federal', 'National level officials like Senators and House Representatives'),
            const SizedBox(height: 16),
            _buildInfoRow('State', 'State Senators, State Assembly Members, and Governors'),
            const SizedBox(height: 16),
            _buildInfoRow('Local', 'County and City officials, Mayors, and Council Members'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  // Helper widget for info dialog
  Widget _buildInfoRow(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          _getLevelIcon(title.toLowerCase()),
          color: _getLevelColor(title.toLowerCase()),
          size: 20,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Get color based on government level
  Color _getLevelColor(String level) {
    switch (level) {
      case 'federal':
        return Colors.indigo;
      case 'state':
        return Colors.teal;
      case 'local':
        return Colors.amber.shade800;
      default:
        return Colors.grey;
    }
  }

  // Get icon based on government level
  IconData _getLevelIcon(String level) {
    switch (level) {
      case 'federal':
        return Icons.account_balance;
      case 'state':
        return Icons.domain;
      case 'local':
        return Icons.location_city;
      default:
        return Icons.public;
    }
  }
}