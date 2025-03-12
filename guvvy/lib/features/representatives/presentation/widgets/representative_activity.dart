// lib/features/representatives/presentation/widgets/representative_activity.dart
import 'package:flutter/material.dart';
import '../../domain/entities/representative.dart';

class RepresentativeActivity extends StatelessWidget {
  final Representative representative;

  const RepresentativeActivity({
    Key? key,
    required this.representative,
  }) : super(key: key);
// In lib/features/representatives/presentation/widgets/representative_activity.dart

  @override
  Widget build(BuildContext context) {
    // Mock activity data for display
    final activities = [
      {
        'title': 'Voted on Infrastructure Bill',
        'date': 'Yesterday',
        'type': 'vote'
      },
      {
        'title': 'Introduced Climate Bill',
        'date': '3 days ago',
        'type': 'bill'
      },
      {
        'title': 'Committee Meeting: Finance',
        'date': '1 week ago',
        'type': 'committee'
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    activity['type'] == 'vote'
                        ? Icons.how_to_vote
                        : activity['type'] == 'bill'
                            ? Icons.description
                            : Icons.people,
                    color: Theme.of(context).primaryColor,
                  ),
                  title: Text(activity['title']!),
                  subtitle: Text(activity['date']!),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Handle activity tap if needed
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
