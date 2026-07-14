import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../utils/app_logger.dart';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    // Initialize Local Notifications
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        AppLogger.info('Notification clicked: ${details.payload}');
      },
    );

    // Request permissions for iOS
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Setup foreground message handling
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.info('Foreground push received: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle background notification click
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.info('Push notification clicked in background: ${message.data}');
    });

    // Retrieve and upload FCM token
    try {
      final token = await _fcm.getToken();
      if (token != null) {
        AppLogger.info('FCM Token: $token');
        await uploadFcmToken(token);
      }
      _fcm.onTokenRefresh.listen((newToken) async {
        await uploadFcmToken(newToken);
      });
    } catch (e, stack) {
      AppLogger.error('Failed to register FCM token', e, stack);
    }
  }

  Future<void> uploadFcmToken(String token) async {
    try {
      await ApiClient().post(ApiEndpoints.deviceToken, data: {'token': token});
    } catch (_) {
      // Don't throw errors in initialization flows if user is offline or not logged in yet
    }
  }

  Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);
    if (tzDate.isBefore(DateTime.now())) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expiry_alerts',
      'Expiry Alerts',
      channelDescription: 'Alerts before groceries expire',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  Future<void> scheduleExpiryAlertsForItems(List<dynamic> items) async {
    await cancelAllNotifications();
    int id = 1;
    for (var item in items) {
      if (item.expiryDate == null) continue;

      final expiry = item.expiryDate!;
      
      // 1. One day prior alert (at 9:00 AM)
      final oneDayBefore = expiry.subtract(const Duration(days: 1));
      final scheduledOneDay = DateTime(oneDayBefore.year, oneDayBefore.month, oneDayBefore.day, 9, 0);
      await scheduleLocalNotification(
        id: id++,
        title: 'Expiry Tomorrow: ${item.name}',
        body: '${item.name} will expire tomorrow. Use it soon to prevent waste!',
        scheduledDate: scheduledOneDay,
      );

      // 2. Expiry day alert (at 9:00 AM)
      final scheduledExpiry = DateTime(expiry.year, expiry.month, expiry.day, 9, 0);
      await scheduleLocalNotification(
        id: id++,
        title: 'Expired Today: ${item.name}',
        body: '${item.name} is expiring today. Mark as consumed or wasted.',
        scheduledDate: scheduledExpiry,
      );
    }
  }

  void _showLocalNotification(RemoteMessage message) {
    final title = message.notification?.title ?? '';
    final body = message.notification?.body ?? '';
    
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'fcm_foreground',
      'Foreground Alerts',
      channelDescription: 'Foreground push alerts',
      importance: Importance.max,
      priority: Priority.high,
    );

    _localNotifications.show(
      message.hashCode,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
