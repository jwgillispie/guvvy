// lib/features/representatives/presentation/screens/representative_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representative_activity.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representative_details_widgets.dart';
// In lib/features/representatives/screens/representatives_details_screen.dart

class RepresentativeDetailsScreen extends StatefulWidget {
  final String representativeId;

  const RepresentativeDetailsScreen({
    Key? key,
    required this.representativeId,
  }) : super(key: key);

  @override
  State<RepresentativeDetailsScreen> createState() => _RepresentativeDetailsScreenState();
}

class _RepresentativeDetailsScreenState extends State<RepresentativeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load the representative details when the screen initializes
    Future.microtask(() {
      context.read<RepresentativesBloc>().add(
        LoadRepresentativeDetails(widget.representativeId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepresentativesBloc, RepresentativesState>(
      builder: (context, state) {
        // Add debugging to see what state is being received
        print('Current state: $state');
        
        if (state is RepresentativesLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is RepresentativeDetailsLoaded) {
          final representative = state.representative;
          return Scaffold(
            appBar: AppBar(
              title: Text(representative.name),
              actions: [
                IconButton(
                  icon: Icon(
                    state.isSaved ? Icons.star : Icons.star_border,
                  ),
                  onPressed: () {
                    context.read<RepresentativesBloc>().add(
                      state.isSaved
                        ? UnsaveRepresentativeEvent(representative.id)
                        : SaveRepresentativeEvent(representative.id),
                    );
                  },
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  RepresentativeHeader(representative: representative),
                  RepresentativeStats(representative: representative),
                  RepresentativeActivity(representative: representative),
                ],
              ),
            ),
          );
        } else if (state is RepresentativesError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Error loading representative: ${state.message}'),
            ),
          );
        }
        
        // Default loading state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}