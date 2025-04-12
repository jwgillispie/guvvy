// lib/features/representatives/screens/representatives_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/govtrack_service.dart';
import 'package:guvvy/core/services/representative_image_service.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/representatives/presentation/widgets/position_education_widget.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representative_voting_history_widget.dart';
import 'package:guvvy/features/representatives/screens/voting_history_screen.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RepresentativeDetailsScreen extends StatefulWidget {
  final String representativeId;

  const RepresentativeDetailsScreen({
    Key? key,
    required this.representativeId,
  }) : super(key: key);

  @override
  State<RepresentativeDetailsScreen> createState() =>
      _RepresentativeDetailsScreenState();
}

class _RepresentativeDetailsScreenState
    extends State<RepresentativeDetailsScreen> {
  final GovTrackService _govTrackService = GovTrackService();
  List<Map<String, dynamic>> _votingHistory = [];
  bool _isLoadingVotes = false;

  @override
  void initState() {
    super.initState();
    // Load the representative details when the screen initializes
    context.read<RepresentativesBloc>().add(
          LoadRepresentativeDetails(widget.representativeId),
        );

    // Load voting history
    _loadVotingHistory();
  }

  Future<void> _loadVotingHistory() async {
    setState(() {
      _isLoadingVotes = true;
    });

    try {
      final votingData =
          await _govTrackService.getVotingHistory(widget.representativeId);

      if (mounted) {
        setState(() {
          _votingHistory = votingData;
          _isLoadingVotes = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() async {
          _isLoadingVotes = false;
          // Use mock data as fallback
          _votingHistory = await _govTrackService.getMockVotingData();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading voting data: $e')),
        );
      }
    }
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
                            _getPartyColor(representative.party)
                                .withOpacity(0.8),
                            _getPartyColor(representative.party)
                                .withOpacity(0.4),
                          ],
                        ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background pattern
                          Opacity(
                            opacity: 0.05,
                            child: _buildCoverImage(representative),
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
                                    // Use our image service for the representative's photo
                                    RepresentativeImageService
                                        .getRepresentativeImage(
                                      name: representative.name,
                                      role: representative.role,
                                      party: representative.party,
                                      radius: 40,
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                        Share.share(
                          'Check out ${representative.name}, ${representative.role} from ${representative.district}. Contact at ${representative.contact.phone}',
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

                      // Divider and section title
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Divider(),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Voting History',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VotingHistoryScreen(
                                      representativeId: representative.id,
                                      votingData: _votingHistory,
                                    ),
                                  ),
                                );
                              },
                              child: const Text('View All'),
                            ),
                          ],
                        ),
                      ),

                      // Voting history
                      if (_isLoadingVotes)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_votingHistory.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.how_to_vote,
                                  size: 48,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No voting history available',
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadVotingHistory,
                                  child: const Text('Try Again'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        _buildVotingPreview(_votingHistory),

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

  // Build a background cover image for the representative
  Widget _buildCoverImage(representative) {
    // This pattern shows geometric patterns appropriate for the gov level
    if (representative.level.toLowerCase() == 'federal') {
      return Image.network(
          'https://source.unsplash.com/random/?capitol,government',
          fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return const SizedBox(); // Return empty box if loading fails
      });
    } else if (representative.level.toLowerCase() == 'state') {
      return Image.network(
          'https://source.unsplash.com/random/?statehouse,government',
          fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return const SizedBox(); // Return empty box if loading fails
      });
    } else {
      return Image.network(
          'https://source.unsplash.com/random/?cityhall,government',
          fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) {
        return const SizedBox(); // Return empty box if loading fails
      });
    }
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
                _buildStatItem('Bills Sponsored',
                    representative.id.contains('mock') ? '12' : '8'),
                _buildStatItem('Years in Office',
                    representative.id.contains('mock') ? '4' : '2'),
                _buildStatItem(
                    'Committees',
                    representative.committees.isEmpty
                        ? (representative.level == 'federal' ? '3' : '2')
                        : representative.committees.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Get color based on political party
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

  Widget _buildInfoColumn(
      String label, String value, Color color, IconData icon) {
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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    _launchMaps(representative.contact.office);
                  },
                ),
                const Divider(height: 1),
                _buildContactItem(
                  'Phone',
                  representative.contact.phone,
                  Icons.phone,
                  onTap: () {
                    _makePhoneCall(representative.contact.phone);
                  },
                ),
                if (representative.contact.email != null) ...[
                  const Divider(height: 1),
                  _buildContactItem(
                    'Email',
                    representative.contact.email!,
                    Icons.email,
                    onTap: () {
                      _sendEmail(representative.contact.email!);
                    },
                  ),
                ],
                const Divider(height: 1),
                _buildContactItem(
                  'Website',
                  representative.contact.website,
                  Icons.public,
                  onTap: () {
                    _launchUrl(representative.contact.website);
                  },
                ),
                if (representative.contact.socialMedia.twitter != null ||
                    representative.contact.socialMedia.facebook != null) ...[
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.share,
                            size: 20, color: GuvvyTheme.primary),
                        const SizedBox(width: 12),
                        const Text('Social Media'),
                        const Spacer(),
                        if (representative.contact.socialMedia.twitter != null)
                          IconButton(
                            icon: const Icon(Icons.south_america,
                                color: Colors.blue),
                            onPressed: () {
                              _launchUrl(
                                  'https://twitter.com/${representative.contact.socialMedia.twitter}');
                            },
                          ),
                        if (representative.contact.socialMedia.facebook != null)
                          IconButton(
                            icon: const Icon(Icons.facebook,
                                color: Colors.indigo),
                            onPressed: () {
                              _launchUrl(
                                  'https://facebook.com/${representative.contact.socialMedia.facebook}');
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

  Widget _buildContactItem(String label, String value, IconData icon,
      {VoidCallback? onTap}) {
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
      // Return generic committees for reps that don't have real data
      if (representative.level == 'federal') {
        return _buildGenericCommitteesSection([
          'Budget Committee',
          'Foreign Affairs Committee',
          'Judiciary Committee'
        ], representative.level);
      } else if (representative.level == 'state') {
        return _buildGenericCommitteesSection(
            ['State Finance Committee', 'Education Committee'],
            representative.level);
      } else if (representative.level == 'local') {
        return _buildGenericCommitteesSection(
            ['Zoning Committee', 'Public Works Committee'],
            representative.level);
      }

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
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    'Member', // This would come from real data
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    // Show committee details or educational info about this committee
                    _showCommitteeInfo(context, committee);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Build mock committees section for representatives without real data
  Widget _buildGenericCommitteesSection(List<String> committees, String level) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Committee Memberships',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Example Data',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.deepOrange,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 1,
            margin: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListView.separated(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: committees.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final committee = committees[index];
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
                    'Typical $level committee',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                  trailing: const Icon(Icons.info_outline),
                  onTap: () {
                    // Show info about this being example data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'This is example committee data. Real data would be shown for actual representatives.'),
                        duration: Duration(seconds: 4),
                      ),
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

  Widget _buildVotingPreview(List<Map<String, dynamic>> votingHistory) {
    // Just show the top 3 most recent votes as a preview
    final recentVotes = votingHistory.take(3).toList();

    return Column(
      children: [
        ...recentVotes.map((vote) => _buildVotePreviewItem(vote)).toList(),
      ],
    );
  }

  Widget _buildVotePreviewItem(Map<String, dynamic> vote) {
    final voteDate = DateTime.parse(vote['date']);
    final formattedDate = '${voteDate.month}/${voteDate.day}/${voteDate.year}';
    final isYea = vote['yea_count'] > vote['nay_count'];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vote #${vote['rollnumber']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isYea ? GuvvyTheme.success : GuvvyTheme.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isYea ? 'Passed' : 'Failed',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isYea ? GuvvyTheme.success : GuvvyTheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              vote['vote_question'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 12),

            // Vote results visualization
            Row(
              children: [
                Expanded(
                  flex: vote['yea_count'],
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: GuvvyTheme.success,
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4)),
                    ),
                  ),
                ),
                Expanded(
                  flex: vote['nay_count'],
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: GuvvyTheme.error,
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Yea: ${vote['yea_count']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: GuvvyTheme.success,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Nay: ${vote['nay_count']}',
                  style: TextStyle(
                    fontSize: 14,
                    color: GuvvyTheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
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
                  _makePhoneCall(representative.contact.phone);
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
                    _sendEmail(representative.contact.email!);
                  },
                ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green.shade50,
                  child: const Icon(Icons.language, color: Colors.green),
                ),
                title: const Text('Visit Website'),
                subtitle: Text(representative.contact.website),
                onTap: () {
                  Navigator.pop(context);
                  _launchUrl(representative.contact.website);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCommitteeInfo(BuildContext context, String committeeName) {
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
                    committeeName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'About this Committee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCommitteeDescription(committeeName),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Committee Responsibilities',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._getCommitteeResponsibilities(committeeName)
                      .map((resp) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle,
                                    color: GuvvyTheme.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(resp)),
                              ],
                            ),
                          ))
                      .toList(),
                  const SizedBox(height: 32),
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

  String _getCommitteeDescription(String committeeName) {
    final lowerName = committeeName.toLowerCase();

    if (lowerName.contains('budget')) {
      return 'The Budget Committee is responsible for drafting and overseeing the budget process, managing fiscal planning, and ensuring financial accountability within the government.';
    } else if (lowerName.contains('foreign') || lowerName.contains('affairs')) {
      return 'The Foreign Affairs Committee oversees international relations, foreign policy, diplomatic missions, and international organizations. It plays a key role in shaping the country\'s engagement with other nations.';
    } else if (lowerName.contains('judiciary')) {
      return 'The Judiciary Committee handles matters relating to the administration of justice, including constitutional amendments, federal courts, civil liberties, and oversight of the Department of Justice.';
    } else if (lowerName.contains('finance')) {
      return 'The Finance Committee has jurisdiction over taxation, revenue measures, health programs, and trade agreements. It is one of the most powerful committees with broad economic impact.';
    } else if (lowerName.contains('education')) {
      return 'The Education Committee oversees education policy, student loans, school programs, and educational research. It influences how education is structured and funded across the country.';
    } else if (lowerName.contains('zoning')) {
      return 'The Zoning Committee regulates land use within the jurisdiction, determining how properties can be developed and what types of structures may be built in specific areas.';
    } else if (lowerName.contains('works') ||
        lowerName.contains('infrastructure')) {
      return 'The Public Works Committee oversees infrastructure development including roads, bridges, public buildings, water systems, and other public facilities.';
    }

    // Generic description
    return 'This committee focuses on specific policy areas and legislation within its jurisdiction. It reviews bills, conducts hearings, and provides oversight on related government activities.';
  }

  List<String> _getCommitteeResponsibilities(String committeeName) {
    final lowerName = committeeName.toLowerCase();

    if (lowerName.contains('budget')) {
      return [
        'Drafting and approving budget resolutions',
        'Monitoring government spending',
        'Reviewing fiscal impact of legislation',
        'Setting spending priorities',
        'Budget enforcement',
      ];
    } else if (lowerName.contains('foreign') || lowerName.contains('affairs')) {
      return [
        'Oversight of foreign policy implementation',
        'Authorization of foreign aid programs',
        'Reviewing treaties and international agreements',
        'Holding hearings on global issues',
        'Diplomatic relations oversight',
      ];
    } else if (lowerName.contains('judiciary')) {
      return [
        'Oversight of federal courts and judiciary',
        'Constitutional amendment considerations',
        'Civil rights and liberties legislation',
        'Immigration policy',
        'Criminal justice reform',
      ];
    }

    // Generic responsibilities
    return [
      'Reviewing legislation within its jurisdiction',
      'Conducting oversight hearings',
      'Investigating issues related to its focus area',
      'Making recommendations on relevant policy',
      'Approving certain appointments or actions',
    ];
  }

  // URL Launcher methods
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    await _launchUri(phoneUri);
  }

  Future<void> _sendEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Message from a constituent',
      },
    );
    await _launchUri(emailUri);
  }

  Future<void> _launchMaps(String address) async {
    final Uri mapsUri = Uri.parse(
      'https://maps.google.com/?q=${Uri.encodeComponent(address)}',
    );
    await _launchUri(mapsUri);
  }

  Future<void> _launchUrl(String url) async {
    // Check if the URL has a scheme
    final Uri uri = Uri.parse(url.contains('://') ? url : 'https://$url');
    await _launchUri(uri);
  }

  Future<void> _launchUri(Uri uri) async {
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not launch ${uri.toString()}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error launching link: $e')),
        );
      }
    }
  }
}
