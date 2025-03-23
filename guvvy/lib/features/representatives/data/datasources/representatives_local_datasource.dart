// lib/features/representatives/data/datasources/representatives_local_datasource.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/representative.dart';
import '../models/representative_model.dart';

abstract class RepresentativesLocalDataSource {
  /// Gets the cached list of [Representative] which was gotten the last time
  /// the user had an internet connection.
  Future<List<Representative>> getLastRepresentatives();

  /// Gets a specific [Representative] by ID from the local cache
  Future<Representative?> getRepresentativeById(String id);

  /// Caches a list of [Representative] for offline use
  Future<void> cacheRepresentatives(List<Representative> representatives);
  
  /// Caches a single [Representative] for offline use
  Future<void> cacheRepresentative(Representative representative);

  /// Gets the user's saved/favorite representatives
  Future<List<Representative>> getSavedRepresentatives();

  /// Adds a representative to the saved/favorites list
  Future<void> saveRepresentative(String representativeId);

  /// Removes a representative from the saved/favorites list
  Future<void> removeSavedRepresentative(String representativeId);
}

class RepresentativesLocalDataSourceImpl implements RepresentativesLocalDataSource {
  final SharedPreferences sharedPreferences;

  RepresentativesLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<Representative>> getLastRepresentatives() async {
    final jsonString = sharedPreferences.getString('CACHED_REPRESENTATIVES');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((jsonRep) => RepresentativeModel.fromJson(jsonRep))
          .toList();
    }
    return [];
  }

  @override
  Future<Representative?> getRepresentativeById(String id) async {
    final representatives = await getLastRepresentatives();
    try {
      return representatives.firstWhere((rep) => rep.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheRepresentatives(List<Representative> representatives) async {
    final List<Map<String, dynamic>> jsonList = representatives
        .map((rep) {
          if (rep is RepresentativeModel) {
            return rep.toJson();
          } else {
            // If it's not already a model, convert it (though this shouldn't happen)
            // This is a fallback for type safety
            return RepresentativeModel(
              id: rep.id,
              name: rep.name,
              party: rep.party,
              role: rep.role,
              level: rep.level,
              district: rep.district,
              contact: rep.contact is ContactModel
                  ? rep.contact as ContactModel
                  : ContactModel(
                      office: rep.contact.office,
                      phone: rep.contact.phone,
                      email: rep.contact.email,
                      website: rep.contact.website,
                      socialMedia: rep.contact.socialMedia is SocialMediaModel
                          ? rep.contact.socialMedia as SocialMediaModel
                          : SocialMediaModel(
                              twitter: rep.contact.socialMedia.twitter,
                              facebook: rep.contact.socialMedia.facebook,
                            ),
                    ),
              committees: rep.committees,
            ).toJson();
          }
        })
        .toList();

    await sharedPreferences.setString(
      'CACHED_REPRESENTATIVES',
      json.encode(jsonList),
    );
  }
  
  @override
  Future<void> cacheRepresentative(Representative representative) async {
    // Get existing cached representatives
    final representatives = await getLastRepresentatives();
    
    // Check if this representative is already cached
    final existingIndex = representatives.indexWhere((rep) => rep.id == representative.id);
    
    if (existingIndex >= 0) {
      // Update existing representative
      representatives[existingIndex] = representative;
    } else {
      // Add new representative
      representatives.add(representative);
    }
    
    // Cache the updated list
    await cacheRepresentatives(representatives);
  }

  @override
  Future<List<Representative>> getSavedRepresentatives() async {
    final savedIds = _getSavedRepresentativeIds();
    final allRepresentatives = await getLastRepresentatives();
    
    return allRepresentatives
        .where((rep) => savedIds.contains(rep.id))
        .toList();
  }

  @override
  Future<void> saveRepresentative(String representativeId) async {
    final savedIds = _getSavedRepresentativeIds();
    
    if (!savedIds.contains(representativeId)) {
      savedIds.add(representativeId);
      await sharedPreferences.setStringList(
        'SAVED_REPRESENTATIVE_IDS',
        savedIds,
      );
    }
  }

  @override
  Future<void> removeSavedRepresentative(String representativeId) async {
    final savedIds = _getSavedRepresentativeIds();
    
    if (savedIds.contains(representativeId)) {
      savedIds.remove(representativeId);
      await sharedPreferences.setStringList(
        'SAVED_REPRESENTATIVE_IDS',
        savedIds,
      );
    }
  }

  // Helper method to get saved IDs list
  List<String> _getSavedRepresentativeIds() {
    return sharedPreferences.getStringList('SAVED_REPRESENTATIVE_IDS') ?? [];
  }
}