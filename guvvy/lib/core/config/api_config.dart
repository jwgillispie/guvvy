// lib/core/config/api_config.dart
class ApiConfig {
  // Base URL for the API - replace with your actual API URL
  // In development, this might be your local server
  // In production, this would be your deployed API
  static const String baseUrl = 'http://localhost:8000';
  
  // API endpoints
  static String get usersEndpoint => '$baseUrl/api/users';
  static String userEndpoint(String firebaseUid) => '$usersEndpoint/$firebaseUid';
  static String userAddressEndpoint(String firebaseUid) => '${userEndpoint(firebaseUid)}/address';
  static String userLoginEndpoint(String firebaseUid) => '${userEndpoint(firebaseUid)}/login';
  
  // Representatives endpoints
  static String get representativesEndpoint => '$baseUrl/api/representatives';
  static String representativeEndpoint(String repId) => '$representativesEndpoint/$repId';
  static String representativesByLocationEndpoint(double lat, double lng) => 
      '$representativesEndpoint?latitude=$lat&longitude=$lng';
  
  // Districts endpoints
  static String get districtsEndpoint => '$baseUrl/api/districts';
  static String districtEndpoint(String districtId) => '$districtsEndpoint/$districtId';
  
  // Bills endpoints
  static String get billsEndpoint => '$baseUrl/api/bills';
  static String billEndpoint(String billId) => '$billsEndpoint/$billId';
  
  // Votes endpoints
  static String get votesEndpoint => '$baseUrl/api/votes';
  static String voteEndpoint(String voteId) => '$votesEndpoint/$voteId';
}