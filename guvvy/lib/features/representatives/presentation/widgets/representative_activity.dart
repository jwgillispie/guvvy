import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:intl/intl.dart';

class RepresentativeActivity extends StatelessWidget {
  final Representative representative;
  final List<Map<String, dynamic>> votingData;

  const RepresentativeActivity({
    Key? key,
    required this.representative,
    required this.votingData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Transform and limit the voting data
    final activities = votingData
      .take(3) // Just show the 3 most recent votes
      .map((vote) => _transformVoteToActivity(vote))
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
                      arguments: {
                        'representativeId': representative.id,
                        'votingData': votingData,
                      },
                    );
                  },
                  icon: const Icon(Icons.history, size: 16),
                  label: const Text('View All'),
                ),
              ],
            ),
          ),
          
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
                        arguments: {
                          'representativeId': representative.id,
                          'votingData': votingData,
                        },
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

  Map<String, dynamic> _transformVoteToActivity(Map<String, dynamic> vote) {
    final date = DateTime.parse(vote['date']);
    return {
      'title': 'Vote #${vote['rollnumber']}',
      'date': _formatDate(date),
      'type': 'vote',
      'result': _getVoteResult(vote),
      'description': vote['vote_question'] ?? 'Legislative Vote',
    };
  }

  String _getVoteResult(Map<String, dynamic> vote) {
    final yeaCount = vote['yea_count'] ?? 0;
    final nayCount = vote['nay_count'] ?? 0;
    return yeaCount > nayCount ? 'Yea' : 'Nay';
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    }
    return DateFormat('MM/dd/yyyy').format(date);
  }

  Color _getVoteColor(String? vote) {
    switch (vote) {
      case 'Yea': return GuvvyTheme.success;
      case 'Nay': return GuvvyTheme.error;
      default: return Colors.grey;
    }
  }
}