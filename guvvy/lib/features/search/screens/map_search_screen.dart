// lib/features/search/screens/map_search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:guvvy/config/theme.dart';
import 'package:guvvy/core/services/geocoding_service.dart';
import 'package:guvvy/core/services/location_service.dart';
import 'package:guvvy/core/services/permissions_service.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_bloc.dart';
import 'package:guvvy/features/representatives/domain/bloc/representatives_event.dart';
import 'package:guvvy/features/search/domain/bloc/search_bloc.dart';
import 'package:guvvy/features/search/domain/bloc/search_event.dart';
import 'package:guvvy/features/search/domain/bloc/search_state.dart';
import 'package:guvvy/features/search/domain/entities/location.dart' as app_location;
import 'package:guvvy/features/search/widgets/enhanced_address_search.dart';

class MapSearchScreen extends StatefulWidget {
  const MapSearchScreen({Key? key}) : super(key: key);

  @override
  State<MapSearchScreen> createState() => _MapSearchScreenState();
}

class _MapSearchScreenState extends State<MapSearchScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  
  // Default to a central US location
  CameraPosition _initialCameraPosition = const CameraPosition(
    target: LatLng(39.8283, -98.5795), // Center of the US
    zoom: 3,
  );
  
  Marker? _selectedLocationMarker;
  bool _isLoading = false;
  bool _isMapReady = false;
  app_location.Location? _selectedLocation;
  
  @override
  void initState() {
    super.initState();
    _determineInitialPosition();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  // Get user's current location if they grant permission
  Future<void> _determineInitialPosition() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final hasPermission = await PermissionsService.checkLocationPermission(context);
      
      if (hasPermission) {
        final currentLocation = await LocationService.getCurrentLocation();
        
        setState(() {
          _initialCameraPosition = CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 11,
          );
        });
        
        // If the map is already ready, update the camera
        if (_isMapReady) {
          _updateCamera(currentLocation.latitude, currentLocation.longitude);
        }
      }
    } catch (e) {
      // Leave the default US map view
      print('Error getting current location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Update map camera position
  Future<void> _updateCamera(double latitude, double longitude) async {
    final controller = await _mapController.future;
    
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(latitude, longitude),
          zoom: 13,
        ),
      ),
    );
  }
  
  // Create or update location marker
  void _setLocationMarker(double latitude, double longitude, {String? address}) {
    setState(() {
      _selectedLocationMarker = Marker(
        markerId: const MarkerId('selected_location'),
        position: LatLng(latitude, longitude),
        infoWindow: InfoWindow(
          title: 'Selected Location',
          snippet: address ?? 'Latitude: $latitude, Longitude: $longitude',
        ),
      );
    });
  }
  
  // Called when an address is selected from search
  void _onAddressSelected(app_location.Location location) {
    setState(() {
      _selectedLocation = location;
    });
    
    // Update the map
    _updateCamera(location.latitude, location.longitude);
    _setLocationMarker(
      location.latitude, 
      location.longitude,
      address: location.formattedAddress,
    );
  }
  
  // Called when a location is selected by tapping on the map
  Future<void> _onMapTap(LatLng position) async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Reverse geocode to get the address
      final address = await GeocodingService.getAddressForCoordinates(
        position.latitude,
        position.longitude,
      );
      
      final location = app_location.Location(
        latitude: position.latitude,
        longitude: position.longitude,
        formattedAddress: address,
      );
      
      setState(() {
        _selectedLocation = location;
        _searchController.text = address;
      });
      
      // Update marker
      _setLocationMarker(
        position.latitude,
        position.longitude,
        address: address,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting address: $e')),
      );
      
      // Still set the marker even if we can't get the address
      final location = app_location.Location(
        latitude: position.latitude,
        longitude: position.longitude,
      );
      
      setState(() {
        _selectedLocation = location;
      });
      
      _setLocationMarker(position.latitude, position.longitude);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  // Find representatives with the selected location
  void _findRepresentatives() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a location first')),
      );
      return;
    }
    
    // Save search to history
    if (_selectedLocation!.formattedAddress != null) {
      context.read<SearchBloc>().add(
        SearchAddressSubmitted(
          _selectedLocation!.formattedAddress!,
        ),
      );
    }
    
    // Load representatives with the coordinates
    context.read<RepresentativesBloc>().add(
      LoadRepresentatives(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      ),
    );
    
    // Navigate to representatives screen
    Navigator.pushNamed(context, '/representatives');
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Representatives'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            tooltip: 'Current Location',
            onPressed: _determineInitialPosition,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Search History',
            onPressed: () {
              _showSearchHistoryBottomSheet(context);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            onMapCreated: (controller) {
              _mapController.complete(controller);
              setState(() {
                _isMapReady = true;
              });
            },
            markers: _selectedLocationMarker != null 
                ? {_selectedLocationMarker!} 
                : {},
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
          ),
          
          // Search Bar at the top
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: EnhancedAddressSearchField(
              onAddressSelected: _onAddressSelected,
              hintText: 'Enter an address to find representatives',
              controller: _searchController,
            ),
          ),
          
          // Find Representatives button at the bottom
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: SafeArea(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedLocation?.formattedAddress != null) ...[
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: GuvvyTheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedLocation!.formattedAddress!,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _selectedLocation != null ? _findRepresentatives : null,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: GuvvyTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Find My Representatives',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
  
  // Show search history in a bottom sheet
  void _showSearchHistoryBottomSheet(BuildContext context) {
    // Load search history
    context.read<SearchBloc>().add(SearchHistoryRequested());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Title
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              
              const Divider(height: 24),
              
              // Search history list
              Expanded(
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    if (state is SearchLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    
                    if (state is SearchHistoryLoaded) {
                      if (state.historyItems.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.history,
                                size: 64,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No recent searches',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.separated(
                        controller: scrollController,
                        itemCount: state.historyItems.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = state.historyItems[index];
                          return Dismissible(
                            key: Key(item.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16.0),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            onDismissed: (direction) {
                              context.read<SearchBloc>().add(
                                SearchHistoryItemDeleted(item.id),
                              );
                            },
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: GuvvyTheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.location_on_outlined,
                                  color: GuvvyTheme.primary,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                item.address,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                'Searched on ${_formatDate(item.timestamp)}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              onTap: () {
                                // Close bottom sheet
                                Navigator.pop(context);
                                
                                // Update UI with this search
                                _onAddressSelected(item.location);
                                
                                // If there's a formatted address, update search field
                                if (item.location.formattedAddress != null) {
                                  _searchController.text = item.location.formattedAddress!;
                                }
                              },
                            ),
                          );
                        },
                      );
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
              ),
              
              // Clear all button
              BlocBuilder<SearchBloc, SearchState>(
                builder: (context, state) {
                  if (state is SearchHistoryLoaded && state.historyItems.isNotEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: OutlinedButton(
                        onPressed: () {
                          // Show confirmation dialog
                          _showClearHistoryConfirmation(context);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_outline),
                            SizedBox(width: 8),
                            Text('Clear All Search History'),
                          ],
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Format date for display
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
  
  // Show confirmation dialog before clearing history
  void _showClearHistoryConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Search History'),
        content: const Text('Are you sure you want to clear all search history?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<SearchBloc>().add(SearchHistoryCleared());
              Navigator.of(context).pop();
            },
            child: const Text(
              'CLEAR',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}