
// lib/features/representatives/presentation/widgets/representative_details_widgets.dart
import 'package:flutter/material.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';

class RepresentativeHeader extends StatelessWidget {
  final Representative representative;

  const RepresentativeHeader({
    Key? key,
    required this.representative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            child: Text(
              representative.name[0],
              style: const TextStyle(fontSize: 36),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            representative.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            representative.role,
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}

class RepresentativeStats extends StatelessWidget {
  final Representative representative;

  const RepresentativeStats({
    Key? key,
    required this.representative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              title: 'Committees',
              value: representative.committees.length.toString(),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: _StatCard(
              title: 'Votes',
              value: '0', // TODO: Implement voting stats
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({
    Key? key,
    required this.title,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}