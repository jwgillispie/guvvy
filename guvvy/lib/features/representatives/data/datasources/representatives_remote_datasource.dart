// lib/features/representatives/data/datasources/representatives_remote_datasource.dart
import 'dart:convert';
import 'package:guvvy/core/services/geocoding_service.dart';
import 'package:http/http.dart' as http;
import '../models/representative_model.dart';

abstract class RepresentativesRemoteDataSource {
  Future<List<RepresentativeModel>> getRepresentativesByLocation(double latitude, double longitude);
  Future<RepresentativeModel> getRepresentativeById(String id);
}

class RepresentativesApiDataSource implements RepresentativesRemoteDataSource {
  final http.Client client;
  final String civicInfoApiKey; // Google Civic Information API key
  
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
    
    try {
      // Using Google Civic Information API
      final response = await client.get(
        Uri.parse(
          'https://www.googleapis.com/civicinfo/v2/representatives'
          '?address=${Uri.encodeComponent(address)}'
          '&includeOffices=true'
          '&key=$civicInfoApiKey'
        ),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return _parseRepresentativesResponse(responseData);
      } else {
        throw Exception('Failed to load representatives: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to connect to representative API: $e');
    }
  }

  @override
  Future<RepresentativeModel> getRepresentativeById(String id) async {
    try {
      // In a real app, this might call different APIs based on the representative's level
      // (federal, state, local)
      final response = await client.get(
        Uri.parse('https://api.example.com/representatives/$id'),
      );

      if (response.statusCode == 200) {
        return RepresentativeModel.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load representative details');
      }
    } catch (e) {
      throw Exception('Failed to connect to server');
    }
  }
  
  // Parse the Google Civic Info API response
  List<RepresentativeModel> _parseRepresentativesResponse(Map<String, dynamic> responseData) {
    final List<RepresentativeModel> representatives = [];
    
    // Extract offices (positions) and officials (people)
    final offices = responseData['offices'] as List<dynamic>;
    final officials = responseData['officials'] as List<dynamic>;
    
    // Match offices with officials
    for (var office in offices) {
      final officeName = office['name'] as String;
      final divisionId = office['divisionId'] as String;
      final officialIndices = office['officialIndices'] as List<dynamic>;
      
      String level = 'local';
      if (divisionId.contains('country')) {
        level = 'federal';
      } else if (divisionId.contains('state')) {
        level = 'state';
      }
      
      for (var index in officialIndices) {
        final official = officials[index as int];
        
        final name = official['name'] as String;
        final party = official['party'] ?? 'Unknown';
        
        // Process contact info
        final phones = official['phones'] as List<dynamic>? ?? [];
        final emails = official['emails'] as List<dynamic>? ?? [];
        final urls = official['urls'] as List<dynamic>? ?? [];
        
        // Process channels (social media)
        final channels = official['channels'] as List<dynamic>? ?? [];
        String? twitterAccount;
        String? facebookAccount;
        
        for (var channel in channels) {
          if (channel['type'] == 'Twitter') {
            twitterAccount = channel['id'];
          } else if (channel['type'] == 'Facebook') {
            facebookAccount = channel['id'];
          }
        }
        
        // Create representative model
        final rep = RepresentativeModel(
          id: '$level:${name.replaceAll(' ', '_')}',
          name: name,
          party: party,
          role: officeName,
          level: level,
          district: _extractDistrictFromDivisionId(divisionId),
          contact: ContactModel(
            office: official['address']?[0]?.toString() ?? '',
            phone: phones.isNotEmpty ? phones[0] as String : '',
            email: emails.isNotEmpty ? emails[0] as String : null,
            website: urls.isNotEmpty ? urls[0] as String : '',
            socialMedia: SocialMediaModel(
              twitter: twitterAccount,
              facebook: facebookAccount,
            ),
          ),
          committees: [], // Would need additional API calls to get committee data
        );
        
        representatives.add(rep);
      }
    }
    
    return representatives;
  }
  
  String _extractDistrictFromDivisionId(String divisionId) {
    // Example: ocd-division/country:us/state:ny/cd:19
    final parts = divisionId.split('/');
    
    for (var part in parts) {
      if (part.startsWith('cd:')) {
        return part.substring(3);
      } else if (part.startsWith('state:')) {
        final stateCode = part.substring(6);
        return stateCode.toUpperCase();
      }
    }
    
    return '';
  }
}