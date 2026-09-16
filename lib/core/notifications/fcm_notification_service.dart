import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';

const fcmNotificationChannelId = 'skills_pathway_notifications';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

class FcmNotificationContent {
  const FcmNotificationContent({required this.title, required this.body});

  final String title;
  final String body;
}

class FcmNotificationService {
  FcmNotificationService({
    FirebaseMessaging? messaging,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  static final instance = FcmNotificationService();

  final FirebaseMessaging _messaging;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FlutterLocalNotificationsPlugin _localNotifications;

  StreamSubscription<String>? _tokenSubscription;
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;
  String? _currentUserId;
  String? _token;
  Map<String, dynamic>? _lastTapData;
  bool _initialized = false;

  String? get currentToken => _token;
  Map<String, dynamic>? get lastTapData => _lastTapData;

  Future<void> initialize() async {
    if (_initialized || Firebase.apps.isEmpty) return;
    _initialized = true;

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _handleForegroundMessage,
    );
    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _handleNotificationTap,
    );

    await _initializeLocalNotifications();
    await _requestPermission();

    _authSubscription = _auth.authStateChanges().listen((user) {
      unawaited(_handleAuthChanged(user));
    });
    _tokenSubscription = _messaging.onTokenRefresh.listen((token) {
      unawaited(_handleTokenRefresh(token));
    });

    try {
      _token = await _messaging.getToken();
      if (_token != null) {
        debugPrint('FCM Token: $_token');
        await _saveTokenForCurrentUser();
      }
    } catch (error) {
      debugPrint('[FCM] Token retrieval unavailable: $error');
    }

    try {
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) _handleNotificationTap(initialMessage);
    } catch (error) {
      debugPrint('[FCM] Initial message unavailable: $error');
    }
  }

  Future<void> _initializeLocalNotifications() async {
    try {
      const androidSettings = AndroidInitializationSettings(
        '@mipmap/launcher_icon',
      );
      const settings = InitializationSettings(
        android: androidSettings,
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(
        settings: settings,
        onDidReceiveNotificationResponse: _handleLocalNotificationTap,
      );
      final android = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          fcmNotificationChannelId,
          'Skills Pathway notifications',
          description: 'Notifications from Skills Pathway.',
          importance: Importance.high,
        ),
      );
    } catch (error) {
      debugPrint('[FCM] Local notification setup unavailable: $error');
    }
  }

  Future<void> _requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('[FCM] Notification permission: ${settings.authorizationStatus}');
    } catch (error) {
      debugPrint('[FCM] Notification permission unavailable: $error');
    }
  }

  Future<void> _handleAuthChanged(User? user) async {
    _currentUserId = user?.uid;
    if (user != null) await _saveTokenForCurrentUser();
  }

  Future<void> _handleTokenRefresh(String token) async {
    _token = token;
    debugPrint('FCM Token: $token');
    await _saveTokenForCurrentUser();
  }

  Future<void> _saveTokenForCurrentUser() async {
    final userId = _currentUserId ?? _auth.currentUser?.uid;
    final token = _token;
    if (userId == null || token == null || _auth.currentUser?.uid != userId) {
      return;
    }
    try {
      await _firestore.collection('users').doc(userId).set({
        'fcmToken': token,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (error) {
      debugPrint('[FCM] Token storage unavailable: $error');
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final content = contentFor(message);
    if (content == null) return;
    try {
      await _localNotifications.show(
        id: message.hashCode,
        title: content.title,
        body: content.body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            fcmNotificationChannelId,
            'Skills Pathway notifications',
            channelDescription: 'Notifications from Skills Pathway.',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    } catch (error) {
      debugPrint('[FCM] Foreground notification display unavailable: $error');
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    _lastTapData = Map<String, dynamic>.from(message.data);
    debugPrint('[FCM] Notification tapped with data: $_lastTapData');
  }

  void _handleLocalNotificationTap(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null || payload.isEmpty) return;
    try {
      _lastTapData = jsonDecode(payload) as Map<String, dynamic>;
      debugPrint('[FCM] Local notification tapped with data: $_lastTapData');
    } catch (error) {
      debugPrint('[FCM] Invalid notification payload: $error');
    }
  }

  static FcmNotificationContent? contentFor(RemoteMessage message) {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();
    if (title == null && body == null) return null;
    return FcmNotificationContent(title: title ?? 'Skills Pathway', body: body ?? '');
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    await _authSubscription?.cancel();
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();
  }
}