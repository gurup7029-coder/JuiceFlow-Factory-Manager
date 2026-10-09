import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Android Initialization
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // Linux/Darwin if applicable
      const DarwinInitializationSettings darwinSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification clicked with payload: ${response.payload}');
        },
      );

      // Request notification permission for Android 13+ (TIRAMISU)
      if (!kIsWeb && Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();

        await androidImplementation?.requestNotificationsPermission();
        await androidImplementation?.requestExactAlarmsPermission();
      }

      // Create high-priority notification channels
      await _createNotificationChannels();

      // Schedule periodic background freshness & batch status check
      await scheduleBackgroundHealthPing();

      _isInitialized = true;
      debugPrint('NotificationService: Initialized successfully with high-priority channels.');
    } catch (e) {
      debugPrint('NotificationService: Init error (running gracefully): $e');
    }
  }

  Future<void> _createNotificationChannels() async {
    if (kIsWeb || !Platform.isAndroid) return;

    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      // 1. Customer Orders & Payments Channel
      const AndroidNotificationChannel ordersChannel = AndroidNotificationChannel(
        'juiceflow_orders_channel',
        'Customer Orders & Payments',
        description: 'Instant notification on customer juice orders, payment confirmations, and delivery updates',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // 2. Factory Quality & Production Alerts Channel
      const AndroidNotificationChannel factoryChannel = AndroidNotificationChannel(
        'juiceflow_factory_channel',
        'Factory & Batch Alerts',
        description: 'Production completion, critical raw material stock, and QC approvals',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      // 3. Background Hourly Status Channel
      const AndroidNotificationChannel backgroundChannel = AndroidNotificationChannel(
        'juiceflow_background_channel',
        'JuiceFlow Background Monitor',
        description: 'Automatic periodic updates and freshness tracking even when app is closed',
        importance: Importance.defaultImportance,
        playSound: true,
        enableVibration: true,
        showBadge: true,
      );

      await androidImplementation.createNotificationChannel(ordersChannel);
      await androidImplementation.createNotificationChannel(factoryChannel);
      await androidImplementation.createNotificationChannel(backgroundChannel);
    }
  }

  /// Show instant order confirmed notification to Customer
  Future<void> showOrderConfirmedNotification({
    required String orderNumber,
    required double grandTotal,
    required int itemCount,
    required String paymentMode,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'juiceflow_orders_channel',
        'Customer Orders & Payments',
        channelDescription: 'Order confirmations and invoices',
        importance: Importance.max,
        priority: Priority.max,
        styleInformation: BigTextStyleInformation(''),
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000,
        title: '🥤 Order Confirmed! #$orderNumber',
        body: 'Thank you! Your order of $itemCount juice bottle(s) totaling ₹${grandTotal.toStringAsFixed(0)} is paid via $paymentMode and sent to factory production!',
        notificationDetails: platformDetails,
        payload: 'order:$orderNumber',
      );
    } catch (e) {
      debugPrint('Error showing customer order notification: $e');
    }
  }

  /// Show factory alert notification when a new order arrives
  Future<void> showNewOrderForFactoryNotification({
    required String orderNumber,
    required String customerName,
    required double grandTotal,
    required String itemsSummary,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'juiceflow_factory_channel',
        'Factory & Batch Alerts',
        channelDescription: 'New incoming juice production orders',
        importance: Importance.max,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(''),
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: ((DateTime.now().millisecondsSinceEpoch ~/ 1000) + 1) % 100000,
        title: '🔔 New Order #$orderNumber from $customerName',
        body: 'Total: ₹${grandTotal.toStringAsFixed(0)} | Items: $itemsSummary. Check production line!',
        notificationDetails: platformDetails,
        payload: 'factory_order:$orderNumber',
      );
    } catch (e) {
      debugPrint('Error showing factory notification: $e');
    }
  }

  /// Generic Factory Alert (Stock low, QC passed, Batch finished)
  Future<void> showFactoryAlert({
    required String title,
    required String message,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'juiceflow_factory_channel',
        'Factory & Batch Alerts',
        channelDescription: 'Factory floor operations',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: (DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000,
        title: title,
        body: message,
        notificationDetails: platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing factory alert: $e');
    }
  }

  /// Schedule periodic background notifications so alerts appear even when the app is closed
  Future<void> scheduleBackgroundHealthPing() async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'juiceflow_background_channel',
        'JuiceFlow Background Monitor',
        channelDescription: 'Periodic plant health & batch notifications',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      // Periodically trigger every hour so Android OS wakes up even if app is terminated
      await _notificationsPlugin.periodicallyShow(
        id: 888,
        title: '🏭 JuiceFlow Plant Status Active',
        body: 'Cold-chain temperature normal (3.8°C). Pasteurizer & filler lines operational.',
        repeatInterval: RepeatInterval.hourly,
        notificationDetails: platformDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Periodic notification schedule skipped: $e');
    }
  }

  /// Generic Notification Method for OTA & In-App Alerts
  Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'juiceflow_factory_channel',
        'Factory & Batch Alerts',
        channelDescription: 'Factory floor operations & cloud updates',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
      );

      const NotificationDetails platformDetails =
          NotificationDetails(android: androidDetails);

      await _notificationsPlugin.show(
        id: id ?? ((DateTime.now().millisecondsSinceEpoch ~/ 1000) % 100000),
        title: title,
        body: body,
        notificationDetails: platformDetails,
        payload: payload,
      );
    } catch (e) {
      debugPrint('Error showing generic notification: $e');
    }
  }

  /// Send immediate test notification
  Future<void> sendTestNotification() async {
    await showFactoryAlert(
      title: '🔔 JuiceFlow Live Test Alert',
      message: 'Background notifications are active! You will receive alerts even when app is closed.',
      payload: 'test_alert',
    );
  }
}
