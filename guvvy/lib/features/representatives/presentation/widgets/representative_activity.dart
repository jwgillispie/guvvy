// lib/features/representatives/presentation/widgets/representative_activity.dart
import 'package:flutter/material.dart';
import '../../domain/entities/representative.dart';

class RepresentativeActivity extends StatelessWidget {
  final Representative representative;

  const RepresentativeActivity({
    Key? key,
    required this.representative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          // This will be populated with actual activity data
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 3,
            itemBuilder: (context, index) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: const Text('Vote on Bill HR-123'),
                  subtitle: const Text('Yesterday'),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}