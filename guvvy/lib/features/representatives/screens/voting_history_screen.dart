// lib/features/voting/presentation/screens/voting_history_screen.dart
import 'package:flutter/material.dart';

class VotingHistoryScreen extends StatelessWidget {
  const VotingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10, // This will be dynamic based on actual data
        itemBuilder: (context, index) {
          // This is a placeholder - we'll need to create a voting bloc and models
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: index % 2 == 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'H.R. ${1000 + index} - Infrastructure Bill',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          index % 2 == 0 ? 'Yea' : 'Nay',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: index % 2 == 0 ? Colors.green : Colors.red,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${DateTime.now().subtract(Duration(days: index)).month}/${DateTime.now().subtract(Duration(days: index)).day}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}