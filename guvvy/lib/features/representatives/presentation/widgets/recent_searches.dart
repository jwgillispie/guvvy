// lib/features/representatives/presentation/widgets/recent_searches.dart
import 'package:flutter/material.dart';

class RecentSearches extends StatelessWidget {
  const RecentSearches({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 2, // This will be dynamic based on actual data
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text('123 Main St, Springfield, IL'),
            leading: const Icon(Icons.history),
            onTap: () {
              // Handle tap on recent search
            },
          ),
        );
      },
    );
  }
}