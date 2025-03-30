// lib/core/widgets/rep_search_diagnostics.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/search/domain/entities/location.dart';

class RepSearchDiagnostics extends StatelessWidget {
  final Location searchLocation;

  const RepSearchDiagnostics({
    Key? key,
    required this.searchLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepresentativesBloc, RepresentativesState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade400),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DIAGNOSTICS',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Text('Search Location: ${searchLocation.latitude}, ${searchLocation.longitude}'),
              Text('Address: ${searchLocation.formattedAddress ?? "Unknown"}'),
              const Divider(),
              Text('Bloc State: ${state.runtimeType}'),
              if (state is RepresentativesLoaded) ...[
                Text('Total Representatives: ${state.representatives.length}'),
                Text('Active Filter: ${state.activeFilter ?? "None"}'),
                Text('Saved Representatives: ${state.savedRepresentatives.length}'),
                const SizedBox(height: 8),
                _buildLevelBreakdown(state.representatives),
                const SizedBox(height: 8),
                _buildFirstRepInfo(state.representatives),
              ],
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelBreakdown(List<Representative> reps) {
    final Map<String, int> counts = {'federal': 0, 'state': 0, 'local': 0, 'unknown': 0};
    
    for (final rep in reps) {
      final level = rep.level.toLowerCase();
      if (counts.containsKey(level)) {
        counts[level] = counts[level]! + 1;
      } else {
        counts['unknown'] = counts['unknown']! + 1;
      }
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Representatives by Level:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('Federal: ${counts['federal']}'),
        Text('State: ${counts['state']}'),
        Text('Local: ${counts['local']}'),
        if (counts['unknown']! > 0) Text('Unknown: ${counts['unknown']}'),
      ],
    );
  }

  Widget _buildFirstRepInfo(List<Representative> reps) {
    if (reps.isEmpty) {
      return const Text('No representatives to display');
    }
    
    final rep = reps.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('First Representative Details:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text('ID: ${rep.id}'),
        Text('Name: ${rep.name}'),
        Text('Party: ${rep.party}'),
        Text('Role: ${rep.role}'),
        Text('Level: ${rep.level}'),
        Text('District: ${rep.district}'),
      ],
    );
  }
}