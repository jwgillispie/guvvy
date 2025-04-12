// lib/core/services/govtrack_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class GovTrackService {
  static const String baseUrl = 'https://www.govtrack.us/api/v2';
  final http.Client _client = http.Client();

  // Fetch voting history for a specific representative
  Future<List<Map<String, dynamic>>> getVotingHistory(
      String representativeId) async {
    try {
      // For congressional representatives, we use their Bioguide ID
      // which is a standard identifier across government databases
      final response = await _client.get(
        Uri.parse(
            '$baseUrl/vote_voter?person=$representativeId&limit=100&sort=-created'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseVotingHistory(data);
      } else {
        throw Exception(
            'Failed to load voting history: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to mock data for testing or when API is unavailable
      return getMockVotingData();
    }
  }

  // Parse voting history data from GovTrack API response
  List<Map<String, dynamic>> _parseVotingHistory(Map<String, dynamic> data) {
    final List<dynamic> voteObjects = data['objects'] ?? [];

    return voteObjects.map<Map<String, dynamic>>((vote) {
      final voteData = vote['vote'] ?? {};

      return {
        'rollnumber': voteData['number'] ?? '',
        'vote_question': voteData['question'] ?? '',
        'date': voteData['created'] ?? DateTime.now().toIso8601String(),
        'vote_result': vote['option'] ?? '',
        'yea_count': voteData['total_plus'] ?? 0,
        'nay_count': voteData['total_minus'] ?? 0,
        'nominate_mid_1': 0.0, // Not available in GovTrack API
        'bill_id': voteData['related_bill']?['id'],
        'bill_title': voteData['related_bill']?['title'],
      };
    }).toList();
  }

  // Get details about a specific vote
  Future<Map<String, dynamic>> getVoteDetails(String voteId) async {
    try {
      final response = await _client.get(
        Uri.parse('$baseUrl/vote/$voteId'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load vote details: ${response.statusCode}');
      }
    } catch (e) {
      // Return placeholder data
      return {
        'id': voteId,
        'question': 'Vote details unavailable',
        'result': 'Unknown',
      };
    }
  }

  // Mock data for testing or when API is unavailable
  Future<List<Map<String, dynamic>>> getMockVotingData() async {
    return [
      {
        "rollnumber": "1234",
        "vote_question": "Infrastructure Investment and Jobs Act",
        "date": "2024-04-05T14:30:00Z",
        "vote_result": "Passed",
        "yea_count": 220,
        "nay_count": 211,
        "nominate_mid_1": 0.2
      },
      {
        "rollnumber": "1235",
        "vote_question": "Clean Energy Innovation Act",
        "date": "2024-03-28T10:15:00Z",
        "vote_result": "Failed",
        "yea_count": 198,
        "nay_count": 232,
        "nominate_mid_1": -0.3
      },
      {
        "rollnumber": "1236",
        "vote_question": "Postal Service Reform Act",
        "date": "2024-03-15T16:45:00Z",
        "vote_result": "Passed",
        "yea_count": 342,
        "nay_count": 92,
        "nominate_mid_1": 0.8
      },
      {
        "rollnumber": "1237",
        "vote_question": "Bipartisan Safer Communities Act",
        "date": "2024-02-28T11:20:00Z",
        "vote_result": "Passed",
        "yea_count": 234,
        "nay_count": 193,
        "nominate_mid_1": 0.4
      },
      {
        "rollnumber": "1238",
        "vote_question": "National Defense Authorization Act",
        "date": "2024-02-15T09:30:00Z",
        "vote_result": "Passed",
        "yea_count": 310,
        "nay_count": 118,
        "nominate_mid_1": 0.6
      },
      {
        "rollnumber": "1239",
        "vote_question": "Veterans Health Care Act",
        "date": "2024-02-02T14:00:00Z",
        "vote_result": "Passed",
        "yea_count": 401,
        "nay_count": 20,
        "nominate_mid_1": 0.9
      },
      {
        "rollnumber": "1240",
        "vote_question": "Inflation Reduction Act",
        "date": "2024-01-20T15:15:00Z",
        "vote_result": "Passed",
        "yea_count": 219,
        "nay_count": 212,
        "nominate_mid_1": -0.1
      }
    ];
  }
}
