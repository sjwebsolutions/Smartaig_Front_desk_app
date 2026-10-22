import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';
import '../view/screens/auth/login_screen.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _deviceUuidKey = 'device_unique_uuid';
  static bool _isLoggingOut = false;

  static Future<String> getDeviceUuid() async {
    final prefs = await SharedPreferences.getInstance();
    String? uuid = prefs.getString(_deviceUuidKey);
    if (uuid == null || uuid.trim().isEmpty) {
      final random = Random();
      uuid = 'device_${DateTime.now().millisecondsSinceEpoch}_${random.nextInt(999999)}';
      await prefs.setString(_deviceUuidKey, uuid);
      debugPrint('📱 [TokenManager] New unique device UUID generated: $uuid');
    }
    return uuid;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    String cleanToken = token.trim();
    if (cleanToken.startsWith('Bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    while ((cleanToken.startsWith('"') && cleanToken.endsWith('"')) ||
           (cleanToken.startsWith("'") && cleanToken.endsWith("'"))) {
      cleanToken = cleanToken.substring(1, cleanToken.length - 1).trim();
    }
    await prefs.setString(_tokenKey, cleanToken);
    _isLoggingOut = false;
    debugPrint('💾 [TokenManager] Token saved successfully (${cleanToken.length} chars)');
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString(_tokenKey);
    if (token == null || token.trim().isEmpty || token == 'null') return null;
    String cleanToken = token.trim();
    if (cleanToken.startsWith('Bearer ')) {
      cleanToken = cleanToken.substring(7).trim();
    }
    while ((cleanToken.startsWith('"') && cleanToken.endsWith('"')) ||
           (cleanToken.startsWith("'") && cleanToken.endsWith("'"))) {
      cleanToken = cleanToken.substring(1, cleanToken.length - 1).trim();
    }
    if (cleanToken.isEmpty || cleanToken == 'null') return null;
    return cleanToken;
  }

  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final fcmToken = await NotificationService.instance.getDeviceToken();
    final deviceUuid = await getDeviceUuid();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      if (fcmToken != null && fcmToken.isNotEmpty) 'X-FCM-Token': fcmToken,
      if (fcmToken != null && fcmToken.isNotEmpty) 'Device-Token': fcmToken,
      'X-Device-UUID': deviceUuid,
      'Device-UUID': deviceUuid,
    };
  }

  static Future<void> handleUnauthorized() async {
    if (_isLoggingOut) return; // Prevent multiple simultaneous logout triggers
    _isLoggingOut = true;

    final existingToken = await getToken();
    if (existingToken == null) {
      _isLoggingOut = false;
      return;
    }

    debugPrint('⚠️ [TokenManager] Unauthorized 401 detected. Logging out...');
    await removeToken();

    Get.offAll(() => const LoginScreen(sessionExpired: true));

    Future.delayed(const Duration(seconds: 3), () {
      _isLoggingOut = false;
    });
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    debugPrint('🗑️ [TokenManager] Token removed.');
  }
}
