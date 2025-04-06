import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:work/models/job.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Callback for handling new job notifications
  Function(Job)? onNewJobReceived;

  Future<void> initialize() async {
    // Request permission for notifications
    await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await _localNotifications.initialize(initializationSettings);

    // Handle FCM messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle FCM messages when app is in background
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    if (message.data['type'] == 'new_job') {
      // Show local notification
      await _showJobNotification(message.data);

      // Notify listeners about new job
      if (onNewJobReceived != null) {
        final job = Job.fromMap(message.data['job']);
        onNewJobReceived!(job);
      }
    }
  }

  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background messages
    print('Handling background message: ${message.messageId}');
  }

  Future<void> _showJobNotification(Map<String, dynamic> data) async {
    const androidDetails = AndroidNotificationDetails(
      'new_jobs',
      'New Job Notifications',
      channelDescription: 'Notifications for new job opportunities',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      data['jobId'].hashCode,
      'New Job Available!',
      data['jobTitle'],
      details,
      payload: data['jobId'],
    );
  }

  Future<String?> getFCMToken() async {
    return await _fcm.getToken();
  }
}
