// lib/features/representatives/presentation/widgets/representative_voting_history_widget.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:intl/intl.dart';

class RepresentativeVotingHistory extends StatefulWidget {
  final Representative representative;
  final List<Map<String, dynamic>> votingData;

  const RepresentativeVotingHistory({
    Key? key,
    required this.representative,
    required this.votingData,
  }) : super(key: key);

  @override
  State<RepresentativeVotingHistory> createState() => _RepresentativeVotingHistoryState();
}

class _RepresentativeVotingHistoryState extends State<RepresentativeVotingHistory> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'All';
  final List<String> _voteFilters = ['All', 'Yea', 'Nay', 'Present'];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredVotes = _getFilteredVotes();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tab bar for overview vs detailed list
        TabBar(
          controller: _tabController,
          labelColor: GuvvyTheme.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: GuvvyTheme.primary,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Vote History'),
          ],
        ),
        
        // Tab content
        SizedBox(
          height: 500, // Adjust height as needed
          child: TabBarView(
            controller: _tabController,
            children: [
              // Overview tab with statistics
              _buildOverviewTab(),
              
              // Detailed vote history tab
              _buildVoteHistoryTab(filteredVotes),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildOverviewTab() {
    // Calculate stats
    final stats = _calculateVoteStats();
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vote summary card
          _buildSummaryCard(stats),
          
          const SizedBox(height: 24),
          
          // Vote by category
          _buildCategoryBreakdown(),
          
          const SizedBox(height: 24),
          
          // Recent votes preview
          _buildRecentVotes(),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voting Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn('Total', stats['total'].toString(), Colors.blue),
                _buildStatColumn('Yea', '${stats['yea']} (${stats['yeaPercent']}%)', GuvvyTheme.success),
                _buildStatColumn('Nay', '${stats['nay']} (${stats['nayPercent']}%)', GuvvyTheme.error),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Visual bar representation
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Row(
                children: [
                  Flexible(
                    flex: stats['yea'],
                    child: Container(height: 8, color: GuvvyTheme.success),
                  ),
                  Flexible(
                    flex: stats['nay'],
                    child: Container(height: 8, color: GuvvyTheme.error),
                  ),
                  if (stats['other'] > 0)
                    Flexible(
                      flex: stats['other'],
                      child: Container(height: 8, color: GuvvyTheme.warning),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
  
  Widget _buildCategoryBreakdown() {
    // Get category breakdown - in real app, this would come from actual vote categories
    final categories = _getCategoryBreakdown();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Votes by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            
            ...categories.entries.map((entry) => _buildCategoryBar(
              entry.key, 
              entry.value, 
              widget.votingData.length,
            )).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCategoryBar(String category, int count, int total) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    final color = _getCategoryColor(category);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text('$count votes ($percentage%)'),
            ],
          ),
          const SizedBox(height: 4),
          
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: total > 0 ? count / total : 0,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRecentVotes() {
    // Only show the 3 most recent votes
    final recentVotes = widget.votingData.take(3).toList();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Votes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {
                    _tabController.animateTo(1); // Switch to history tab
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          ...recentVotes.map((vote) => _buildVoteItem(vote)).toList(),
          
          if (recentVotes.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('No recent voting activity'),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildVoteHistoryTab(List<Map<String, dynamic>> filteredVotes) {
    return Column(
      children: [
        // Filter chips
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Filter by vote:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _voteFilters.map((filter) => 
                  FilterChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      }
                    },
                    selectedColor: _getFilterColor(filter).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: _selectedFilter == filter 
                        ? _getFilterColor(filter) 
                        : Colors.black,
                    ),
                  )
                ).toList(),
              ),
            ],
          ),
        ),
        
        // Votes list
        Expanded(
          child: filteredVotes.isEmpty
            ? const Center(
                child: Text('No votes match the selected filter'),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: filteredVotes.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final vote = filteredVotes[index];
                  return _buildVoteItem(vote);
                },
              ),
        ),
      ],
    );
  }
  
  Widget _buildVoteItem(Map<String, dynamic> vote) {
    final voteDate = DateTime.parse(vote['date']);
    final formattedDate = DateFormat('MMM d, yyyy').format(voteDate);
    final voteResult = vote['yea_count'] > vote['nay_count'] ? 'Yea' : 'Nay';
    
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      title: Text(
        vote['vote_question'],
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Text(
            'Vote #${vote['rollnumber']} • $formattedDate',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: vote['yea_count'] / (vote['yea_count'] + vote['nay_count']),
                    minHeight: 8,
                    backgroundColor: GuvvyTheme.error.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(GuvvyTheme.success),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '${vote['yea_count']}-${vote['nay_count']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _getVoteColor(voteResult).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          voteResult,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getVoteColor(voteResult),
          ),
        ),
      ),
      onTap: () {
        // Navigate to vote details
        _showVoteDetails(vote);
      },
    );
  }
  
  void _showVoteDetails(Map<String, dynamic> vote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Text(
                    vote['vote_question'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  _buildInfoRow('Vote Number', '#${vote['rollnumber']}'),
                  _buildInfoRow('Date', DateFormat('MMMM d, yyyy').format(DateTime.parse(vote['date']))),
                  _buildInfoRow('Result', vote['vote_result'] ?? 'Unknown'),
                  
                  const SizedBox(height: 24),
                  const Text(
                    'Vote Breakdown',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Vote breakdown visualization
                  Row(
                    children: [
                      Expanded(
                        flex: vote['yea_count'],
                        child: Column(
                          children: [
                            Text(
                              '${vote['yea_count']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: GuvvyTheme.success,
                              ),
                            ),
                            const Text('Yea'),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: vote['nay_count'],
                        child: Column(
                          children: [
                            Text(
                              '${vote['nay_count']}',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: GuvvyTheme.error,
                              ),
                            ),
                            const Text('Nay'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Row(
                      children: [
                        Expanded(
                          flex: vote['yea_count'],
                          child: Container(
                            height: 24,
                            color: GuvvyTheme.success,
                            child: const Center(
                              child: Text(
                                'Yea',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: vote['nay_count'],
                          child: Container(
                            height: 24,
                            color: GuvvyTheme.error,
                            child: const Center(
                              child: Text(
                                'Nay',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GuvvyTheme.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  // Helper Functions
  
  Map<String, dynamic> _calculateVoteStats() {
    final totalVotes = widget.votingData.length;
    final yeaVotes = widget.votingData.where((vote) => vote['yea_count'] > vote['nay_count']).length;
    final nayVotes = widget.votingData.where((vote) => vote['yea_count'] < vote['nay_count']).length;
    final otherVotes = totalVotes - yeaVotes - nayVotes;
    
    final yeaPercent = totalVotes > 0 ? (yeaVotes / totalVotes * 100).round() : 0;
    final nayPercent = totalVotes > 0 ? (nayVotes / totalVotes * 100).round() : 0;
    
    return {
      'total': totalVotes,
      'yea': yeaVotes,
      'nay': nayVotes,
      'other': otherVotes,
      'yeaPercent': yeaPercent,
      'nayPercent': nayPercent,
    };
  }
  
  List<Map<String, dynamic>> _getFilteredVotes() {
    if (_selectedFilter == 'All') {
      return widget.votingData;
    }
    
    return widget.votingData.where((vote) {
      final voteResult = vote['yea_count'] > vote['nay_count'] ? 'Yea' : 'Nay';
      return voteResult == _selectedFilter;
    }).toList();
  }
  
  Map<String, int> _getCategoryBreakdown() {
    // In a real app, this would be based on actual vote categories
    // For now, let's create synthetic categories
    final categories = <String, int>{
      'Economy': 0,
      'Healthcare': 0,
      'Environment': 0,
      'Defense': 0,
      'Foreign Policy': 0,
    };
    
    // Assign votes to categories using vote question text
    for (final vote in widget.votingData) {
      final question = vote['vote_question'].toString().toLowerCase();
      
      if (question.contains('budget') || question.contains('tax') || question.contains('economic')) {
        categories['Economy'] = (categories['Economy'] ?? 0) + 1;
      } else if (question.contains('health') || question.contains('care') || question.contains('medical')) {
        categories['Healthcare'] = (categories['Healthcare'] ?? 0) + 1;
      } else if (question.contains('climate') || question.contains('environment') || question.contains('energy')) {
        categories['Environment'] = (categories['Environment'] ?? 0) + 1;
      } else if (question.contains('defense') || question.contains('military') || question.contains('security')) {
        categories['Defense'] = (categories['Defense'] ?? 0) + 1;
      } else if (question.contains('foreign') || question.contains('international') || question.contains('treaty')) {
        categories['Foreign Policy'] = (categories['Foreign Policy'] ?? 0) + 1;
      } else {
        // Add to a random category for demonstration
        final keys = categories.keys.toList();
        final randomKey = keys[widget.votingData.indexOf(vote) % keys.length];
        categories[randomKey] = (categories[randomKey] ?? 0) + 1;
      }
    }
    
    return categories;
  }
  
  Color _getVoteColor(String voteResult) {
    switch (voteResult) {
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
  
  Color _getFilterColor(String filter) {
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
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Economy':
        return Colors.green;
      case 'Healthcare':
        return Colors.blue;
      case 'Environment':
        return Colors.teal;
      case 'Defense':
        return Colors.red;
      case 'Foreign Policy':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}