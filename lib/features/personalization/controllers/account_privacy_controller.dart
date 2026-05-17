import 'package:get/get.dart';

class AccountPrivacyController extends GetxController {
  static AccountPrivacyController get instance => Get.find();

  // Privacy Settings
  final profileVisibility = true.obs;
  final shareActivityStatus = false.obs;

  // Data Usage
  final dataCollection = true.obs;
  final marketingCommunications = false.obs;

  // Connected Accounts
  final thirdPartySharing = false.obs;

  // Loading state
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadPrivacyPreferences();
  }

  /// Load privacy preferences from storage/database
  void loadPrivacyPreferences() {
    // TODO: Fetch from shared preferences or Firebase
    // For now, defaults are set in initState
  }

  /// Toggle profile visibility
  void toggleProfileVisibility(bool value) {
    profileVisibility.value = value;
    savePrivacyPreferences();
  }

  /// Toggle activity status sharing
  void toggleActivityStatus(bool value) {
    shareActivityStatus.value = value;
    savePrivacyPreferences();
  }

  /// Toggle data collection
  void toggleDataCollection(bool value) {
    dataCollection.value = value;
    savePrivacyPreferences();
  }

  /// Toggle marketing communications
  void toggleMarketingCommunications(bool value) {
    marketingCommunications.value = value;
    savePrivacyPreferences();
  }

  /// Toggle third party sharing
  void toggleThirdPartySaring(bool value) {
    thirdPartySharing.value = value;
    savePrivacyPreferences();
  }

  /// Save all privacy preferences
  void savePrivacyPreferences() {
    try {
      // TODO: Save to shared preferences or Firebase
      // YLoaders.successSnackBar(title: 'Success', message: 'Preferences updated');
    } catch (e) {
      // YLoaders.errorSnackBar(title: 'Error', message: 'Failed to save preferences: $e');
    }
  }

  /// Reset to default privacy preferences
  void resetToDefaults() {
    profileVisibility.value = true;
    shareActivityStatus.value = false;
    dataCollection.value = true;
    marketingCommunications.value = false;
    thirdPartySharing.value = false;
    savePrivacyPreferences();
  }

  /// Delete account - navigate to confirmation dialog
  void deleteAccount() {
    // TODO: Implement account deletion logic
    // This should show a confirmation dialog first
  }
}

