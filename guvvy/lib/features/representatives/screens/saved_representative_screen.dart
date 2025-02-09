// lib/features/representatives/presentation/screens/saved_representatives_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representatives_card.dart';
import '../../../core/widgets/loading_widget.dart';

class SavedRepresentativesScreen extends StatefulWidget {
  const SavedRepresentativesScreen({Key? key}) : super(key: key);

  @override
  State<SavedRepresentativesScreen> createState() => _SavedRepresentativesScreenState();
}

class _SavedRepresentativesScreenState extends State<SavedRepresentativesScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved representatives when screen is mounted
    context.read<RepresentativesBloc>().add(LoadSavedRepresentatives());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Representatives'),
      ),
      body: BlocBuilder<RepresentativesBloc, RepresentativesState>(
        builder: (context, state) {
          if (state is RepresentativesLoading) {
            return const LoadingWidget();
          }

          if (state is RepresentativesLoaded) {
            if (state.savedRepresentatives.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_border,
                      size: 64,
                      color: theme.disabledColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved representatives',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Star representatives to save them here',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.savedRepresentatives.length,
              itemBuilder: (context, index) {
                final representative = state.savedRepresentatives[index];
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

          return const SizedBox.shrink();
        },
      ),
    );
  }
}