import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pibro/utils/pibro_logger.dart';

/// Background message handler - must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  PibroLogger.logger.d('Handling a background message: ${message.messageId}');
  PibroLogger.logger.d('Message data: ${message.data}');
  if (message.notification != null) {
    PibroLogger.logger
        .d('Message notification: ${message.notification?.title}');
  }
}

/// Service class to handle Firebase Cloud Messaging
class FirebaseMessagingService {
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();

  factory FirebaseMessagingService() => _instance;

  FirebaseMessagingService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Cloud Messaging
  Future<void> initialize() async {
    try {
      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request permission for notifications (mainly for iOS)
      final NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      PibroLogger.logger
          .d('User granted permission: ${settings.authorizationStatus}');

      // Get device token (useful for sending targeted messages)
      _fcmToken = await _firebaseMessaging.getToken();
      PibroLogger.logger.d("FCM Token: $_fcmToken");

      // Listen to token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _fcmToken = newToken;
        PibroLogger.logger.d("FCM Token refreshed: $newToken");
        // TODO: Send token to your server if needed
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from a terminated state via notification
      final RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      PibroLogger.logger.e('Error initializing Firebase Messaging: $e');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    PibroLogger.logger.d('Notification tapped: ${response.payload}');
    // TODO: Navigate to specific screen based on payload
    // Example: Get.toNamed(AppRoutes.someRoute, arguments: response.payload);
  }

  /// Handle messages when app is in foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    PibroLogger.logger
        .d('Message received in foreground: ${message.messageId}');
    PibroLogger.logger.d('Message data: ${message.data}');

    if (message.notification != null) {
      PibroLogger.logger.d(
          'Message notification: ${message.notification?.title} - ${message.notification?.body}');

      // Show local notification when app is in foreground
      await _showNotification(message);
    }
  }

  /// Show local notification
  Future<void> _showNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      details,
      payload: message.data.toString(),
    );
  }

  /// Handle notification tap when app is opened from background
  void _handleMessageOpenedApp(RemoteMessage message) {
    PibroLogger.logger.d('Message opened app: ${message.messageId}');
    PibroLogger.logger.d('Message data: ${message.data}');

    // TODO: Navigate to specific screen based on message data
    // Example: Get.toNamed(AppRoutes.someRoute, arguments: message.data);
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      PibroLogger.logger.d('Subscribed to topic: $topic');
    } catch (e) {
      PibroLogger.logger.e('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      PibroLogger.logger.d('Unsubscribed from topic: $topic');
    } catch (e) {
      PibroLogger.logger.e('Error unsubscribing from topic: $e');
    }
  }
}
