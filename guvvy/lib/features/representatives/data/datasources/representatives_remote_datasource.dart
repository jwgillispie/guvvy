// lib/features/representatives/data/datasources/representatives_remote_datasource.dart
import 'dart:convert';
import 'package:guvvy/core/services/geocoding_service.dart';
import 'package:http/http.dart' as http;
import 'package:guvvy/core/services/api_keys.dart';
import '../models/representative_model.dart';

abstract class RepresentativesRemoteDataSource {
  Future<List<RepresentativeModel>> getRepresentativesByLocation(double latitude, double longitude);
  Future<RepresentativeModel> getRepresentativeById(String id);
}

class RepresentativesApiDataSource implements RepresentativesRemoteDataSource {
  final http.Client client;
  final String civicInfoApiKey;
  
  RepresentativesApiDataSource({
    required this.client,
    required this.civicInfoApiKey,
  });

  @override
  Future<List<RepresentativeModel>> getRepresentativesByLocation(
    double latitude,
    double longitude,
  ) async {
    // Get address from coordinates for Google Civic Info API
    final address = await GeocodingService.getAddressForCoordinates(latitude, longitude);
    final representatives = <RepresentativeModel>[];
    
    // Get federal and state representatives from Google Civic Info API
    try {
      await _fetchFromCivicInfoApi(address, representatives);
    } catch (e) {
      print('Error fetching from Civic Info API: $e');
      // Continue to next API even if this one fails
    }
    
    // Get state representatives from Open States API
    try {
      await _fetchFromOpenStatesApi(latitude, longitude, representatives);
    } catch (e) {
      print('Error fetching from Open States API: $e');
      // Continue even if this API fails
    }
    
    return representatives;
  }
  
  // Fetch representatives from Google Civic Info API
  Future<void> _fetchFromCivicInfoApi(
    String address, 
    List<RepresentativeModel> representatives,
  ) async {
    final response = await client.get(
      Uri.parse(
        'https://www.googleapis.com/civicinfo/v2/representatives'
        '?address=${Uri.encodeComponent(address)}'
        '&includeOffices=true'
        '&key=$civicInfoApiKey'
      ),
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _parseCivicInfoResponse(data, representatives);
    } else {
      throw Exception('Failed to load from Civic Info API: ${response.body}');
    }
  }
  
  // Parse response from Google Civic Info API
  void _parseCivicInfoResponse(
    Map<String, dynamic> data, 
    List<RepresentativeModel> representatives,
  ) {
    if (!data.containsKey('offices') || !data.containsKey('officials')) {
      return;
    }
    
    final offices = data['offices'] as List<dynamic>;
    final officials = data['officials'] as List<dynamic>;
    
    for (var office in offices) {
      final String officeName = office['name'];
      final List<dynamic> officialIndices = office['officialIndices'];
      
      // Determine government level
      String level = 'local';
      final division = office['divisionId'] as String? ?? '';
      
      if (division.contains('country')) {
        level = 'federal';
      } else if (division.contains('state')) {
        level = 'state';
      }
      
      // Get district from division ID
      String district = _extractDistrictFromDivision(division);
      
      for (final index in officialIndices) {
        if (index >= officials.length) continue;
        
        final official = officials[index];
        
        // Basic info
        final String name = official['name'];
        final String party = official['party'] ?? 'Unknown';
        
        // Contact info
        final addresses = official['address'] as List<dynamic>? ?? [];
        final phones = official['phones'] as List<dynamic>? ?? [];
        final emails = official['emails'] as List<dynamic>? ?? [];
        final urls = official['urls'] as List<dynamic>? ?? [];
        
        // Generate a predictable ID
        final id = '$level-${name.toLowerCase().replaceAll(' ', '-')}-$district';
        
        // Extract social media info
        String? twitter;
        String? facebook;
        
        final channels = official['channels'] as List<dynamic>? ?? [];
        for (final channel in channels) {
          if (channel['type'] == 'Twitter') {
            twitter = channel['id'];
          } else if (channel['type'] == 'Facebook') {
            facebook = channel['id'];
          }
        }
        
        // Create contact model
        final contactModel = ContactModel(
          office: addresses.isNotEmpty 
              ? _formatAddress(addresses[0] as Map<String, dynamic>) 
              : '',
          phone: phones.isNotEmpty ? phones[0] : '',
          email: emails.isNotEmpty ? emails[0] : null,
          website: urls.isNotEmpty ? urls[0] : '',
          socialMedia: SocialMediaModel(
            twitter: twitter,
            facebook: facebook,
          ),
        );
        
        // Create representative model
        final representative = RepresentativeModel(
          id: id,
          name: name,
          party: party,
          role: officeName,
          level: level,
          district: district,
          contact: contactModel,
          committees: [], // Would need additional API calls for committee data
        );
        
        representatives.add(representative);
      }
    }
  }
  
