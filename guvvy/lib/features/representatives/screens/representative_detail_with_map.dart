// lib/features/representatives/screens/representative_detail_with_map.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/geocoding_service.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_state.dart';
import 'package:guvvy/features/representatives/domain/entities/representative.dart';
import 'package:guvvy/features/representatives/presentation/widgets/representative_activity.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class RepresentativeDetailWithMap extends StatefulWidget {
  final String representativeId;

  const RepresentativeDetailWithMap({
    Key? key,
    required this.representativeId,
  }) : super(key: key);

  @override
  State<RepresentativeDetailWithMap> createState() => _RepresentativeDetailWithMapState();
}

class _RepresentativeDetailWithMapState extends State<RepresentativeDetailWithMap>
    with SingleTickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer();
  late TabController _tabController;
  Set<Polygon> _districtPolygons = {};
  bool _isMapReady = false;
  bool _isLoadingDistrict = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load representative data
    Future.microtask(() {
      context.read<RepresentativesBloc>().add(
        LoadRepresentativeDetails(widget.representativeId),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Initialize the map with district boundaries
  Future<void> _initializeMap(Representative representative) async {
    if (!_isMapReady) return;
    
    setState(() {
      _isLoadingDistrict = true;
    });
    
    try {
      // This is where you would fetch district boundaries from your backend
      // For now, we'll create a simple polygon as a placeholder
      final Set<Polygon> polygons = await _fetchDistrictBoundaries(representative);
      
      if (mounted) {
        setState(() {
          _districtPolygons = polygons;
          _isLoadingDistrict = false;
        });
      }
      
      // Get a point in the district (typically the representative's office)
      final LatLng districtCenter = await _getDistrictCenter(representative);
      
      // Update camera to show the district
      if (mounted) {
        final controller = await _mapController.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: districtCenter,
              zoom: 10,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingDistrict = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading district map: $e')),
        );
      }
    }
  }
  
  // This would fetch actual district boundaries from backend API
  Future<Set<Polygon>> _fetchDistrictBoundaries(Representative representative) async {
    // Mock implementation - in a real app, this would call an API
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Create a simple polygon as a placeholder based on rep's level
    final LatLng center = await _getDistrictCenter(representative);
    final Set<Polygon> polygons = {};
    
    // Different polygons based on level (smaller for local, larger for federal)
    double size = 0.05;
    if (representative.level == 'state') {
      size = 0.1;
    } else if (representative.level == 'federal') {
      size = 0.2;
    }
    
    polygons.add(
      Polygon(
        polygonId: PolygonId('district_${representative.id}'),
        points: [
          LatLng(center.latitude - size, center.longitude - size),
          LatLng(center.latitude - size, center.longitude + size),
          LatLng(center.latitude + size, center.longitude + size),
          LatLng(center.latitude + size, center.longitude - size),
        ],
        strokeWidth: 2,
        strokeColor: _getPartyColor(representative.party),
        fillColor: _getPartyColor(representative.party).withOpacity(0.2),
      ),
    );
    
    return polygons;
  }
  
  // Get the center point of the district for the map
  Future<LatLng> _getDistrictCenter(Representative representative) async {
    // Try to geocode the representative's office address
    try {
      if (representative.contact.office.isNotEmpty) {
        final location = await GeocodingService.getCoordinatesForAddress(
          representative.contact.office,
        );
        return LatLng(location.latitude, location.longitude);
      }
    } catch (e) {
      // If geocoding fails, fallback to default coordinates
    }
    
    // Fallback coordinates based on level
    switch (representative.level) {
      case 'federal':
        return const LatLng(38.8899, -77.0091); // US Capitol
      case 'state':
        // Try to extract state from district
        final stateCodes = {
          'AL': const LatLng(32.3792, -86.3077), // Alabama
          'AK': const LatLng(58.3019, -134.4197), // Alaska
          'AZ': const LatLng(33.4484, -112.0740), // Arizona
          'AR': const LatLng(34.7465, -92.2896), // Arkansas
          'CA': const LatLng(38.5816, -121.4944), // California
          'CO': const LatLng(39.7392, -104.9903), // Colorado
          'CT': const LatLng(41.7658, -72.6734), // Connecticut
          'DE': const LatLng(39.1582, -75.5244), // Delaware
          'FL': const LatLng(30.4383, -84.2807), // Florida
          'GA': const LatLng(33.7490, -84.3880), // Georgia
          'HI': const LatLng(21.3069, -157.8583), // Hawaii
          'ID': const LatLng(43.6150, -116.2023), // Idaho
          'IL': const LatLng(39.7817, -89.6501), // Illinois
          'IN': const LatLng(39.7684, -86.1581), // Indiana
          'IA': const LatLng(41.5868, -93.6250), // Iowa
          'KS': const LatLng(39.0483, -95.6775), // Kansas
          'KY': const LatLng(38.1894, -84.8715), // Kentucky
          'LA': const LatLng(30.4515, -91.1871), // Louisiana
          'ME': const LatLng(44.3106, -69.7795), // Maine
          'MD': const LatLng(38.9784, -76.4922), // Maryland
          'MA': const LatLng(42.3601, -71.0589), // Massachusetts
          'MI': const LatLng(42.7325, -84.5555), // Michigan
          'MN': const LatLng(44.9537, -93.0900), // Minnesota
          'MS': const LatLng(32.2988, -90.1848), // Mississippi
          'MO': const LatLng(38.5767, -92.1735), // Missouri
          'MT': const LatLng(46.5958, -112.0270), // Montana
          'NE': const LatLng(40.8136, -96.7026), // Nebraska
          'NV': const LatLng(39.1638, -119.7674), // Nevada
          'NH': const LatLng(43.2081, -71.5376), // New Hampshire
          'NJ': const LatLng(40.2206, -74.7597), // New Jersey
          'NM': const LatLng(35.6870, -105.9378), // New Mexico
          'NY': const LatLng(42.6526, -73.7562), // New York
          'NC': const LatLng(35.7796, -78.6382), // North Carolina
          'ND': const LatLng(46.8083, -100.7837), // North Dakota
          'OH': const LatLng(39.9612, -82.9988), // Ohio
          'OK': const LatLng(35.4676, -97.5164), // Oklahoma
          'OR': const LatLng(44.9429, -123.0351), // Oregon
          'PA': const LatLng(40.2732, -76.8867), // Pennsylvania
          'RI': const LatLng(41.8240, -71.4128), // Rhode Island
          'SC': const LatLng(34.0007, -81.0348), // South Carolina
          'SD': const LatLng(44.3683, -100.3510), // South Dakota
          'TN': const LatLng(36.1627, -86.7816), // Tennessee
          'TX': const LatLng(30.2672, -97.7431), // Texas
          'UT': const LatLng(40.7608, -111.8910), // Utah
          'VT': const LatLng(44.2601, -72.5754), // Vermont
          'VA': const LatLng(37.5407, -77.4360), // Virginia
          'WA': const LatLng(47.0379, -122.9007), // Washington
          'WV': const LatLng(38.3498, -81.6326), // West Virginia
          'WI': const LatLng(43.0731, -89.4012), // Wisconsin
          'WY': const LatLng(41.1400, -104.8202), // Wyoming
          'DC': const LatLng(38.9072, -77.0369), // District of Columbia
        };
        
        // Try to extract state code from district
        for (final stateCode in stateCodes.keys) {
          if (representative.district.contains(stateCode)) {
            return stateCodes[stateCode]!;
          }
        }
        
        return const LatLng(39.8283, -98.5795); // Center of US
      
      case 'local':
      default:
        return const LatLng(39.8283, -98.5795); // Center of US
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RepresentativesBloc, RepresentativesState>(
      listener: (context, state) {
        if (state is RepresentativeDetailsLoaded && _isMapReady) {
          // Initialize map when rep details are loaded and map is ready
          _initializeMap(state.representative);
        }
      },
      builder: (context, state) {
        if (state is RepresentativesLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (state is RepresentativeDetailsLoaded) {
          final representative = state.representative;
          
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                return [
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
                          Share.share(
                            'Check out ${representative.name}, ${representative.role} - Contact at ${representative.contact.phone}',
                          );
                        },
                      ),
                    ],
                    bottom: TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Profile'),
                        Tab(text: 'Map'),
                        Tab(text: 'Activity'),
                      ],
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  // Profile Tab
                  _buildProfileTab(representative),
                  
                  // Map Tab
                  _buildMapTab(representative),
                  
                  // Activity Tab
                  _buildActivityTab(representative),
                ],
              ),
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
  
  // Profile Tab Content
  Widget _buildProfileTab(Representative representative) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Party & district info card
          _buildInfoCard(representative),
          
          // Contact information
          _buildContactSection(representative),
          
          // Committee memberships
          _buildCommitteesSection(representative),
        ],
      ),
    );
  }
  
  // Map Tab Content
  Widget _buildMapTab(Representative representative) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(39.8283, -98.5795), // Center of US
            zoom: 3,
          ),
          onMapCreated: (controller) {
            _mapController.complete(controller);
            setState(() {
              _isMapReady = true;
            });
            
            // Initialize district boundaries after map is ready
            _initializeMap(representative);
          },
          polygons: _districtPolygons,
          myLocationEnabled: false,
          zoomControlsEnabled: true,
          compassEnabled: true,
          mapToolbarEnabled: false,
        ),
        
        // Loading indicator for district boundaries
        if (_isLoadingDistrict)
          const Center(
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading district boundaries...'),
                  ],
                ),
              ),
            ),
          ),
        
        // Info panel
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    representative.district.isNotEmpty
                        ? '${representative.name} - District: ${representative.district}'
                        : representative.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level: ${representative.level.toUpperCase()} - ${representative.role}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  // Activity Tab Content
  Widget _buildActivityTab(Representative representative) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RepresentativeActivity(representative: representative),
        ],
      ),
    );
  }
  
  Widget _buildInfoCard(representative) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.contact_mail, color: GuvvyTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Office address
            if (representative.contact.office.isNotEmpty)
              _buildContactItem(
                'Office',
                representative.contact.office,
                Icons.location_on,
                onTap: () => _launchMaps(representative.contact.office),
              ),
            
            // Phone
            if (representative.contact.phone.isNotEmpty)
              _buildContactItem(
                'Phone',
                representative.contact.phone,
                Icons.phone,
                onTap: () => _makePhoneCall(representative.contact.phone),
              ),
            
            // Email
            if (representative.contact.email != null)
              _buildContactItem(
                'Email',
                representative.contact.email!,
                Icons.email,
                onTap: () => _sendEmail(representative.contact.email!),
              ),
            
            // Website
            if (representative.contact.website.isNotEmpty)
              _buildContactItem(
                'Website',
                representative.contact.website,
                Icons.language,
                onTap: () => _launchUrl(representative.contact.website),
              ),
            
            // Social media
            if (representative.contact.socialMedia.twitter != null ||
                representative.contact.socialMedia.facebook != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    const Icon(Icons.share, size: 20, color: GuvvyTheme.primary),
                    const SizedBox(width: 12),
                    const Text(
                      'Social Media:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Spacer(),
                    if (representative.contact.socialMedia.twitter != null)
                      IconButton(
                        icon: const Icon(Icons.south_america, color: Colors.blue),
                        onPressed: () => _launchUrl(
                          'https://twitter.com/${representative.contact.socialMedia.twitter}',
                        ),
                      ),
                    if (representative.contact.socialMedia.facebook != null)
                      IconButton(
                        icon: const Icon(Icons.facebook, color: Colors.indigo),
                        onPressed: () => _launchUrl(
                          'https://facebook.com/${representative.contact.socialMedia.facebook}',
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildContactItem(String label, String value, IconData icon, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: GuvvyTheme.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommitteesSection(representative) {
    if (representative.committees.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.groups, color: GuvvyTheme.primary),
                SizedBox(width: 8),
                Text(
                  'Committee Memberships',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...representative.committees.map((committee) => _buildCommitteeItem(committee)).toList(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCommitteeItem(String committee) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.blueGrey.shade100,
            child: Text(
              committee[0],
              style: const TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  committee,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Member', // This could be dynamic based on real data
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
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
              
              // Call option
              if (representative.contact.phone.isNotEmpty)
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
              
              // Email option
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
              
              // Website option
              if (representative.contact.website.isNotEmpty)
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