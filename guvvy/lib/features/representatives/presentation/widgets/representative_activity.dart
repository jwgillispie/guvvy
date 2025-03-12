// lib/features/representatives/presentation/widgets/representative_activity.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/mock_data_service.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';

class RepresentativeActivity extends StatelessWidget {
  final Representative representative;

  const RepresentativeActivity({
    Key? key,
    required this.representative,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use mock voting history data
    final activities = MockDataService.getMockVotingHistory(representative.id)
      .take(3) // Just show the 3 most recent votes
      .map((vote) => {
        'title': '${vote['billId']} - ${vote['billTitle']}',
        'date': _formatDate(DateTime.parse(vote['date'])),
        'type': 'vote',
        'result': vote['result'],
        'description': vote['description'],
      })
      .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(
                      context, 
                      '/voting-history',
                      arguments: representative.id,
                    );
                  },
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
          ),
          
          // Activity cards
          if (activities.isEmpty)
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('No recent activity available'),
                ),
              ),
            )
          else
            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: _getVoteColor(activity['result']).withOpacity(0.2),
                      child: Icon(
                        Icons.how_to_vote,
                        color: _getVoteColor(activity['result']),
                        size: 18,
                      ),
                    ),
                    title: Text(
                      activity['title']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          activity['description'] ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              activity['date']!,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getVoteColor(activity['result']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                activity['result']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getVoteColor(activity['result']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context, 
                        '/voting-history',
                        arguments: representative.id,
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  Color _getVoteColor(String? vote) {
    switch (vote) {
      case 'Yea':
        return GuvvyTheme.success;
      case 'Nay':
        return GuvvyTheme.error;
      case 'Present':
        return GuvvyTheme.warning;
      default:
        return Colors.grey;
    }
  }
}