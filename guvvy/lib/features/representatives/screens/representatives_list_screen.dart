// lib/features/representatives/presentation/screens/representatives_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/core/widgets/loading_widget.dart';
import 'package:guvvy/core/widgets/error_widget.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representatives_card.dart';

class RepresentativesListScreen extends StatefulWidget {
  const RepresentativesListScreen({Key? key}) : super(key: key);

  @override
  State<RepresentativesListScreen> createState() =>
      _RepresentativesListScreenState();
}

class _RepresentativesListScreenState extends State<RepresentativesListScreen>
    with SingleTickerProviderStateMixin {
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

// In lib/features/representatives/screens/representatives_list_screen.dart
// Replace the AnimatedList with this:

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.representatives.length,
              itemBuilder: (context, index) {
                final representative = state.representatives[index];
                final isSaved = state.savedRepresentatives.any(
                  (rep) => rep.id == representative.id,
                );

                return Padding(
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
                );
              },
            );
          }

          if (state is RepresentativesError) {
            return ErrorMessageWidget(
              message: state.message,
              onRetry: () {
                context.read<RepresentativesBloc>().add(
                      const LoadRepresentatives(
                          latitude: 37.7749, longitude: -122.4194),
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
