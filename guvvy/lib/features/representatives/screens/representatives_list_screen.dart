// lib/features/representatives/presentation/screens/representatives_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/presentation/widgets/enhanced_representative_card.dart';
import 'package:guvvy/core/widgets/loading_widget.dart';
import 'package:guvvy/core/widgets/error_widget.dart';

class RepresentativesListScreen extends StatefulWidget {
  const RepresentativesListScreen({Key? key}) : super(key: key);

  @override
  State<RepresentativesListScreen> createState() => _RepresentativesListScreenState();
}

class _RepresentativesListScreenState extends State<RepresentativesListScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Load representatives when screen is mounted
    context.read<RepresentativesBloc>().add(
      const LoadRepresentatives(latitude: 37.7749, longitude: -122.4194),
    );
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
        title: const Text('Your Representatives'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog
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
            // Start staggered animation when data is loaded
            _animationController.forward();
            
            if (state.representatives.isEmpty) {
              return const Center(
                child: Text('No representatives found'),
              );
            }

            return AnimatedList(
              padding: const EdgeInsets.all(16),
              initialItemCount: state.representatives.length,
              itemBuilder: (context, index, animation) {
                final representative = state.representatives[index];
                final isSaved = state.savedRepresentatives.any(
                  (rep) => rep.id == representative.id,
                );
                
                // Create a staggered fade-in and slide-up animation
                final staggeredAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Interval(
                      index * 0.1, // Stagger start times
                      1.0,
                      curve: Curves.easeOut,
                    ),
                  ),
                );
                
                return FadeTransition(
                  opacity: staggeredAnimation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(staggeredAnimation),
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
                  ),
                );
              },
            );
          }
          
          if (state is RepresentativesError) {
            return ErrorMessageWidget(
              message: state.message,
              onRetry: () {
                context.read<RepresentativesBloc>().add(
                  const LoadRepresentatives(latitude: 37.7749, longitude: -122.4194),
                );
              },
            );
          }

          return const Center(
            child: Text('Enter an address to find your representatives'),
          );
        },
      ),
    );
  }
}