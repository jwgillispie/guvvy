// lib/features/representatives/screens/representatives_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representative_activity.dart';

class RepresentativeDetailsScreen extends StatefulWidget {
  final String representativeId;

  const RepresentativeDetailsScreen({
    Key? key,
    required this.representativeId,
  }) : super(key: key);

  @override
  State<RepresentativeDetailsScreen> createState() => _RepresentativeDetailsScreenState();
}

class _RepresentativeDetailsScreenState extends State<RepresentativeDetailsScreen> {
  @override
  void initState() {
    super.initState();
    // Load the representative details when the screen initializes
    Future.microtask(() {
      context.read<RepresentativesBloc>().add(
        LoadRepresentativeDetails(widget.representativeId),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RepresentativesBloc, RepresentativesState>(
      builder: (context, state) {
        if (state is RepresentativesLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is RepresentativeDetailsLoaded) {
          final representative = state.representative;
          
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                // Enhanced app bar with profile image and gradient
                SliverAppBar(
                  expandedHeight: 200.0,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _getPartyColor(representative.party).withOpacity(0.8),
                            _getPartyColor(representative.party).withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background pattern
                          Opacity(
                            opacity: 0.05,
                            child: Image.network(
                              'https://api.placeholder.com/450/350',
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Representative details
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 40,
                                      backgroundColor: Colors.white,
                                      child: Text(
                                        representative.name[0],
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold,
                                          color: _getPartyColor(representative.party),
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
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(1, 1),
                                                  blurRadius: 3,
                                                  color: Colors.black26,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            representative.role,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              shadows: [
                                                Shadow(
                                                  offset: Offset(1, 1),
                                                  blurRadius: 2,
                                                  color: Colors.black26,
                                                ),
                                              ],
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
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        state.isSaved ? Icons.star : Icons.star_border,
                        color: state.isSaved ? Colors.amber : Colors.white,
                      ),
                      onPressed: () {
                        context.read<RepresentativesBloc>().add(
                          state.isSaved
                            ? UnsaveRepresentativeEvent(representative.id)
                            : SaveRepresentativeEvent(representative.id),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share, color: Colors.white),
                      onPressed: () {
                        // Share functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Share feature coming soon')),
                        );
                      },
                    ),
                  ],
                ),
                
                // Main content
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Party & district info card
                      _buildInfoCard(representative),
                      
                      // Contact information
                      _buildContactSection(representative),
                      
                      // Committee memberships
                      _buildCommitteesSection(representative),
                      
                      // Recent activity
                      RepresentativeActivity(representative: representative),
                      
                      // Add some bottom padding
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
            // Add a floating action button for quick contact
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () {
                // Show contact options
                _showContactOptions(context, representative);
              },
              backgroundColor: _getPartyColor(representative.party),
              label: const Text('Contact'),
              icon: const Icon(Icons.send),
            ),
          );
        } else if (state is RepresentativesError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(
              child: Text('Error loading representative: ${state.message}'),
            ),
          );
        }
        
        // Default loading state
        return const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
  
  Widget _buildInfoCard(representative) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildInfoColumn(
                  'Party',
                  representative.party,
                  _getPartyColor(representative.party),
                  Icons.how_to_vote,
                ),
                const SizedBox(width: 16),
                _buildInfoColumn(
                  'Level',
                  representative.level.toUpperCase(),
                  GuvvyTheme.primary,
                  Icons.public,
                ),
                const SizedBox(width: 16),
                _buildInfoColumn(
                  'District',
                  representative.district,
                  Colors.teal,
                  Icons.map,
                ),
              ],
            ),
            const Divider(height: 32),
            // Add term statistics - this would be real data in a production app
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Bills Sponsored', '12'),
                _buildStatItem('Years in Office', '4'),
                _buildStatItem('Committees', representative.committees.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoColumn(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
  
  Widget _buildContactSection(representative) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildContactItem(
                  'Office',
                  representative.contact.office,
                  Icons.location_on,
                  onTap: () {
                    // Open maps
                  },
                ),
                const Divider(height: 1),
                _buildContactItem(
                  'Phone',
                  representative.contact.phone,
                  Icons.phone,
                  onTap: () {
                    // Make a call
                  },
                ),
                if (representative.contact.email != null) ...[
                  const Divider(height: 1),
                  _buildContactItem(
                    'Email',
                    representative.contact.email!,
                    Icons.email,
                    onTap: () {
                      // Send email
                    },
                  ),
                ],
                const Divider(height: 1),
                _buildContactItem(
                  'Website',
                  representative.contact.website,
                  Icons.public,
                  onTap: () {
                    // Open website
                  },
                ),
                if (representative.contact.socialMedia.twitter != null || 
                    representative.contact.socialMedia.facebook != null) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.share, size: 20, color: GuvvyTheme.primary),
                        const SizedBox(width: 12),
                        const Text('Social Media'),
                        const Spacer(),
                        if (representative.contact.socialMedia.twitter != null)
                          IconButton(
                            icon: const Icon(Icons.south_america, color: Colors.blue),
                            onPressed: () {
                              // Open Twitter
                            },
                          ),
                        if (representative.contact.socialMedia.facebook != null)
                          IconButton(
                            icon: const Icon(Icons.facebook, color: Colors.indigo),
                            onPressed: () {
                              // Open Facebook
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildContactItem(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: GuvvyTheme.primary),
      title: Text(label),
      subtitle: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
  
  Widget _buildCommitteesSection(representative) {
    if (representative.committees.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Committee Memberships',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: representative.committees.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final committee = representative.committees[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueGrey.shade100,
                    child: Text(
                      committee[0],
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(committee),
                  subtitle: Text(
                    'Member',  // This would come from real data
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Navigate to committee details
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Committee details for $committee coming soon')),
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
  
  void _showContactOptions(BuildContext context, representative) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Contact Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.phone, color: Colors.blue),
                ),
                title: const Text('Call Office'),
                subtitle: Text(representative.contact.phone),
                onTap: () {
                  Navigator.pop(context);
                  // Call functionality
                },
              ),
              if (representative.contact.email != null)
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade50,
                    child: const Icon(Icons.email, color: Colors.red),
                  ),
                  title: const Text('Send Email'),
                  subtitle: Text(representative.contact.email!),
                  onTap: () {
                    Navigator.pop(context);
                    // Email functionality
                  },
                ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: const Icon(Icons.public, color: Colors.green),
                ),
                title: const Text('Visit Website'),
                subtitle: Text(representative.contact.website),
                onTap: () {
                  Navigator.pop(context);
                  // Website functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
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
}