// lib/features/representatives/presentation/widgets/representatives_card.dart
import 'package:flutter/material.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/representatives/presentation/widgets/position_education_widget.dart';

class EnhancedRepresentativeCard extends StatelessWidget {
  final Representative representative;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const EnhancedRepresentativeCard({
    Key? key,
    required this.representative,
    required this.onTap,
    this.isSaved = false,
    required this.onSave,
  }) : super(key: key);

  Color _getPartyColor(String party) {
    switch (party.toLowerCase()) {
      case 'democratic':
        return GuvvyTheme.democrat;
      case 'republican':
        return GuvvyTheme.republican;
      case 'independent':
        return GuvvyTheme.independent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final partyColor = _getPartyColor(representative.party);
    final initials = representative.name
        .split(' ')
        .map((name) => name.isNotEmpty ? name[0] : '')
        .join('')
        .toUpperCase();

    return Card(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile image or initials with gradient background
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          partyColor.withOpacity(0.8),
                          partyColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: partyColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Name and details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                representative.name,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                isSaved ? Icons.star : Icons.star_border,
                                color: isSaved ? Colors.amber : Colors.grey,
                              ),
                              onPressed: onSave,
                              constraints: const BoxConstraints(
                                minWidth: 36,
                                minHeight: 36,
                              ),
                              padding: EdgeInsets.zero,
                            ),
                          ],
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${representative.role} • ${representative.party}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.info_outline,
                                color: theme.primaryColor,
                                size: 20,
                              ),
                              tooltip: 'Learn about this position',
                              constraints: const BoxConstraints(
                                minWidth: 32,
                                minHeight: 32,
                              ),
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PositionEducationWidget(
                                      positionTitle: representative.role,
                                      level: representative.level,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Level indicator
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: partyColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            representative.level.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: partyColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Educational note about the position
              _buildPositionInfoCard(context, representative.role),

              // Contact info
              if (representative.contact.email != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        representative.contact.email!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Committees
              if (representative.committees.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'COMMITTEES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: GuvvyTheme.textTertiary,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: representative.committees.map((committee) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        committee,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Action button
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onTap,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: partyColor,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('View Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPositionInfoCard(BuildContext context, String positionTitle) {
    // Basic position descriptions for common roles
    final String description = _getPositionDescription(positionTitle);
    
    if (description.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, size: 16, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                'About this Position',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PositionEducationWidget(
                      positionTitle: positionTitle,
                      level: representative.level,
                    ),
                  ),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Learn More',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPositionDescription(String positionTitle) {
    final String title = positionTitle.toLowerCase();
    
    if (title.contains('senator')) {
      if (title.contains('state')) {
        return 'State Senators create and vote on state laws, approve state budgets, and represent their districts at the state level.';
      } else {
        return 'U.S. Senators serve six-year terms in the upper chamber of Congress. They represent entire states, confirming presidential appointments and ratifying treaties.';
      }
    } else if (title.contains('representative') || title.contains('congressman')) {
      if (title.contains('state')) {
        return 'State Representatives create and vote on state laws, approve the state budget, and address state-level policy issues.';
      } else {
        return 'U.S. Representatives serve two-year terms in the House, the "people\'s chamber" of Congress. They represent smaller districts and initiate revenue bills.';
      }
    } else if (title.contains('governor')) {
      return 'Governors are the chief executives of states, similar to the President at the federal level. They implement state laws and can issue executive orders.';
    } else if (title.contains('mayor')) {
      return 'Mayors are the chief executives of cities or towns. They oversee city departments, services, and represent the city officially.';
    } else if (title.contains('council')) {
      return 'City Council Members create local ordinances (laws), approve city budgets, set tax rates, and oversee city services.';
    } else if (title.contains('commissioner')) {
      return 'County Commissioners govern counties, creating county ordinances, approving budgets, and overseeing county services.';
    }
    
    return '';
  }
}