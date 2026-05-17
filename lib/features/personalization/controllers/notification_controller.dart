import 'package:get/get.dart';

import '../../../utils/local_storage/storage_utility.dart';
import '../../../utils/services/notification_service.dart';

class NotificationController extends GetxController {
  static NotificationController get instance => Get.find();

  final orderNotifications = true.obs;
  final promotionalNotifications = true.obs;
  final emailNotifications = true.obs;
  final smsNotifications = false.obs;
  final pushNotifications = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotificationPreferences();
  }

  /// Load notification preferences from storage/database
  void loadNotificationPreferences() {
    final storage = YLocalStorage.instance();

    orderNotifications.value =
        storage.readData<bool>(YNotificationService.orderNotificationsKey) ?? true;
    promotionalNotifications.value =
        storage.readData<bool>(YNotificationService.promotionalNotificationsKey) ?? true;
    emailNotifications.value =
        storage.readData<bool>(YNotificationService.emailNotificationsKey) ?? true;
    smsNotifications.value =
        storage.readData<bool>(YNotificationService.smsNotificationsKey) ?? false;
    pushNotifications.value =
        storage.readData<bool>(YNotificationService.pushNotificationsKey) ?? true;

    saveNotificationPreferences();
  }

  /// Toggle order notifications
  void toggleOrderNotifications(bool value) {
    orderNotifications.value = value;
    saveNotificationPreferences();
  }

  /// Toggle promotional notifications
  void togglePromotionalNotifications(bool value) {
    promotionalNotifications.value = value;
    saveNotificationPreferences();
  }

  /// Toggle email notifications
  void toggleEmailNotifications(bool value) {
    emailNotifications.value = value;
    saveNotificationPreferences();
  }

  /// Toggle SMS notifications
  void toggleSMSNotifications(bool value) {
    smsNotifications.value = value;
    saveNotificationPreferences();
  }

  /// Toggle push notifications
  void togglePushNotifications(bool value) {
    pushNotifications.value = value;
    saveNotificationPreferences();
  }

  /// Save all notification preferences
  void saveNotificationPreferences() {
    try {
      final storage = YLocalStorage.instance();
      storage.saveData<bool>(YNotificationService.orderNotificationsKey, orderNotifications.value);
      storage.saveData<bool>(YNotificationService.promotionalNotificationsKey, promotionalNotifications.value);
      storage.saveData<bool>(YNotificationService.emailNotificationsKey, emailNotifications.value);
      storage.saveData<bool>(YNotificationService.smsNotificationsKey, smsNotifications.value);
      storage.saveData<bool>(YNotificationService.pushNotificationsKey, pushNotifications.value);
    } catch (e) {
      // Ignore storage failures for now.
    }
  }

  /// Reset to default preferences
  void resetToDefaults() {
    orderNotifications.value = true;
    promotionalNotifications.value = true;
    emailNotifications.value = true;
    smsNotifications.value = false;
    pushNotifications.value = true;
    saveNotificationPreferences();
  }

  /// Show a real device notification for testing.
  Future<void> showTestNotification() async {
    await YNotificationService.instance.showTestNotification();
  }
}

