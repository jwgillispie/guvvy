// lib/features/representatives/presentation/widgets/position_education_widget.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/government_position_data.dart';

class PositionEducationWidget extends StatefulWidget {
  final String positionTitle;
  final String level;

  const PositionEducationWidget({
    Key? key,
    required this.positionTitle,
    required this.level,
  }) : super(key: key);

  @override
  State<PositionEducationWidget> createState() => _PositionEducationWidgetState();
}

class _PositionEducationWidgetState extends State<PositionEducationWidget> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Map<String, dynamic> positionInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    positionInfo = GovernmentPositionData.getPositionInfoByTitle(widget.positionTitle);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('About ${widget.positionTitle}'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Powers'),
            Tab(text: 'Limitations'),
            Tab(text: 'Fun Facts'),
          ],
          isScrollable: true,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildPowersTab(),
          _buildLimitationsTab(),
          _buildFunFactsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getLevelColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              widget.level.toUpperCase(),
              style: TextStyle(
                color: _getLevelColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            'What is a ${widget.positionTitle}?',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            positionInfo['description'] ?? '',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          // Term length
          Row(
            children: [
              Icon(Icons.calendar_today, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Term Length:',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            positionInfo['termLength'] ?? 'Varies',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          
          // Requirements
          Row(
            children: [
              Icon(Icons.assignment, color: theme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Requirements:',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            positionInfo['requirements'] ?? 'Varies by position',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          
          // Responsibilities
          Text(
            'Key Responsibilities',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          
          ..._buildListItems(
            positionInfo['responsibilities'] ?? [],
            Icons.check_circle_outline,
            theme.primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildPowersTab() {
    final theme = Theme.of(context);
    final powers = positionInfo['powers'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Powers of a ${widget.positionTitle}',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'These are the key powers and authorities granted to this position:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          ..._buildListItems(powers, Icons.gavel, Colors.indigo),
          
          if (powers.isEmpty)
            Center(
              child: Text(
                'No specific powers information available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLimitationsTab() {
    final theme = Theme.of(context);
    final limitations = positionInfo['limitations'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Limitations & Constraints',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Even elected officials have limits to their authority:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          ..._buildListItems(limitations, Icons.block, Colors.red.shade700),
          
          if (limitations.isEmpty)
            Center(
              child: Text(
                'No specific limitations information available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // Checks and balances explanation
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.balance, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Checks and Balances',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The American system of government is designed with "checks and balances" to ensure no single branch or official becomes too powerful. Each elected position has specific powers that are kept in check by other parts of government.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFunFactsTab() {
    final theme = Theme.of(context);
    final funFacts = positionInfo['funFacts'] ?? [];
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Interesting Facts',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            'Learn some interesting facts about this position:',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          
          for (int i = 0; i < funFacts.length; i++)
            Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        funFacts[i],
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          if (funFacts.isEmpty)
            Center(
              child: Column(
                children: [
                  Icon(Icons.lightbulb_outline, size: 64, color: Colors.amber),
                  const SizedBox(height: 16),
                  Text(
                    'No fun facts available for this position',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildListItems(List<dynamic> items, IconData icon, Color iconColor) {
    final theme = Theme.of(context);
    
    return items.map((item) => Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    )).toList();
  }

  Color _getLevelColor() {
    switch (widget.level.toLowerCase()) {
      case 'federal':
        return Colors.indigo;
      case 'state':
        return Colors.teal;
      case 'local':
        return Colors.amber.shade800;
      default:
        return Colors.grey;
    }
  }
}