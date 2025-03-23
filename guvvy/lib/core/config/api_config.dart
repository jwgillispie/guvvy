// lib/core/config/api_config.dart
class ApiConfig {
  // Base URL for the API - replace with your actual API URL
  // In development, this might be your local server
  // In production, this would be your deployed API
  static const String baseUrl = 'http://localhost:8000';
  
  // Helper method to join URL paths without double slashes
  static String joinUrl(String base, String path) {
    if (base.endsWith('/')) {
      base = base.substring(0, base.length - 1);
    }
    if (path.startsWith('/')) {
      path = path.substring(1);
    }
    return '$base/$path';
  }
  
  // API endpoints
  static String get usersEndpoint => '$baseUrl/api/users/';
  
  static String userEndpoint(String firebaseUid) => 
      joinUrl(usersEndpoint, firebaseUid);
      
  static String userAddressEndpoint(String firebaseUid) => 
      joinUrl(userEndpoint(firebaseUid), 'address');
      
  static String userLoginEndpoint(String firebaseUid) => 
      joinUrl(userEndpoint(firebaseUid), 'login');
  
  // Representatives endpoints
  static String get representativesEndpoint => '$baseUrl/api/representatives';
  
  static String representativeEndpoint(String repId) => 
      joinUrl(representativesEndpoint, repId);
      
  static String representativesByLocationEndpoint(double lat, double lng) => 
      '$representativesEndpoint?latitude=$lat&longitude=$lng';
  
  // Districts endpoints
  static String get districtsEndpoint => '$baseUrl/api/districts';
  
  static String districtEndpoint(String districtId) => 
      joinUrl(districtsEndpoint, districtId);
  
  // Bills endpoints
  static String get billsEndpoint => '$baseUrl/api/bills';
  
  static String billEndpoint(String billId) => 
      joinUrl(billsEndpoint, billId);
  
  // Votes endpoints
  static String get votesEndpoint => '$baseUrl/api/votes';
  
  static String voteEndpoint(String voteId) => 
      joinUrl(votesEndpoint, voteId);
}