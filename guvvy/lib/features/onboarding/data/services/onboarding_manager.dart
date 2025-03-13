// lib/features/onboarding/data/services/onboarding_manager.dart
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingManager {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _addressSavedKey = 'address_saved';

  /// Checks if the user has completed the onboarding process
  static Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Marks onboarding as complete
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Reset onboarding status (for testing or user preference reset)
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, false);
  }

  /// Checks if the user has saved an address
  static Future<bool> hasAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_addressSavedKey) ?? false;
  }

  /// Marks address as saved
  static Future<void> setAddressSaved() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_addressSavedKey, true);
  }
  
  /// Get the user's complete onboarding status
  static Future<OnboardingStatus> getStatus() async {
    final onboardingComplete = await isOnboardingComplete();
    final addressSaved = await hasAddress();
    
    if (!onboardingComplete) {
      return OnboardingStatus.needsOnboarding;
    } else if (!addressSaved) {
      return OnboardingStatus.needsAddress;
    } else {
      return OnboardingStatus.complete;
    }
  }
}

enum OnboardingStatus {
  needsOnboarding,
  needsAddress,
  complete
}