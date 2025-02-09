// lib/features/representatives/presentation/widgets/representative_card.dart
import 'package:flutter/material.dart';
import '../../domain/entities/representative.dart';

class RepresentativeCard extends StatelessWidget {
  final Representative representative;
  final VoidCallback onTap;

  const RepresentativeCard({
    Key? key,
    required this.representative,
    required this.onTap,
  }) : super(key: key);

  Color _getPartyColor(String party) {
    switch (party.toLowerCase()) {
      case 'democratic':
        return Colors.blue;
      case 'republican':
        return Colors.red;
      default:
        return Colors.purple; // Independent or other
    }
  }

  String _getLevelIcon(String level) {
    switch (level.toLowerCase()) {
      case 'federal':
        return '🏛️';
      case 'state':
        return '🏪';
      case 'local':
        return '🏢';
      default:
        return '🏢';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partyColor = _getPartyColor(representative.party);
    final levelIcon = _getLevelIcon(representative.level);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: partyColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        representative.name[0],
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: partyColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          representative.name,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${representative.role} • ${representative.party}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    levelIcon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ],
              ),
              if (representative.committees.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: representative.committees.map((committee) {
                    return Chip(
                      label: Text(
                        committee,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.8),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}