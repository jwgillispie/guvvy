// lib/features/representatives/screens/voting_history_screen.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/mock_data_service.dart';
import 'package:intl/intl.dart';

class VotingHistoryScreen extends StatefulWidget {
  final String? representativeId;
  final List<Map<String, dynamic>> votingData;

  const VotingHistoryScreen({
    Key? key, 
    this.representativeId,
    required this.votingData,
  }) : super(key: key);

  @override
  State<VotingHistoryScreen> createState() => _VotingHistoryScreenState();
}

class _VotingHistoryScreenState extends State<VotingHistoryScreen> with SingleTickerProviderStateMixin {
  String _selectedVoteFilter = 'All';
  String _selectedCategoryFilter = 'All';
  late TabController _tabController;
  
  final List<String> _categories = [
    'All',
    'Economy',
    'Healthcare',
    'Environment',
    'Education',
    'Infrastructure',
    'Foreign Policy',
    'Defense',
    'Social Issues',
  ];
  
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
    // Transform the voting data to match our expected format
    final transformedVotes = widget.votingData.map((vote) {
      return {
        'billId': 'H.R. ${vote['rollnumber']}',
        'billTitle': vote['vote_question'] ?? 'Vote on Legislation',
        'description': _getVoteDescription(vote),
        'date': vote['date'],
        'result': _getVoteResult(vote),
        'categories': _determineCategories(vote),
        'withParty': _isWithParty(vote),
      };
    }).toList();

    final voteTypeFilters = ['All', 'Yea', 'Nay', 'Present'];
    
