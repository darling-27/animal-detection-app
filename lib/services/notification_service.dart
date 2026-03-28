// lib/services/notification_service.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  // ── Singleton ──
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // ── Channel IDs — MUST match server-side channel_id ──
  static const String wildChannelId = 'wild_animal_alarm';
  static const String wildChannelName = 'Wild Animal Alarm';
  static const String wildChannelDesc =
      'Critical alerts when a wild/dangerous animal is detected';

  static const String generalChannelId = 'general_detection';
  static const String generalChannelName = 'General Detection';
  static const String generalChannelDesc =
      'Notifications for domestic or general animal detections';

  // ─────────────────────────────────────────────────────────
  // INITIALIZE — call once from main()
  // ─────────────────────────────────────────────────────────
  Future<void> initialize() async {
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      // ✅ FIX: Method name was mismatched (_onNotificationTapped vs onNotificationTapped)
      onDidReceiveNotificationResponse: _onNotificationTapped,
      onDidReceiveBackgroundNotificationResponse:
      _onBackgroundNotificationTapped,
    );

    await _createNotificationChannels();
    await _requestPermissions();

    debugPrint('✅ NotificationService initialized');
  }

  // ─────────────────────────────────────────────────────────
  // CREATE CHANNELS
  // ─────────────────────────────────────────────────────────
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;

    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        wildChannelId,
        wildChannelName,
        description: wildChannelDesc,
        importance: Importance.max,
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
        playSound: true,
        enableVibration: true,
      ),
    );

    // ✅ ADD THIS: List all active channels to verify
    final channels = await androidPlugin.getNotificationChannels();
    for (var ch in channels ?? []) {
      debugPrint('CHANNEL: ${ch?.id} | sound: ${ch?.sound}');
    }
  }

  // ─────────────────────────────────────────────────────────
  // REQUEST PERMISSIONS
  // ─────────────────────────────────────────────────────────
  Future<void> _requestPermissions() async {
    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted =
      await androidPlugin.requestNotificationsPermission();
      debugPrint('🔔 Android notification permission: $granted');
    }

    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ─────────────────────────────────────────────────────────
  // SHOW NOTIFICATION FROM FCM MESSAGE
  // ─────────────────────────────────────────────────────────
  Future<void> showNotification(RemoteMessage message) async {
    final data = message.data;
    final bool isWild = data['is_wild'] == 'true';
    final String animalType = data['animal_type'] ?? 'Unknown';
    final String location = data['location'] ?? 'Unknown';

    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📩 SHOWING LOCAL NOTIFICATION');
    debugPrint('   Animal : $animalType');
    debugPrint('   Wild?  : $isWild');
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    late AndroidNotificationDetails androidDetails;

    if (isWild) {
      androidDetails = const AndroidNotificationDetails(
        wildChannelId,
        wildChannelName,
        channelDescription: wildChannelDesc,
        importance: Importance.max,
        priority: Priority.max,
        sound: RawResourceAndroidNotificationSound('alarm_sound'),
        playSound: true,
        enableVibration: true,
        fullScreenIntent: true,
        category: AndroidNotificationCategory.alarm,
        visibility: NotificationVisibility.public,
        ticker: 'WILD ANIMAL ALERT!',
        styleInformation: BigTextStyleInformation(''),
        autoCancel: true,
        ongoing: false,
      );
    } else {
      androidDetails = const AndroidNotificationDetails(
        generalChannelId,
        generalChannelName,
        channelDescription: generalChannelDesc,
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        autoCancel: true,
      );
    }

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final int notificationId =
    DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await _localNotifications.show(
      notificationId,
      message.notification?.title ??
          (isWild ? '🚨 WILD ANIMAL ALERT!' : '🐾 Animal Detected'),
      message.notification?.body ??
          'A $animalType was detected at $location',
      details,
      payload: jsonEncode(data),
    );

    debugPrint('✅ Notification shown (id: $notificationId)');
  }

  // ─────────────────────────────────────────────────────────
  // NOTIFICATION TAPPED — foreground
  // ✅ FIX: Made private with underscore to match the callback reference
  // ─────────────────────────────────────────────────────────
  static void _onNotificationTapped(NotificationResponse response) {
    debugPrint('📲 Notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        debugPrint('   Data: $data');
        // TODO: Navigate to detection detail screen
      } catch (_) {
        // ✅ FIX: was "catch ()" which is invalid syntax
        debugPrint('   Failed to parse payload');
      }
    }
  }

  // ─────────────────────────────────────────────────────────
  // NOTIFICATION TAPPED — background
  // ─────────────────────────────────────────────────────────
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationTapped(
      NotificationResponse response) {
    debugPrint(
        '📲 Background notification tapped: ${response.payload}');
  }
}