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

  // Original voting history method (kept for backwards compatibility)
  static List<Map<String, dynamic>> getMockVotingHistory(String repId) {
    return [
      {
        'id': 'vote1',
        'billId': 'H.R. 1234',
        'billTitle': 'Infrastructure Investment and Jobs Act',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'result': repId.contains('1') || repId.contains('3') ? 'Yea' : 'Nay',
        'description': 'Comprehensive legislation to rebuild roads, bridges, and other infrastructure.',
      },
      {
        'id': 'vote2',
        'billId': 'S. 935',
        'billTitle': 'Clean Energy Innovation Act',
        'date': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        'result': repId.contains('2') ? 'Nay' : 'Yea',
        'description': 'Bill to fund research and development of clean energy technologies.',
      },
      {
        'id': 'vote3',
        'billId': 'H.R. 3076',
        'billTitle': 'Postal Service Reform Act',
        'date': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'result': repId.contains('4') ? 'Present' : 'Yea',
        'description': 'Legislation to improve the financial condition of the USPS.',
      },
      {
        'id': 'vote4',
        'billId': 'S. 2938',
        'billTitle': 'Bipartisan Safer Communities Act',
        'date': DateTime.now().subtract(const Duration(days: 42)).toIso8601String(),
        'result': repId == '1' ? 'Yea' : repId == '2' ? 'Nay' : 'Present',
        'description': 'Gun violence prevention and mental health funding legislation.',
      },
      {
        'id': 'vote5',
        'billId': 'H.R. 7900',
        'billTitle': 'National Defense Authorization Act',
        'date': DateTime.now().subtract(const Duration(days: 65)).toIso8601String(),
        'result': repId.contains('2') || repId.contains('4') ? 'Yea' : 'Nay',
        'description': 'Annual defense policy bill that authorizes defense spending.',
      },
      {
        'id': 'vote6',
        'billId': 'S. 4357',
        'billTitle': 'Veterans Health Care Act',
        'date': DateTime.now().subtract(const Duration(days: 78)).toIso8601String(),
        'result': 'Yea', // Unanimous
        'description': 'Expands healthcare benefits for veterans exposed to toxic substances.',
      },
      {
        'id': 'vote7',
        'billId': 'H.R. 5376',
        'billTitle': 'Inflation Reduction Act',
        'date': DateTime.now().subtract(const Duration(days: 93)).toIso8601String(),
        'result': repId.contains('1') || repId.contains('3') ? 'Yea' : 'Nay',
        'description': 'Climate change, tax reform, and healthcare legislation.',
      },
    ];
  }

  // Enhanced voting history with categories
  static List<Map<String, dynamic>> getMockVotingHistoryWithCategories(String repId) {
    // Base voting data
    final baseVotingData = [
      {
        'id': 'vote1',
        'billId': 'H.R. 1234',
        'billTitle': 'Infrastructure Investment and Jobs Act',
        'date': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
        'result': repId.contains('1') || repId.contains('3') ? 'Yea' : 'Nay',
        'description': 'Comprehensive legislation to rebuild roads, bridges, and other infrastructure.',
        'categories': ['Infrastructure', 'Economy'],
        'withParty': true,
      },
      {
        'id': 'vote2',
        'billId': 'S. 935',
        'billTitle': 'Clean Energy Innovation Act',
        'date': DateTime.now().subtract(const Duration(days: 12)).toIso8601String(),
        'result': repId.contains('2') ? 'Nay' : 'Yea',
        'description': 'Bill to fund research and development of clean energy technologies.',
        'categories': ['Environment', 'Economy'],
        'withParty': repId.contains('2'),
      },
      {
        'id': 'vote3',
        'billId': 'H.R. 3076',
        'billTitle': 'Postal Service Reform Act',
        'date': DateTime.now().subtract(const Duration(days: 25)).toIso8601String(),
        'result': repId.contains('4') ? 'Present' : 'Yea',
        'description': 'Legislation to improve the financial condition of the USPS.',
        'categories': ['Infrastructure', 'Economy'],
        'withParty': true,
      },
      {
        'id': 'vote4',
        'billId': 'S. 2938',
        'billTitle': 'Bipartisan Safer Communities Act',
        'date': DateTime.now().subtract(const Duration(days: 42)).toIso8601String(),
        'result': repId == '1' ? 'Yea' : repId == '2' ? 'Nay' : 'Present',
        'description': 'Gun violence prevention and mental health funding legislation.',
        'categories': ['Social Issues', 'Healthcare'],
        'withParty': repId != '3',
      },
      {
        'id': 'vote5',
        'billId': 'H.R. 7900',
        'billTitle': 'National Defense Authorization Act',
        'date': DateTime.now().subtract(const Duration(days: 65)).toIso8601String(),
        'result': repId.contains('2') || repId.contains('4') ? 'Yea' : 'Nay',
        'description': 'Annual defense policy bill that authorizes defense spending.',
        'categories': ['Defense', 'Foreign Policy'],
        'withParty': repId.contains('2') || repId.contains('4'),
      },
      {
        'id': 'vote6',
        'billId': 'S. 4357',
        'billTitle': 'Veterans Health Care Act',
        'date': DateTime.now().subtract(const Duration(days: 78)).toIso8601String(),
        'result': 'Yea', // Unanimous
        'description': 'Expands healthcare benefits for veterans exposed to toxic substances.',
        'categories': ['Healthcare', 'Defense'],
        'withParty': true,
      },
      {
        'id': 'vote7',
        'billId': 'H.R. 5376',
        'billTitle': 'Inflation Reduction Act',
        'date': DateTime.now().subtract(const Duration(days: 93)).toIso8601String(),
        'result': repId.contains('1') || repId.contains('3') ? 'Yea' : 'Nay',
        'description': 'Climate change, tax reform, and healthcare legislation.',
        'categories': ['Environment', 'Economy', 'Healthcare'],
        'withParty': repId.contains('1') || repId.contains('3'),
      },
      {
        'id': 'vote8',
        'billId': 'H.R. 4521',
        'billTitle': 'America COMPETES Act',
        'date': DateTime.now().subtract(const Duration(days: 110)).toIso8601String(),
        'result': repId == '2' ? 'Nay' : 'Yea',
        'description': 'Legislation to strengthen U.S. economic competitiveness and supply chains.',
        'categories': ['Economy', 'Foreign Policy'],
        'withParty': repId != '2',
      },
      {
        'id': 'vote9',
        'billId': 'S. 1260',
        'billTitle': 'U.S. Innovation and Competition Act',
        'date': DateTime.now().subtract(const Duration(days: 125)).toIso8601String(),
        'result': 'Yea',
        'description': 'Bill to invest in research, innovation, and American manufacturing.',
        'categories': ['Economy', 'Education'],
        'withParty': true,
      },
      {
        'id': 'vote10',
        'billId': 'H.R. 8373',
        'billTitle': 'Right to Contraception Act',
        'date': DateTime.now().subtract(const Duration(days: 140)).toIso8601String(),
        'result': repId.contains('2') ? 'Nay' : 'Yea',
        'description': 'Legislation to protect access to contraception.',
        'categories': ['Healthcare', 'Social Issues'],
        'withParty': repId != '4', // Independent voted with Democrats
      },
      {
        'id': 'vote11',
        'billId': 'S. 2089',
        'billTitle': 'Student Loan Forgiveness Act',
        'date': DateTime.now().subtract(const Duration(days: 155)).toIso8601String(),
        'result': repId.contains('1') || repId.contains('3') ? 'Yea' : 'Nay',
        'description': 'Bill to provide relief for student loan borrowers.',
        'categories': ['Education', 'Economy'],
        'withParty': repId != '4', // Independent voted against
      },
      {
        'id': 'vote12',
        'billId': 'H.R. 5949',
        'billTitle': 'Public School Infrastructure Act',
        'date': DateTime.now().subtract(const Duration(days: 170)).toIso8601String(),
        'result': 'Yea',
        'description': 'Legislation to fund improvements to public school buildings.',
        'categories': ['Education', 'Infrastructure'],
        'withParty': true,
      },
      {
        'id': 'vote13',
        'billId': 'S. 3257',
        'billTitle': 'Military Family Housing Act',
        'date': DateTime.now().subtract(const Duration(days: 185)).toIso8601String(),
        'result': 'Yea',
        'description': 'Bill to improve housing for military families on bases.',
        'categories': ['Defense', 'Infrastructure'],
        'withParty': true,
      },
      {
        'id': 'vote14',
        'billId': 'H.R. 2617',
        'billTitle': 'Consolidated Appropriations Act',
        'date': DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
        'result': repId == '4' ? 'Present' : (repId.contains('1') || repId.contains('3') ? 'Yea' : 'Nay'),
        'description': 'Government funding bill for fiscal year 2023.',
        'categories': ['Economy'],
        'withParty': repId != '4',
      },
      {
        'id': 'vote15',
        'billId': 'S. 4205',
        'billTitle': 'Wildfire Response and Drought Resiliency Act',
        'date': DateTime.now().subtract(const Duration(days: 215)).toIso8601String(),
        'result': repId.contains('2') ? 'Nay' : 'Yea',
        'description': 'Legislation to address wildfires and drought conditions.',
        'categories': ['Environment', 'Infrastructure'],
        'withParty': repId != '2',
      },
    ];

    // Add monthly activity distribution
    final months = 8;
    for (int i = 0; i < months; i++) {
      final bool isDemocrat = repId == '1' || repId == '3';
      final monthOffset = i * 30;
      
      baseVotingData.add({
        'id': 'vote_monthly_${i}_1',
        'billId': 'H.R. ${4000 + i}',
        'billTitle': 'Monthly Omnibus Bill ${i + 1}',
        'date': DateTime.now().subtract(Duration(days: monthOffset + 3 + (i * 3))).toIso8601String(),
        'result': isDemocrat ? 'Yea' : 'Nay',
        'description': 'Regular monthly legislative package.',
        'categories': ['Economy', 'Infrastructure'],
        'withParty': true,
      });
      
      if (i % 2 == 0) {
        baseVotingData.add({
          'id': 'vote_monthly_${i}_2',
          'billId': 'S. ${3000 + i}',
          'billTitle': 'Supplemental Funding Act ${i + 1}',
          'date': DateTime.now().subtract(Duration(days: monthOffset + 15 + (i * 2))).toIso8601String(),
          'result': isDemocrat ? 'Yea' : 'Nay',
          'description': 'Additional funding for government programs.',
          'categories': ['Economy'],
          'withParty': true,
        });
      }
    }

    return baseVotingData;
  }
}