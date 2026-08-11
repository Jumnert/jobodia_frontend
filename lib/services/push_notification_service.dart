import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:forui/forui.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:jobodia_frontend/features/notifications/controller/notifications_controller.dart';
import 'package:jobodia_frontend/features/notifications/model/notification_item.dart';
import 'package:jobodia_frontend/firebase_options.dart';
import 'package:jobodia_frontend/core/config/app_environment.dart';
import 'package:jobodia_frontend/services/secure_storage_service.dart';

class PushNotificationService extends GetxService {
  static const _authTokenKey = 'jobodiaAuthToken';
  static const _baseUrl = String.fromEnvironment(
    'JOBODIA_API_BASE_URL',
    defaultValue: 'https://v1.jobodia.com',
  );

  bool _initialized = false;

  Future<void> registerAuthenticatedDevice(String jwt) async {
    try {
      if (!await _initializeFirebase()) return;

      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _sendDeviceToken(token: token, jwt: jwt, remove: false);
      }
    } on Exception catch (error) {
      // Push setup must never prevent a successful authentication.
      debugPrint('Push token registration failed: $error');
    }
  }

  Future<void> unregisterAuthenticatedDevice(String jwt) async {
    if (!AppConfig.enableFirebase) return;
    try {
      if (!await _initializeFirebase()) return;
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await _sendDeviceToken(token: token, jwt: jwt, remove: true);
      }
    } on Exception catch (error) {
      debugPrint('Push token removal failed: $error');
    }
  }

  Future<bool> _initializeFirebase() async {
    final supportsFirebase =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (!AppConfig.enableFirebase || !supportsFirebase) return false;
    if (_initialized) return true;

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      }
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: true,
            badge: true,
            sound: true,
          );
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.instance.onTokenRefresh.listen((token) async {
        final jwt = await SecureStorageService.to.readSecure(_authTokenKey);
        if (jwt != null && jwt.isNotEmpty) {
          await _sendDeviceToken(token: token, jwt: jwt, remove: false);
        }
      });
      _initialized = true;
      return true;
    } on Exception catch (error) {
      debugPrint('Firebase messaging initialization failed: $error');
      return false;
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null || !Get.isRegistered<NotificationsController>()) {
      return;
    }

    Get.find<NotificationsController>().addNotification(
      NotificationItem(
        id:
            message.messageId ??
            'push-${DateTime.now().microsecondsSinceEpoch}',
        icon: FLucideIcons.bell,
        title: notification.title ?? 'Jobodia',
        body: notification.body ?? '',
        time: 'Now',
      ),
    );
  }

  Future<void> _sendDeviceToken({
    required String token,
    required String jwt,
    required bool remove,
  }) async {
    if (defaultTargetPlatform != TargetPlatform.android &&
        defaultTargetPlatform != TargetPlatform.iOS) {
      return;
    }

    try {
      final request =
          http.Request(
              remove ? 'DELETE' : 'POST',
              Uri.parse('$_baseUrl/api/v1/notifications/devices'),
            )
            ..headers.addAll({
              'Authorization': 'Bearer $jwt',
              'Content-Type': 'application/json',
            })
            ..body = jsonEncode({
              'token': token,
              'platform': defaultTargetPlatform == TargetPlatform.iOS
                  ? 'ios'
                  : 'android',
            });
      final response = await request.send().timeout(
        const Duration(seconds: 15),
      );
      if (response.statusCode < 200 || response.statusCode >= 300) {
        debugPrint('Push token registration failed: ${response.statusCode}');
      }
    } on Exception catch (error) {
      debugPrint('Push token registration failed: $error');
    }
  }
}