    final filteredVotes = transformedVotes.where((vote) {
      final passesVoteFilter = _selectedVoteFilter == 'All' || 
                              vote['result'] == _selectedVoteFilter;
      final passesCategoryFilter = _selectedCategoryFilter == 'All' || 
                                  vote['categories'].contains(_selectedCategoryFilter);
      return passesVoteFilter && passesCategoryFilter;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Voting History'),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Timeline'),
            Tab(text: 'Statistics'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTimelineTab(transformedVotes, filteredVotes, voteTypeFilters),
          _buildStatisticsTab(transformedVotes),
        ],
      ),
    );
  }

  String _getVoteDescription(Map<String, dynamic> vote) {
    final question = vote['vote_question'] ?? 'Legislative Vote';
    final result = vote['vote_result'] ?? 'Completed';
    return '$question - Result: $result';
  }

  String _getVoteResult(Map<String, dynamic> vote) {
    final yeaCount = vote['yea_count'] ?? 0;
    final nayCount = vote['nay_count'] ?? 0;
    return yeaCount > nayCount ? 'Yea' : 'Nay';
  }

  List<String> _determineCategories(Map<String, dynamic> vote) {
    final question = (vote['vote_question'] ?? '').toLowerCase();
    if (question.contains('speaker')) return ['Leadership'];
    if (question.contains('budget') || question.contains('spending')) return ['Economy'];
    if (question.contains('health') || question.contains('care')) return ['Healthcare'];
    if (question.contains('environment') || question.contains('climate')) return ['Environment'];
    if (question.contains('education')) return ['Education'];
    if (question.contains('infrastructure') || question.contains('transportation')) return ['Infrastructure'];
    if (question.contains('foreign') || question.contains('international')) return ['Foreign Policy'];
    if (question.contains('defense') || question.contains('military')) return ['Defense'];
    if (question.contains('social') || question.contains('rights')) return ['Social Issues'];
    return ['Legislation'];
  }

  bool _isWithParty(Map<String, dynamic> vote) {
    // This is a simplified version - in reality you'd compare with party majority
    return vote['nominate_mid_1'] != null && vote['nominate_mid_1'] > 0;
  }

  
  Widget _buildTimelineTab(List<Map<String, dynamic>> allVotes, List<Map<String, dynamic>> filteredVotes, List<String> voteTypeFilters) {
    return Column(
      children: [
        // Stats summary card
        _buildVotingSummaryCard(allVotes),
        
        // Filter section
        _buildFilterSection(voteTypeFilters),
        
        // Voting timeline
        Expanded(
          child: filteredVotes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.filter_list, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        'No votes matching current filters',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedVoteFilter = 'All';
                            _selectedCategoryFilter = 'All';
                          });
                        },
                        child: const Text('Clear All Filters'),
                      ),
                    ],
                  ),
                )
              : _buildVotingTimeline(filteredVotes),
        ),
      ],
    );
  }
  
  Widget _buildFilterSection(List<String> voteTypeFilters) {
    return Container(
      color: Colors.grey.shade50,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vote Type Filters
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(
              'Filter by Vote',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: voteTypeFilters.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final option = voteTypeFilters[index];
                final isSelected = option == _selectedVoteFilter;
                
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedVoteFilter = option;
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
          
          // Category Filters
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 8),
            child: Text(
              'Filter by Category',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategoryFilter;
                
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCategoryFilter = category;
                    });
                  },
                  backgroundColor: Colors.grey.shade100,
                  selectedColor: GuvvyTheme.primary.withOpacity(0.1),
                  labelStyle: TextStyle(
                    color: isSelected ? GuvvyTheme.primary : Colors.grey.shade700,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              },
            ),
          ),
          
          const Divider(height: 16),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsTab(List<Map<String, dynamic>> votes) {
    // Calculate category statistics
    final Map<String, int> categoryVoteCounts = {};
    
    // Initialize with all categories
    for (final category in _categories.where((c) => c != 'All')) {
      categoryVoteCounts[category] = 0;
    }
    
    // Count votes in each category
    for (final vote in votes) {
      final List<dynamic> categories = vote['categories'] ?? [];
      for (final category in categories) {
        if (categoryVoteCounts.containsKey(category)) {
          categoryVoteCounts[category] = categoryVoteCounts[category]! + 1;
        }
      }
    }
    
    // Sort categories by vote count
    final sortedCategories = categoryVoteCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
      
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall voting statistics
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voting by Category',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category bars
                  ...sortedCategories.map((entry) => _buildCategoryBar(
                    entry.key, 
                    entry.value, 
                    votes.length,
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Monthly voting activity
          _buildMonthlyVotingCard(votes),
          
          const SizedBox(height: 24),
          
          // Vote consistency card  
          _buildVoteConsistencyCard(votes),
        ],
      ),
    );
  }
  
  Widget _buildCategoryBar(String category, int count, int total) {
    final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
    final barWidth = total > 0 ? count / total : 0;
    
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
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barWidth.toDouble(),
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(_getCategoryColor(category)),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMonthlyVotingCard(List<Map<String, dynamic>> votes) {
    // Group votes by month  
    final Map<String, int> monthlyVotes = {};
    
    for (final vote in votes) {
      final date = DateTime.parse(vote['date']);
      final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
      
      if (!monthlyVotes.containsKey(monthKey)) {
        monthlyVotes[monthKey] = 0;
      }
      
      monthlyVotes[monthKey] = monthlyVotes[monthKey]! + 1;
    }
    
    // Sort months chronologically
    final sortedMonths = monthlyVotes.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Voting Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              height: 200,
              child: sortedMonths.isEmpty
                ? Center(
                    child: Text(
                      'No monthly data available',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  )
                : _buildMonthlyChart(sortedMonths),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMonthlyChart(List<MapEntry<String, int>> monthlyData) {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: monthlyData.length,
      separatorBuilder: (context, index) => const SizedBox(width: 8),
      itemBuilder: (context, index) {
        final entry = monthlyData[index];
        final parts = entry.key.split('-');
        final year = parts[0];
        final month = parts[1];
        final monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final monthName = monthNames[int.parse(month) - 1];
        
        // Calculate bar height (maximum height: 150)
        final maxVotes = monthlyData.map((e) => e.value).reduce((a, b) => a > b ? a : b);
        final barHeight = maxVotes > 0 ? (entry.value / maxVotes * 150).toDouble() : 0.0;
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Vote count
            Text(
              entry.value.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            
            // Bar
            Container(
              width: 24,
              height: barHeight,
              decoration: BoxDecoration(
                color: GuvvyTheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ),
            
            // Month label
            const SizedBox(height: 8),
            Text(
              monthName,
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              year,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
            ),
          ],
        );
      },
    );
  }
  
Widget _buildVoteConsistencyCard(List<Map<String, dynamic>> votes) {
    // Calculate party-line vote consistency
    int partyLineVotes = 0;
    int crossPartyVotes = 0;
    
    for (final vote in votes) {
      // This is simulated logic - in a real app you would compare with party majority vote
      final String voteResult = vote['result'];
      final bool isWithParty = vote['withParty'] ?? true;
      
      if (isWithParty) {
        partyLineVotes++;
      } else {
        crossPartyVotes++;
      }
    }
    
    final total = partyLineVotes + crossPartyVotes;
    final partyLinePercentage = total > 0 ? (partyLineVotes / total * 100).toStringAsFixed(1) : '0';
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Voting Consistency',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Visual representation
            Row(
              children: [
                _buildConsistencyPie(partyLineVotes, crossPartyVotes),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$partyLinePercentage% Party-line Votes',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Votes in line with party majority: $partyLineVotes',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cross-party votes: $crossPartyVotes',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConsistencyPie(int partyLine, int crossParty) {
    final total = partyLine + crossParty;
    
    return SizedBox(
      width: 100,
      height: 100,
      child: total == 0
          ? Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'No Data',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            )
          : Stack(
              children: [
                CustomPaint(
                  size: const Size(100, 100),
                  painter: PieChartPainter(
                    values: [partyLine, crossParty],
                    colors: [GuvvyTheme.primary, Colors.orange],
                  ),
                ),
                Center(
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 2,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '$total\nVotes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
        final formattedDate = DateFormat('MM/dd/yyyy').format(date);
        
        // Get categories
        final List<dynamic> categories = vote['categories'] ?? [];
        
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
                        
                        // Categories
                        if (categories.isNotEmpty) ...[
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: categories.map((category) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCategoryColor(category).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _getCategoryColor(category),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
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
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Economy':
        return Colors.green;
      case 'Healthcare':
        return Colors.blue;
      case 'Environment':
        return Colors.teal;
      case 'Education':
        return Colors.purple;
      case 'Infrastructure':
        return Colors.amber.shade800;
      case 'Foreign Policy':
        return Colors.indigo;
      case 'Defense':
        return Colors.red.shade700;
      case 'Social Issues':
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
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

// Custom painter for pie chart
class PieChartPainter extends CustomPainter {
  final List<int> values;
  final List<Color> colors;

  PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.fold<int>(0, (prev, curr) => prev + curr);
    if (total == 0) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    double startAngle = -90 * (3.14159 / 180); // Start from top (in radians)

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * 3.14159;
      
      paint.color = colors[i];
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}