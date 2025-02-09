
// lib/features/representatives/presentation/screens/representative_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representative_activity.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representative_details_widgets.dart';

class RepresentativeDetailsScreen extends StatelessWidget {
  final String representativeId;

  const RepresentativeDetailsScreen({
    Key? key,
    required this.representativeId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepresentativesBloc, RepresentativesState>(
      builder: (context, state) {
        if (state is RepresentativeDetailsLoaded) {
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
        }
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}