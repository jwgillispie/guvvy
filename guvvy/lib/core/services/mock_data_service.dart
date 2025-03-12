// lib/core/services/mock_data_service.dart
import '../../features/representatives/data/models/representative_model.dart';

class MockDataService {
  static List<RepresentativeModel> getMockRepresentatives() {
    return [
      RepresentativeModel(
        id: '1',
        name: 'John Smith',
        party: 'Democratic',
        role: 'Senator',
        level: 'federal',
        district: 'IL-Senate',
        contact: ContactModel(
          office: '123 Senate Building, Washington DC',
          phone: '(202) 555-0123',
          email: 'john.smith@senate.gov',
          website: 'www.smith.senate.gov',
          socialMedia: const SocialMediaModel(
            twitter: '@senatorsmith',
            facebook: 'senatorsmith',
          ),
        ),
        committees: ['Finance', 'Foreign Relations'],
      ),
      RepresentativeModel(
        id: '2',
        name: 'Sarah Johnson',
        party: 'Republican',
        role: 'Representative',
        level: 'federal',
        district: 'IL-1',
        contact: ContactModel(
          office: '456 House Building, Washington DC',
          phone: '(202) 555-0124',
          email: 'sarah.johnson@house.gov',
          website: 'www.johnson.house.gov',
          socialMedia: const SocialMediaModel(
            twitter: '@repjohnson',
            facebook: 'repjohnson',
          ),
        ),
        committees: ['Armed Services', 'Education'],
      ),
      RepresentativeModel(
        id: '3',
        name: 'Michael Chen',
        party: 'Democratic',
        role: 'State Senator',
        level: 'state',
        district: 'IL-State-5',
        contact: ContactModel(
          office: '789 State Capitol, Springfield IL',
          phone: '(217) 555-0125',
          email: 'michael.chen@ilsenate.gov',
          website: 'www.chen.ilsenate.gov',
          socialMedia: const SocialMediaModel(
            twitter: '@senchenmichael',
            facebook: 'senchenmichael',
          ),
        ),
        committees: ['State Budget', 'Transportation'],
      ),
      RepresentativeModel(
        id: '4',
        name: 'Emily Rodriguez',
        party: 'Independent',
        role: 'City Council Member',
        level: 'local',
        district: 'Ward 3',
        contact: ContactModel(
          office: '321 City Hall, Chicago IL',
          phone: '(312) 555-0126',
          email: 'emily.rodriguez@citycouncil.gov',
          website: 'www.rodriguez.council.gov',
          socialMedia: const SocialMediaModel(
            twitter: '@cmrodriguez',
            facebook: 'cmrodriguez',
          ),
        ),
        committees: ['Zoning', 'Public Safety'],
      ),
    ];
  }

  static List<RepresentativeModel> getMockSavedRepresentatives() {
    final allReps = getMockRepresentatives();
    // Return first two as "saved" representatives
    return [allReps[0], allReps[2]];
  }
  // Add to lib/core/services/mock_data_service.dart

// Mock voting history for a representative
  static List<Map<String, dynamic>> getMockVotingHistory(String repId) {
    return [
      {
        'id': 'vote1',
        'billId': 'H.R.1',
        'billTitle': 'For the People Act',
        'date':
            DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'result': repId.contains('1') || repId.contains('3') ? 'Yea' : 'Nay',
        'description': 'Election reform and voting rights bill',
      },
      {
        'id': 'vote2',
        'billId': 'H.R.2',
        'billTitle': 'Infrastructure Investment Act',
        'date':
            DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        'result': repId.contains('2') ? 'Nay' : 'Yea',
        'description': 'Comprehensive infrastructure funding package',
      },
      {
        'id': 'vote3',
        'billId': 'S.1',
        'billTitle': 'Healthcare Reform Act',
        'date':
            DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'result': repId.contains('4') ? 'Present' : 'Yea',
        'description': 'Healthcare system overhaul and funding',
      },
    ];
  }

// Get detailed representative data by ID
  static RepresentativeModel getMockRepresentativeDetails(String id) {
    // Get all reps and find the one with matching ID
    final allReps = getMockRepresentatives();
    try {
      final rep = allReps.firstWhere((rep) => rep.id == id);

      // Return the representative with additional details if needed
      return rep;
    } catch (e) {
      // If not found, create a fallback representative
      return RepresentativeModel(
        id: id,
        name: 'Unknown Representative',
        party: 'Independent',
        role: 'Unknown',
        level: 'federal',
        district: 'Unknown',
        contact: ContactModel(
          office: 'Unknown',
          phone: 'Unknown',
          email: 'unknown@example.com',
          website: 'www.example.com',
          socialMedia: const SocialMediaModel(),
        ),
        committees: ['Unknown Committee'],
      );
    }
  }
}
