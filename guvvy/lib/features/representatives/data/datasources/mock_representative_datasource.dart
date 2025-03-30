// Create this file at lib/features/representatives/data/datasources/mock_representative_datasource.dart
import 'package:guvvy/core/services/mock_data_service.dart';
import 'package:guvvy/features/representatives/data/datasources/representatives_remote_datasource.dart';
import 'package:guvvy/features/representatives/data/models/representative_model.dart';
// Update this in lib/features/representatives/data/datasources/mock_representative_datasource.dart

class MockRepresentativeDataSource implements RepresentativesRemoteDataSource {
  @override
  Future<List<RepresentativeModel>> getRepresentativesByLocation(
    double latitude,
    double longitude,
  ) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    print('MockDataSource: Generating mock representatives for coordinates: $latitude, $longitude');
    
    // Customize mock data to match the provided location
    return _generateLocationSpecificMockData(latitude, longitude);
  }

  @override
  Future<RepresentativeModel> getRepresentativeById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));

    // Return the detailed mock data
    print('MockDataSource: Generating mock representative for ID: $id');
    return MockDataService.getMockRepresentativeDetails(id);
  }
  
  // Generate mock data that's more representative of the location
  List<RepresentativeModel> _generateLocationSpecificMockData(double latitude, double longitude) {
    // Determine what area we're looking at
    String state = _getStateForCoordinates(latitude, longitude);
    String stateName = _getStateNameFromCode(state);
    
    // Create data with the state in the name/district
    return [
      RepresentativeModel(
        id: 'mock-federal-senator-$state',
        name: 'Senator John $stateName',
        party: 'Democratic',
        role: 'Senator',
        level: 'federal',
        district: '$state-Senate',
        contact: ContactModel(
          office: '123 Senate Building, Washington DC',
          phone: '(202) 555-0123',
          email: 'john.$stateName@senate.gov',
          website: 'www.smith.senate.gov',
          socialMedia: SocialMediaModel( // Removed const
            twitter: '@senator$stateName',
            facebook: 'senator$stateName',
          ),
        ),
        committees: ['Finance', 'Foreign Relations'],
      ),
      RepresentativeModel(
        id: 'mock-federal-rep-$state',
        name: 'Rep. Sarah $stateName',
        party: 'Republican',
        role: 'Representative',
        level: 'federal',
        district: '$state-01',
        contact: ContactModel(
          office: '456 House Building, Washington DC',
          phone: '(202) 555-0124',
          email: 'sarah.$stateName@house.gov',
          website: 'www.johnson.house.gov',
          socialMedia: SocialMediaModel( // Removed const
            twitter: '@rep$stateName',
            facebook: 'rep$stateName',
          ),
        ),
        committees: ['Armed Services', 'Education'],
      ),
      RepresentativeModel(
        id: 'mock-state-$state',
        name: 'Michael $stateName',
        party: 'Democratic',
        role: 'State Senator',
        level: 'state',
        district: '$state-State-5',
        contact: ContactModel(
          office: '789 State Capitol, $stateName',
          phone: '(217) 555-0125',
          email: 'michael.$stateName@ilsenate.gov',
          website: 'www.chen.ilsenate.gov',
          socialMedia: SocialMediaModel( // Removed const
            twitter: '@sen$stateName',
            facebook: 'sen$stateName',
          ),
        ),
        committees: ['State Budget', 'Transportation'],
      ),
      RepresentativeModel(
        id: 'mock-local-$state',
        name: 'Emily $stateName',
        party: 'Independent',
        role: 'City Council Member',
        level: 'local',
        district: 'Ward 3',
        contact: ContactModel(
          office: '321 City Hall, $stateName',
          phone: '(312) 555-0126',
          email: 'emily.$stateName@citycouncil.gov',
          website: 'www.rodriguez.council.gov',
          socialMedia: SocialMediaModel( // Removed const
            twitter: '@cm$stateName',
            facebook: 'cm$stateName',
          ),
        ),
        committees: ['Zoning', 'Public Safety'],
      ),
    ];
  }
  
  // Determine state based on coordinates
  String _getStateForCoordinates(double latitude, double longitude) {
    // This is a very simple approximation
    // In a real app, you'd use a proper geocoding service
    
    // West Coast
    if (longitude < -115) {
      if (latitude > 42) return 'WA';
      if (latitude > 38) return 'OR';
      return 'CA';
    }
    
    // Mountain West
    if (longitude < -100) {
      if (latitude > 44) return 'MT';
      if (latitude > 40) return 'CO';
      return 'AZ';
    }
    
    // Midwest
    if (longitude < -85) {
      if (latitude > 43) return 'WI';
      if (latitude > 40) return 'IL';
      return 'MO';
    }
    
    // East Coast
    if (latitude > 42) return 'NY';
    if (latitude > 39) return 'PA';
    if (latitude > 36) return 'VA';
    if (latitude > 33) return 'GA';
    return 'FL';
  }
  
  // Get state name from code
  String _getStateNameFromCode(String stateCode) {
    final stateNames = {
      'AL': 'Alabama',
      'AK': 'Alaska',
      'AZ': 'Arizona',
      'AR': 'Arkansas',
      'CA': 'California',
      'CO': 'Colorado',
      'CT': 'Connecticut',
      'DE': 'Delaware',
      'FL': 'Florida',
      'GA': 'Georgia',
      'HI': 'Hawaii',
      'ID': 'Idaho',
      'IL': 'Illinois',
      'IN': 'Indiana',
      'IA': 'Iowa',
      'KS': 'Kansas',
      'KY': 'Kentucky',
      'LA': 'Louisiana',
      'ME': 'Maine',
      'MD': 'Maryland',
      'MA': 'Massachusetts',
      'MI': 'Michigan',
      'MN': 'Minnesota',
      'MS': 'Mississippi',
      'MO': 'Missouri',
      'MT': 'Montana',
      'NE': 'Nebraska',
      'NV': 'Nevada',
      'NH': 'New Hampshire',
      'NJ': 'New Jersey',
      'NM': 'New Mexico',
      'NY': 'New York',
      'NC': 'North Carolina',
      'ND': 'North Dakota',
      'OH': 'Ohio',
      'OK': 'Oklahoma',
      'OR': 'Oregon',
      'PA': 'Pennsylvania',
      'RI': 'Rhode Island',
      'SC': 'South Carolina',
      'SD': 'South Dakota',
      'TN': 'Tennessee',
      'TX': 'Texas',
      'UT': 'Utah',
      'VT': 'Vermont',
      'VA': 'Virginia',
      'WA': 'Washington',
      'WV': 'West Virginia',
      'WI': 'Wisconsin',
      'WY': 'Wyoming',
      'DC': 'District of Columbia',
    };
    
    return stateNames[stateCode] ?? stateCode;
  }
}