  // Fetch representatives from Open States API
  Future<void> _fetchFromOpenStatesApi(
    double latitude, 
    double longitude,
    List<RepresentativeModel> representatives,
  ) async {
    final response = await client.get(
      Uri.parse(
        'https://v3.openstates.org/people.geo'
        '?lat=$latitude'
        '&lng=$longitude'
        '&include=sources'
      ),
      headers: {
        'X-API-Key': ApiKeys.openStatesKey,
      },
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data.containsKey('results')) {
        final List<dynamic> results = data['results'];
        
        for (final person in results) {
          // Skip if we can't generate a proper ID
          if (!person.containsKey('id')) continue;
          
          final String id = 'openstate-${person['id']}';
          final String name = person['name'] ?? '';
          final String party = person['party'] ?? 'Unknown';
          
          // Get current role
          String role = 'State Legislator';
          String district = '';
          
          if (person.containsKey('current_role') && person['current_role'] != null) {
            final currentRole = person['current_role'];
            role = currentRole['title'] ?? 'State Legislator';
            district = currentRole['district'] ?? '';
          }
          
          // Get contact information
          final String phone = _extractContactInfo(person, 'voice') ?? '';
          final String? email = _extractContactInfo(person, 'email');
          final String website = person['openstates_url'] ?? '';
          
          // Create contact model
          final contactModel = ContactModel(
            office: _extractOfficeAddress(person) ?? '',
            phone: phone,
            email: email,
            website: website,
            socialMedia: SocialMediaModel(
              twitter: null, // Open States doesn't provide this directly
              facebook: null,
            ),
          );
          
          // Create representative model
          final representative = RepresentativeModel(
            id: id,
            name: name,
            party: party,
            role: role,
            level: 'state',
            district: district,
            contact: contactModel,
            committees: _extractCommittees(person),
          );
          
          representatives.add(representative);
        }
      }
    } else {
      throw Exception('Failed to load from Open States API: ${response.body}');
    }
  }
  
  // Helper to extract contact info from Open States API response
  String? _extractContactInfo(Map<String, dynamic> person, String type) {
    if (person.containsKey('offices')) {
      final List<dynamic> offices = person['offices'];
      for (final office in offices) {
        if (office['type'] == type) {
          return office['voice'];
        }
      }
    }
    return null;
  }
  
  // Helper to extract office address from Open States API response
  String? _extractOfficeAddress(Map<String, dynamic> person) {
    if (person.containsKey('offices')) {
      final List<dynamic> offices = person['offices'];
      for (final office in offices) {
        if (office.containsKey('address')) {
          return office['address'];
        }
      }
    }
    return null;
  }
  
  // Helper to extract committees from Open States API response
  List<String> _extractCommittees(Map<String, dynamic> person) {
    final committees = <String>[];
    
    if (person.containsKey('committee_memberships')) {
      final memberships = person['committee_memberships'] as Map<String, dynamic>;
      
      memberships.forEach((key, value) {
        committees.add(key);
      });
    }
    
    return committees;
  }
  
  // Format address from Google Civic Info API
  String _formatAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    
    if (address.containsKey('line1')) {
      parts.add(address['line1']);
    }
    
    if (address.containsKey('city')) {
      parts.add(address['city']);
    }
    
    if (address.containsKey('state')) {
      parts.add(address['state']);
    }
    
    if (address.containsKey('zip')) {
      parts.add(address['zip']);
    }
    
    return parts.join(', ');
  }
  
  // Extract district from division ID
  String _extractDistrictFromDivision(String division) {
    // Example: ocd-division/country:us/state:ny/cd:19
    
    // Try to extract congressional district
    final cdMatch = RegExp(r'cd:(\d+)').firstMatch(division);
    if (cdMatch != null) {
      return cdMatch.group(1) ?? '';
    }
    
    // Try to extract state legislative district
    final sldMatch = RegExp(r'sldl:(\d+)').firstMatch(division);
    if (sldMatch != null) {
      return sldMatch.group(1) ?? '';
    }
    
    // Try to extract state
    final stateMatch = RegExp(r'state:(\w{2})').firstMatch(division);
    if (stateMatch != null) {
      return stateMatch.group(1)?.toUpperCase() ?? '';
    }
    
    // Fallback
    return '';
  }

  @override
  Future<RepresentativeModel> getRepresentativeById(String id) async {
    // If it's an Open States ID, use their API
    if (id.startsWith('openstate-')) {
      final openStatesId = id.substring(10); // Remove 'openstate-' prefix
      
      final response = await client.get(
        Uri.parse('https://v3.openstates.org/people/$openStatesId'),
        headers: {
          'X-API-Key': ApiKeys.openStatesKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data.containsKey('result')) {
          final person = data['result'];
          
          return RepresentativeModel(
            id: id,
            name: person['name'] ?? '',
            party: person['party'] ?? 'Unknown',
            role: person['current_role']?['title'] ?? 'State Legislator',
            level: 'state',
            district: person['current_role']?['district'] ?? '',
            contact: ContactModel(
              office: _extractOfficeAddress(person) ?? '',
              phone: _extractContactInfo(person, 'voice') ?? '',
              email: _extractContactInfo(person, 'email'),
              website: person['openstates_url'] ?? '',
              socialMedia: const SocialMediaModel(),
            ),
            committees: _extractCommittees(person),
          );
        }
      }
      
      throw Exception('Failed to load representative details from Open States API');
    }
    
    // For federal/local representatives, we need a different approach
    // Parse the ID to determine the level and other info
    final idParts = id.split('-');
    if (idParts.length >= 2) {
      final level = idParts[0];
      
      // Try to reconstruct the name from the ID
      final nameWithDashes = idParts.sublist(1, idParts.length - 1).join(' ');
      final name = nameWithDashes.split(' ').map((word) => 
        word.isNotEmpty ? word[0].toUpperCase() + word.substring(1) : ''
      ).join(' ');
      
      // Try to retrieve district if available
      final district = idParts.last;
      
      // For federal/local representatives, we'll need to look them up again
      // This is inefficient but ensures we have the latest data
      try {
        // Get address from the district or use a generic one
        String address = '';
        if (level == 'federal' && district.isNotEmpty) {
          address = 'United States';
        } else if (level == 'state' && district.length == 2) {
          address = district; // State code
        } else {
          address = 'United States'; // Fallback
        }
        
        // Fetch representatives again and find the matching one
        final representatives = <RepresentativeModel>[];
        await _fetchFromCivicInfoApi(address, representatives);
        
        // Try to find the exact representative by ID
        final exactMatch = representatives.where((rep) => rep.id == id).toList();
        if (exactMatch.isNotEmpty) {
          return exactMatch.first;
        }
        
        // If no exact match, try to find by name and level
        final nameMatches = representatives.where((rep) => 
          rep.name.toLowerCase().contains(name.toLowerCase()) && 
          rep.level == level
        ).toList();
        
        if (nameMatches.isNotEmpty) {
          return nameMatches.first;
        }
      } catch (e) {
        print('Error refetching representative: $e');
      }
      
      // Fallback: return a minimal representative model
      return RepresentativeModel(
        id: id,
        name: name,
        party: 'Unknown',
        role: level.capitalize() + ' Representative',
        level: level,
        district: district,
        contact: ContactModel(
          office: '',
          phone: '',
          email: null,
          website: '',
          socialMedia: const SocialMediaModel(),
        ),
        committees: [],
      );
    }
    
    throw Exception('Unable to parse representative ID: $id');
  }
}

