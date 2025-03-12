// lib/features/representatives/screens/voting_history_screen.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/mock_data_service.dart';

class VotingHistoryScreen extends StatefulWidget {
  final String? representativeId;

  const VotingHistoryScreen({
    Key? key, 
    this.representativeId, // Optional: if provided, shows votes for a specific rep
  }) : super(key: key);

  @override
  State<VotingHistoryScreen> createState() => _VotingHistoryScreenState();
}

class _VotingHistoryScreenState extends State<VotingHistoryScreen> {
  String _selectedFilter = 'All';
  
  @override
  Widget build(BuildContext context) {
    // Get mock voting data
    final votingHistory = widget.representativeId != null 
        ? MockDataService.getMockVotingHistory(widget.representativeId!)
        : MockDataService.getMockVotingHistory("1"); // Default voting history

    // Filter options
    final filterOptions = ['All', 'Yea', 'Nay', 'Present'];
    
    // Filtered votes
    final filteredVotes = _selectedFilter == 'All'
        ? votingHistory
        : votingHistory.where((vote) => vote['result'] == _selectedFilter).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting History'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Stats summary card
          _buildVotingSummaryCard(votingHistory),
          
          // Filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: filterOptions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final option = filterOptions[index];
                  final isSelected = option == _selectedFilter;
                  
                  return FilterChip(
                    label: Text(option),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = option;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: _getChipColor(option).withOpacity(0.1),
                    labelStyle: TextStyle(
                      color: isSelected ? _getChipColor(option) : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Voting timeline
          Expanded(
            child: filteredVotes.isEmpty
                ? Center(
                    child: Text(
                      'No votes matching "$_selectedFilter" filter',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : _buildVotingTimeline(filteredVotes),
          ),
        ],
      ),
    );
  }
  
  Widget _buildVotingSummaryCard(List<Map<String, dynamic>> votes) {
    // Calculate voting statistics
    final totalVotes = votes.length;
    final yeaVotes = votes.where((v) => v['result'] == 'Yea').length;
    final nayVotes = votes.where((v) => v['result'] == 'Nay').length;
    final otherVotes = totalVotes - yeaVotes - nayVotes;
    
    final yeaPercentage = totalVotes > 0 ? (yeaVotes / totalVotes * 100).toStringAsFixed(1) : '0';
    final nayPercentage = totalVotes > 0 ? (nayVotes / totalVotes * 100).toStringAsFixed(1) : '0';
    
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voting Summary',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVoteStat('Total Votes', totalVotes.toString(), Colors.blue),
                _buildVoteStat('Yea', '$yeaVotes ($yeaPercentage%)', GuvvyTheme.success),
                _buildVoteStat('Nay', '$nayVotes ($nayPercentage%)', GuvvyTheme.error),
                if (otherVotes > 0)
                  _buildVoteStat('Other', otherVotes.toString(), GuvvyTheme.warning),
              ],
            ),
            const SizedBox(height: 12),
            // Visualization bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  if (totalVotes > 0) ...[
                    Flexible(
                      flex: yeaVotes,
                      child: Container(height: 8, color: GuvvyTheme.success),
                    ),
                    Flexible(
                      flex: nayVotes,
                      child: Container(height: 8, color: GuvvyTheme.error),
                    ),
                    Flexible(
                      flex: otherVotes,
                      child: Container(height: 8, color: GuvvyTheme.warning),
                    ),
                  ] else
                    Expanded(
                      child: Container(height: 8, color: Colors.grey.shade300),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVoteStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildVotingTimeline(List<Map<String, dynamic>> votes) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: votes.length,
      itemBuilder: (context, index) {
        final vote = votes[index];
        
        // Format the date
        final date = DateTime.parse(vote['date']);
        final formattedDate = '${date.month}/${date.day}/${date.year}';
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Timeline
              Column(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _getVoteColor(vote['result']),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: _getVoteIcon(vote['result']),
                    ),
                  ),
                  if (index < votes.length - 1)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: Colors.grey.shade300,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Vote content
              Expanded(
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              vote['billId'],
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          vote['billTitle'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          vote['description'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getVoteColor(vote['result']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Vote: ${vote['result']}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getVoteColor(vote['result']),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Color _getVoteColor(String vote) {
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
  
  Color _getChipColor(String filter) {
    switch (filter) {
      case 'Yea':
        return GuvvyTheme.success;
      case 'Nay':
        return GuvvyTheme.error;
      case 'Present':
        return GuvvyTheme.warning;
      default:
        return GuvvyTheme.primary;
    }
  }
  
  Widget _getVoteIcon(String vote) {
    final color = Colors.white;
    final size = 12.0;
    
    switch (vote) {
      case 'Yea':
        return Icon(Icons.check, color: color, size: size);
      case 'Nay':
        return Icon(Icons.close, color: color, size: size);
      case 'Present':
        return Icon(Icons.remove, color: color, size: size);
      default:
        return Icon(Icons.help_outline, color: color, size: size);
    }
  }
}