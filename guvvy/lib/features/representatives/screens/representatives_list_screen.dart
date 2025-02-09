// lib/features/representatives/presentation/screens/representatives_list_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representatives_card.dart';
import '../../../core/widgets/loading_widget.dart';

class RepresentativesListScreen extends StatefulWidget {
  const RepresentativesListScreen({Key? key}) : super(key: key);

  @override
  State<RepresentativesListScreen> createState() => _RepresentativesListScreenState();
}

class _RepresentativesListScreenState extends State<RepresentativesListScreen> {
  @override
  void initState() {
    super.initState();
    // Load representatives when screen is mounted
    context.read<RepresentativesBloc>().add(
      const LoadRepresentatives(latitude: 37.7749, longitude: -122.4194), // Example coordinates
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Representatives'),
      ),
      body: BlocBuilder<RepresentativesBloc, RepresentativesState>(
        builder: (context, state) {
          if (state is RepresentativesLoading) {
            return const LoadingWidget();
          }
          
          if (state is RepresentativesLoaded) {
            if (state.representatives.isEmpty) {
              return Center(
                child: Text(
                  'No representatives found',
                  style: theme.textTheme.bodyLarge,
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.representatives.length,
              itemBuilder: (context, index) {
                final representative = state.representatives[index];
                return RepresentativeCard(
                  representative: representative,
                  onTap: () => Navigator.pushNamed(
                    context,
                    '/representative-details',
                    arguments: representative.id,
                  ),
                );
              },
            );
          }
          
          if (state is RepresentativesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, 
                    size: 48, 
                    color: theme.colorScheme.error
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
              ),
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