// Add this extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    return isEmpty ? '' : this[0].toUpperCase() + substring(1);
  }
}

// Update this in lib/features/representatives/data/datasources/representatives_remote_datasource.dart

// A hybrid implementation that falls back to mock data if API fails
class HybridRepresentativesDataSource implements RepresentativesRemoteDataSource {
  final RepresentativesApiDataSource apiDataSource;
  final RepresentativesRemoteDataSource mockDataSource;
  
  HybridRepresentativesDataSource({
    required this.apiDataSource,
    required this.mockDataSource,
  });
  
  @override
  Future<List<RepresentativeModel>> getRepresentativesByLocation(double latitude, double longitude) async {
    try {
      // Try to get real data first
      print('HybridSource: Attempting to fetch real data for coordinates: $latitude, $longitude');
      final results = await apiDataSource.getRepresentativesByLocation(latitude, longitude);
      
      if (results.isNotEmpty) {
        print('HybridSource: Found ${results.length} representatives from API');
        return results;
      }
      // If no results, fall back to mock data
      print('HybridSource: No representatives found from API - Falling back to mock data');
      final mockResults = await mockDataSource.getRepresentativesByLocation(latitude, longitude);
      print('HybridSource: Found ${mockResults.length} mock representatives');
      return mockResults;
    } catch (e) {
      print('HybridSource: API error: $e - Falling back to mock data');
      // Fall back to mock data if API fails
      final mockResults = await mockDataSource.getRepresentativesByLocation(latitude, longitude);
      print('HybridSource: Using ${mockResults.length} mock representatives due to error');
      
      // Create new models with modified ids instead of trying to modify the existing ones
      final labeledMockResults = mockResults.map((rep) {
        return RepresentativeModel(
          id: 'mock-${rep.id}',  // Prepend 'mock-' to the id
          name: rep.name,
          party: rep.party,
          role: rep.role,
          level: rep.level,
          district: rep.district,
          contact: rep.contact,
          committees: rep.committees,
        );
      }).toList();
      
      return labeledMockResults;
    }
  }
  
