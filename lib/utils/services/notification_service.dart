import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../local_storage/storage_utility.dart';

class YNotificationService {
  YNotificationService._();

  static final YNotificationService instance = YNotificationService._();

  static const String orderNotificationsKey = 'notification_order_updates';
  static const String promotionalNotificationsKey = 'notification_promotions';
  static const String emailNotificationsKey = 'notification_email';
  static const String smsNotificationsKey = 'notification_sms';
  static const String pushNotificationsKey = 'notification_push';

  static const String channelId = 'fast_food_orders';
  static const String channelName = 'Order Notifications';
  static const String channelDescription = 'Notifications for order updates and confirmations';

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.high,
      ),
    );

    final iosPlugin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  bool get notificationsEnabled {
    final storage = YLocalStorage.instance();
    final pushEnabled = storage.readData<bool>(pushNotificationsKey) ?? true;
    return pushEnabled;
  }

  Future<void> showOrderSuccessNotification({
    required String orderId,
    required double totalAmount,
    required int itemCount,
  }) async {
    final storage = YLocalStorage.instance();
    final orderEnabled = storage.readData<bool>(orderNotificationsKey) ?? true;
    final pushEnabled = storage.readData<bool>(pushNotificationsKey) ?? true;

    if (!orderEnabled || !pushEnabled) return;

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(2147483647);
    final title = 'Order placed successfully';
    final body = 'Order #${_shortId(orderId)} • $itemCount item${itemCount == 1 ? '' : 's'} • \$${totalAmount.toStringAsFixed(2)}';

    await _plugin.show(
      notificationId,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: orderId,
    );
  }

  Future<void> showTestNotification() async {
    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(2147483647),
      'Fast Food',
      'This is a test notification from your app.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  String _shortId(String orderId) {
    if (orderId.length <= 6) return orderId;
    return orderId.substring(0, 6);
  }
}