  @override
  Future<RepresentativeModel> getRepresentativeById(String id) async {
    try {
      // Check if this is a mock ID (created by our hybrid implementation)
      if (id.startsWith('mock-')) {
        final originalId = id.substring(5); // Remove 'mock-' prefix
        print('HybridSource: Fetching mock representative with original ID: $originalId');
        final mockRep = await mockDataSource.getRepresentativeById(originalId);
        
        // Create a new model with the mock- prefix preserved
        return RepresentativeModel(
          id: id, // Keep the mock-prefixed id
          name: mockRep.name,
          party: mockRep.party,
          role: mockRep.role,
          level: mockRep.level,
          district: mockRep.district,
          contact: mockRep.contact,
          committees: mockRep.committees,
        );
      }
      
      // Try to get from real API first
      print('HybridSource: Attempting to fetch representative with ID: $id from API');
      return await apiDataSource.getRepresentativeById(id);
    } catch (e) {
      print('HybridSource: API error when fetching representative by ID: $e - Falling back to mock data');
      
      // Get from mock source but preserve the ID format
      try {
        String lookupId = id;
        if (id.startsWith('mock-')) {
          lookupId = id.substring(5); // Remove 'mock-' prefix
        }
        
        final mockRep = await mockDataSource.getRepresentativeById(lookupId);
        
        // Return with the original requested ID to maintain consistency
        return RepresentativeModel(
          id: id,
          name: mockRep.name,
          party: mockRep.party,
          role: mockRep.role,
          level: mockRep.level,
          district: mockRep.district,
          contact: mockRep.contact,
          committees: mockRep.committees,
        );
      } catch (mockError) {
        // If both real and mock fail, rethrow the original error
        print('HybridSource: Mock data source also failed: $mockError');
        throw Exception('Failed to get representative details: $e');
      }
    }
  }
}