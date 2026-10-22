import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view/screens/notification_list_screen.dart';
import '../view_models/get_x/admission_controller.dart';
import '../view_models/get_x/callback_controller.dart';
import '../view_models/get_x/dashboard_controller.dart';
import '../view_models/get_x/gate_pass_controller.dart';
import '../view_models/get_x/notification_history_controller.dart';
import '../view_models/get_x/student_leave_controller.dart';
import '../view_models/get_x/teacher_leave_controller.dart';
import '../view_models/get_x/unread_counter_controller.dart';
import '../view_models/get_x/visitor_controller.dart';

/// Helper to detect category (admission, gate_pass, visitor, callback, general)
String detectNotificationCategory({
  Map<String, dynamic>? data,
  String? title,
  String? body,
}) {
  final dataMap = data ?? {};
  final typeVal = (dataMap['type'] ??
          dataMap['notification_type'] ??
          dataMap['category'] ??
          dataMap['module'] ??
          dataMap['screen'] ??
          dataMap['action'] ??
          dataMap['event'] ??
          dataMap['tag'] ??
          dataMap['topic'] ??
          '')
      .toString()
      .toLowerCase();

  final titleVal = (title ?? dataMap['title'] ?? dataMap['heading'] ?? '').toString().toLowerCase();
  final bodyVal = (body ?? dataMap['body'] ?? dataMap['message'] ?? dataMap['content'] ?? '').toString().toLowerCase();
  final combined = '$typeVal $titleVal $bodyVal';

  if (combined.contains('admission') ||
      combined.contains('enquiry') ||
      combined.contains('inquiry') ||
      combined.contains('student_registration') ||
      combined.contains('registration') ||
      combined.contains('dakhila') ||
      combined.contains('dakila')) {
    return 'admission';
  } else if (combined.contains('teacher_leave') ||
      combined.contains('teacher_leaves') ||
      combined.contains('teacher leave') ||
      combined.contains('teacherleave') ||
      (combined.contains('teacher') && combined.contains('leave')) ||
      (combined.contains('ustad') && combined.contains('chhutti'))) {
    return 'teacher_leave';
  } else if (combined.contains('student_leave') ||
      combined.contains('student_leaves') ||
      combined.contains('student leave') ||
      (combined.contains('student') && combined.contains('leave')) ||
      combined.contains('leave_request') ||
      combined.contains('leave_status') ||
      combined.contains('leave_approved') ||
      combined.contains('leave_rejected') ||
      combined.contains('leave_app') ||
      combined.contains('leave')) {
    return 'student_leave';
  } else if (combined.contains('gate') ||
      combined.contains('pass') ||
      combined.contains('getpass') ||
      combined.contains('gatepass') ||
      combined.contains('outpass') ||
      combined.contains('exit') ||
      combined.contains('pickup') ||
      combined.contains('student_pass') ||
      combined.contains('chhutti')) {
    return 'gate_pass';
  } else if (combined.contains('visitor') ||
      combined.contains('guest') ||
      combined.contains('visiting') ||
      combined.contains('mehman') ||
      combined.contains('entry') ||
      combined.contains('checkin') ||
      combined.contains('check_in') ||
      combined.contains('visit') ||
      combined.contains('reception')) {
    return 'visitor';
  } else if (combined.contains('callback') ||
      combined.contains('call_back') ||
      combined.contains('call request') ||
      combined.contains('call') ||
      combined.contains('phone')) {
    return 'callback';
  }
  return 'general';
}

/// Formats notification title with student/teacher name if available in FCM payload data
String formatNotificationTitle({
  required Map<String, dynamic> data,
  required String rawTitle,
  required String categoryType,
}) {
  final dataTitle = (data['title'] ?? data['heading'] ?? data['notification_title'] ?? '').toString().trim();
  if (dataTitle.isNotEmpty && dataTitle != 'Front Desk Alert') {
    return dataTitle;
  }

  final studentName = (data['student_name'] ?? data['student'] ?? data['name'] ?? '').toString().trim();
  final teacherName = (data['teacher_name'] ?? data['teacher'] ?? data['name'] ?? '').toString().trim();

  if (categoryType == 'student_leave') {
    if (studentName.isNotEmpty) {
      return '📝 Student Leave: $studentName';
    }
    return '📝 Student Leave Request Alert';
  } else if (categoryType == 'teacher_leave') {
    if (teacherName.isNotEmpty) {
      return '📋 Teacher Leave: $teacherName';
    }
    return '📋 Teacher Leave Request Alert';
  } else if (categoryType == 'gate_pass') {
    if (studentName.isNotEmpty) {
      return '🎫 Gate Pass: $studentName';
    }
    return '🎫 Gate Pass Request Alert';
  }

  if (rawTitle.isNotEmpty && rawTitle != 'Front Desk Alert') {
    return rawTitle;
  }
  return 'Front Desk Alert';
}

/// Formats detailed notification body containing Student/Teacher Name, Class, Section, Session, Reason, Date etc.
String formatNotificationBody({
  required Map<String, dynamic> data,
  required String rawBody,
  required String categoryType,
}) {
  final studentName = (data['student_name'] ?? data['student'] ?? data['student_name_en'] ?? '').toString().trim();
  final teacherName = (data['teacher_name'] ?? data['teacher'] ?? data['teacher_name_en'] ?? '').toString().trim();
  final name = (data['name'] ?? '').toString().trim();

  final className = (data['class_name'] ?? data['class'] ?? data['student_class'] ?? data['grade'] ?? '').toString().trim();
  final sectionName = (data['section_name'] ?? data['section'] ?? data['student_section'] ?? '').toString().trim();
  final session = (data['session'] ?? data['academic_session'] ?? data['session_year'] ?? data['session_name'] ?? '').toString().trim();
  final reason = (data['reason'] ?? data['leave_reason'] ?? data['message'] ?? data['content'] ?? '').toString().trim();
  final leaveDate = (data['date'] ?? data['leave_date'] ?? data['from_date'] ?? '').toString().trim();

  final List<String> parts = [];

  if (categoryType == 'student_leave' || categoryType == 'gate_pass') {
    final sName = studentName.isNotEmpty ? studentName : name;
    if (sName.isNotEmpty) {
      parts.add('Name: $sName');
    }

    String classSec = '';
    if (className.isNotEmpty) classSec += 'Class: $className';
    if (sectionName.isNotEmpty) {
      classSec += (classSec.isNotEmpty ? ' ($sectionName)' : 'Sec: $sectionName');
    }
    if (classSec.isNotEmpty) {
      parts.add(classSec);
    }

    if (session.isNotEmpty) {
      parts.add('Session: $session');
    }

    if (leaveDate.isNotEmpty) {
      parts.add('Date: $leaveDate');
    }

    if (reason.isNotEmpty && reason != rawBody) {
      parts.add('Reason: $reason');
    }

    if (parts.isNotEmpty) {
      return parts.join(' | ');
    }
  } else if (categoryType == 'teacher_leave') {
    final tName = teacherName.isNotEmpty ? teacherName : name;
    if (tName.isNotEmpty) {
      parts.add('Name: $tName');
    }
    if (session.isNotEmpty) {
      parts.add('Session: $session');
    }
    if (leaveDate.isNotEmpty) {
      parts.add('Date: $leaveDate');
    }
    if (reason.isNotEmpty && reason != rawBody) {
      parts.add('Reason: $reason');
    }

    if (parts.isNotEmpty) {
      return parts.join(' | ');
    }
  }

  // Fallback if rawBody is informative
  if (rawBody.isNotEmpty && rawBody != 'You have a new request in Front Desk App.') {
    return rawBody;
  }

  return 'A new request has been received at reception.';
}

/// Top-level background message handler for Firebase Messaging.
/// Must be annotated with @pragma('vm:entry-point') so Flutter VM can find it.
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  final rawTitle = message.notification?.title ??
      message.data['title'] ??
      message.data['heading'] ??
      message.data['notification_title'] ??
      'Front Desk Alert';

  final rawBody = message.notification?.body ??
      message.data['body'] ??
      message.data['message'] ??
      message.data['content'] ??
      message.data['notification_body'] ??
      'You have a new request in Front Desk App.';

  final categoryType = detectNotificationCategory(
    data: message.data,
    title: rawTitle,
    body: rawBody,
  );

  final title = formatNotificationTitle(
    data: message.data,
    rawTitle: rawTitle,
    categoryType: categoryType,
  );

  final body = formatNotificationBody(
    data: message.data,
    rawBody: rawBody,
    categoryType: categoryType,
  );

  debugPrint('📩 [FCM Background Message]: ID: ${message.messageId}');
  debugPrint('Title: $title | Body: $body');
  debugPrint('Payload Data: ${message.data}');

  // Save unread counter and notification history in SharedPreferences
  try {
    final prefs = await SharedPreferences.getInstance();
    if (categoryType == 'admission') {
      final cur = prefs.getInt('unread_admission_count') ?? 0;
      await prefs.setInt('unread_admission_count', cur + 1);
    } else if (categoryType == 'teacher_leave') {
      final cur = prefs.getInt('unread_teacher_leave_count') ?? 0;
      await prefs.setInt('unread_teacher_leave_count', cur + 1);
    } else if (categoryType == 'student_leave') {
      final cur = prefs.getInt('unread_student_leave_count') ?? 0;
      await prefs.setInt('unread_student_leave_count', cur + 1);
    } else if (categoryType == 'gate_pass') {
      final cur = prefs.getInt('unread_gate_pass_count') ?? 0;
      await prefs.setInt('unread_gate_pass_count', cur + 1);
    } else if (categoryType == 'visitor') {
      final cur = prefs.getInt('unread_visitor_count') ?? 0;
      await prefs.setInt('unread_visitor_count', cur + 1);
    } else if (categoryType == 'callback') {
      final cur = prefs.getInt('unread_callback_count') ?? 0;
      await prefs.setInt('unread_callback_count', cur + 1);
    }

    final jsonStr = prefs.getString('saved_app_notifications') ?? '[]';
    final List<dynamic> decoded = jsonDecode(jsonStr);
    final newItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': title,
      'body': body,
      'timestamp': DateTime.now().toIso8601String(),
      'type': categoryType,
      'isRead': false,
      'data': message.data,
    };
    decoded.insert(0, newItem);
    await prefs.setString('saved_app_notifications', jsonEncode(decoded));
  } catch (e) {
    debugPrint('⚠️ [FCM Background Save Error]: $e');
  }

  // Show a local notification so the user receives a status bar banner with sound even for data messages.
  if (message.notification == null && message.data.isNotEmpty) {
    try {
      final FlutterLocalNotificationsPlugin localNotifications =
          FlutterLocalNotificationsPlugin();

      const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        defaultPresentAlert: true,
        defaultPresentSound: true,
        defaultPresentBadge: true,
        defaultPresentBanner: true,
        defaultPresentList: true,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );
      await localNotifications.initialize(initSettings);

      final categoryColor = categoryType == 'admission'
          ? const Color(0xFF4F46E5)
          : categoryType == 'gate_pass'
              ? const Color(0xFF0D9488)
              : categoryType == 'visitor'
                  ? const Color(0xFF2563EB)
                  : categoryType == 'callback'
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF4E54C8);

      final androidDetails = AndroidNotificationDetails(
        'front_desk_channel_v4',
        'Front Desk Urgent Callbacks & Alerts',
        channelDescription: 'Rings and displays heads-up alerts for Admission, Callback, Gate Pass, and Visitor requests',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        color: categoryColor,
        playSound: true,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
        category: AndroidNotificationCategory.message,
        visibility: NotificationVisibility.public,
        ticker: 'New Front Desk Request Received',
        styleInformation: BigTextStyleInformation(
          body,
          contentTitle: title,
          summaryText: categoryType == 'admission'
              ? 'Admission Enquiry Alert'
              : categoryType == 'gate_pass'
                  ? 'Gate Pass Alert'
                  : categoryType == 'visitor'
                      ? 'Visitor Log Alert'
                      : categoryType == 'callback'
                          ? 'Callback Alert'
                          : 'Front Desk Alert',
        ),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        presentBanner: true,
        presentList: true,
        interruptionLevel: InterruptionLevel.active,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );
      final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

      await localNotifications.show(
        notificationId,
        title,
        body,
        platformDetails,
        payload: jsonEncode(message.data),
      );
      debugPrint('🔊 [Background Local Notification Shown]: ID: $notificationId (Type: $categoryType)');
    } catch (e) {
      debugPrint('⚠️ Error displaying background local notification: $e');
    }
  }
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  FirebaseMessaging get _fcm => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'front_desk_channel_v4',
    'Front Desk Urgent Callbacks & Alerts',
    description: 'Rings and displays heads-up alerts for Admission, Callback, Gate Pass, and Visitor requests',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  /// Initializes Firebase and Push Notification configurations.
  Future<void> initialize() async {
    try {
      debugPrint('🔥 [NotificationService] Initializing Firebase and Messaging...');
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp().timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            debugPrint('⚠️ Firebase.initializeApp() timed out.');
            return Firebase.app();
          },
        );
      }
      debugPrint('✅ [NotificationService] Firebase App Initialized.');

      // 2. Request Notification Permissions
      try {
        await _requestPermission();
      } catch (e) {
        debugPrint('⚠️ Error requesting notification permission: $e');
      }

      // 3. Initialize Local Notifications for Foreground Display
      try {
        await _initLocalNotifications();
      } catch (e) {
        debugPrint('⚠️ Error initializing local notifications: $e');
      }

      // 4. Set Background Message Handler
      try {
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      } catch (e) {
        debugPrint('⚠️ Error setting background message handler: $e');
      }

      // 5. Setup Foreground Presentation Options (iOS)
      try {
        await _fcm.setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );
      } catch (e) {
        debugPrint('⚠️ Error setting foreground notification options: $e');
      }

      // 6. Setup Foreground Message Listener
      _listenForegroundMessages();

      // 7. Handle Notification Click when App is opened from background/terminated state
      _setupNotificationInteractions();

      // 8. Subscribe to all notification topics for Gate Pass, Visitors, Callbacks, Admission
      try {
        final topics = [
          'all',
          'front_desk',
          'frontdesk',
          'front_desk_app',
          // Admission Topics
          'admission',
          'admissions',
          'admission_enquiries',
          'admission_enquiry',
          'enquiry',
          'enquiries',
          // Gate Pass Topics
          'gate_pass',
          'gate_passes',
          'gate_pass_requests',
          'gate_pass_request',
          'gatepass',
          'gatepasses',
          'gatepass_requests',
          'gatepass_request',
          'get_pass',
          'get_passes',
          'get_pass_requests',
          'get_pass_request',
          'getpass',
          'getpass_requests',
          'student_gate_pass',
          'gate_pass_updates',
          'gate_pass_alerts',
          // Visitor Topics
          'visitor',
          'visitors',
          'visitor_requests',
          'visitor_request',
          'visitor_entry',
          'visitor_entries',
          'visitor_logs',
          'visitor_log',
          'guests',
          'guest',
          'visitor_updates',
          'visitor_alerts',
          'visitor_checkin',
          // Callback Topics
          'callback',
          'callbacks',
          'callback_requests',
          'callback_request',
          'call_requests',
          'call_request',
          // Teacher Leave Topics
          'teacher_leave',
          'teacher_leaves',
          'teacher_leave_requests',
          'teacher_leave_request',
          // Student Leave Topics
          'student_leave',
          'student_leaves',
          'student_leave_requests',
          'student_leave_request',
          'leave_requests',
          'leave_request',
          'leaves',
        ];
        for (final topic in topics) {
          await subscribeToTopic(topic);
        }
      } catch (e) {
        debugPrint('⚠️ Error subscribing to FCM topics: $e');
      }

      // 9. Fetch and log FCM Token
      getDeviceToken().then((token) {
        if (token != null) {
          debugPrint('🔥 [FCM Device Token]: $token');
        }
      });

      // 10. Listen for Token Refresh
      _fcm.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 [FCM Token Refreshed]: $newToken');
      });
    } catch (e, stack) {
      debugPrint('❌ Error initializing NotificationService: $e\n$stack');
    }
  }

  /// Trigger a test Admission notification with sound locally
  Future<void> showTestAdmissionNotification() async {
    debugPrint('🔊 [NotificationService] Triggering Admission Test Notification with Sound...');

    const title = '🎓 New Admission Enquiry Alert';
    const body = 'A new student admission enquiry has been registered at reception.';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: const Color(0xFF4F46E5),
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'New Admission Enquiry Alert',
      styleInformation: const BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Admission Enquiry Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = jsonEncode({
      'type': 'admission',
      'title': title,
      'body': body,
    });

    UnreadCounterController.to.incrementAdmission();
    NotificationHistoryController.to.addNotification(
      title: title,
      body: body,
      type: 'admission',
      data: {'type': 'admission'},
    );

    await _localNotifications.show(
      666,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    debugPrint('🔊 [Admission Test Notification Banner & Sound Fired]');
  }

  /// Trigger a test Gate Pass notification with sound locally
  Future<void> showTestGatePassNotification() async {
    debugPrint('🔊 [NotificationService] Triggering Gate Pass Test Notification with Sound...');

    const title = '🎫 Gate Pass Request Alert';
    const body = 'New student gate pass request received from parent for early leave.';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: const Color(0xFF0D9488),
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'Gate Pass Request Alert',
      styleInformation: const BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Gate Pass Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = jsonEncode({
      'type': 'gate_pass',
      'title': title,
      'body': body,
    });

    UnreadCounterController.to.incrementGatePass();
    NotificationHistoryController.to.addNotification(
      title: title,
      body: body,
      type: 'gate_pass',
      data: {'type': 'gate_pass'},
    );

    await _localNotifications.show(
      888,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    debugPrint('🔊 [Gate Pass Test Notification Banner & Sound Fired]');
  }

  /// Trigger a test Visitor Log notification with sound locally
  Future<void> showTestVisitorNotification() async {
    debugPrint('🔊 [NotificationService] Triggering Visitor Test Notification with Sound...');

    const title = 'New Visitor Checked In';
    const body = 'A visitor entry has been logged at the front desk reception.';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: const Color(0xFF2563EB),
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'New Visitor Check-in Alert',
      styleInformation: const BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Visitor Log Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = jsonEncode({
      'type': 'visitor',
      'title': title,
      'body': body,
    });

    UnreadCounterController.to.incrementVisitor();
    NotificationHistoryController.to.addNotification(
      title: title,
      body: body,
      type: 'visitor',
      data: {'type': 'visitor'},
    );

    await _localNotifications.show(
      999,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    debugPrint('🔊 [Visitor Test Notification Banner & Sound Fired]');
  }

  /// Trigger a test Callback notification with sound locally
  Future<void> showTestCallbackNotification() async {
    debugPrint('🔊 [NotificationService] Triggering Callback Test Notification with Sound...');

    const title = '🔔 Callback Request Alert';
    const body = 'Parent requested an urgent callback regarding their child.';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: const Color(0xFFDC2626),
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'New Callback Request Alert',
      styleInformation: const BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Callback Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = jsonEncode({
      'type': 'callback',
      'title': title,
      'body': body,
    });

    UnreadCounterController.to.incrementCallback();
    NotificationHistoryController.to.addNotification(
      title: title,
      body: body,
      type: 'callback',
      data: {'type': 'callback'},
    );

    await _localNotifications.show(
      777,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    debugPrint('🔊 [Callback Test Notification Banner & Sound Fired]');
  }

  /// Trigger a test Teacher Leave notification with sound locally
  Future<void> showTestTeacherLeaveNotification() async {
    debugPrint('🔊 [NotificationService] Triggering Teacher Leave Test Notification with Sound...');

    const title = '📋 Teacher Leave Request Alert';
    const body = 'A teacher has submitted a new leave application.';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: const Color(0xFF0284C7),
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'Teacher Leave Request Alert',
      styleInformation: const BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Teacher Leave Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = jsonEncode({
      'type': 'teacher_leave',
      'title': title,
      'body': body,
    });

    UnreadCounterController.to.incrementTeacherLeave();
    NotificationHistoryController.to.addNotification(
      title: title,
      body: body,
      type: 'teacher_leave',
      data: {'type': 'teacher_leave'},
    );

    await _localNotifications.show(
      555,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    debugPrint('🔊 [Teacher Leave Test Notification Banner & Sound Fired]');
  }

  /// Trigger a test Student Leave notification with sound locally
  Future<void> showTestStudentLeaveNotification() async {
    debugPrint('🔊 [NotificationService] Triggering Student Leave Test Notification with Sound...');

    const title = '📝 Student Leave Request Alert';
    const body = 'A new student leave request has been submitted by parent.';

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: const Color(0xFFE11D48),
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: 'Student Leave Request Alert',
      styleInformation: const BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: 'Student Leave Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    final payload = jsonEncode({
      'type': 'student_leave',
      'title': title,
      'body': body,
    });

    UnreadCounterController.to.incrementStudentLeave();
    NotificationHistoryController.to.addNotification(
      title: title,
      body: body,
      type: 'student_leave',
      data: {'type': 'student_leave'},
    );

    await _localNotifications.show(
      444,
      title,
      body,
      platformDetails,
      payload: payload,
    );
    debugPrint('🔊 [Student Leave Test Notification Banner & Sound Fired]');
  }

  /// Legacy helper for testing callback notifications
  Future<void> showTestNotification() async {
    await showTestCallbackNotification();
  }

  final Map<String, DateTime> _recentNotificationKeys = {};
  final Map<String, DateTime> _recentCategoryTimes = {};

  /// Checks if a notification was processed recently (within 10-15 seconds) to avoid duplicate alerts.
  bool isDuplicateAndMark(String title, String body, String categoryType, {bool isTest = false}) {
    if (isTest) return false;

    final now = DateTime.now();
    _recentNotificationKeys.removeWhere((_, time) => now.difference(time).inSeconds > 60);
    _recentCategoryTimes.removeWhere((_, time) => now.difference(time).inSeconds > 60);

    final cleanTitle = title.trim().toLowerCase();
    final cleanBody = body.trim().toLowerCase();
    final key = '${categoryType}_${cleanTitle}_$cleanBody';

    // 1. Check exact title/body key
    if (_recentNotificationKeys.containsKey(key)) {
      debugPrint('⚡ [NotificationService] Exact duplicate suppressed: $key');
      return true;
    }

    // 2. For category types (admission, callback, gate_pass, visitor, teacher_leave, student_leave), suppress duplicate alerts of same category within 60s
    if (categoryType == 'admission' ||
        categoryType == 'callback' ||
        categoryType == 'gate_pass' ||
        categoryType == 'visitor' ||
        categoryType == 'teacher_leave' ||
        categoryType == 'student_leave') {
      if (_recentCategoryTimes.containsKey(categoryType)) {
        final lastTime = _recentCategoryTimes[categoryType]!;
        if (now.difference(lastTime).inSeconds < 60) {
          debugPrint('⚡ [NotificationService] Category ($categoryType) duplicate suppressed within 60s window.');
          return true;
        }
      }
      _recentCategoryTimes[categoryType] = now;
    }

    _recentNotificationKeys[key] = now;
    return false;
  }

  /// Displays a heads-up local alert with sound and vibration and adds to history
  Future<void> showLocalAlert({
    required String title,
    required String body,
    required String type, // 'admission', 'gate_pass', 'visitor', 'callback', 'teacher_leave', 'student_leave'
    Map<String, dynamic>? data,
    bool incrementUnread = false,
  }) async {
    if (isDuplicateAndMark(title, body, type)) {
      debugPrint('⚡ [NotificationService] Suppressing duplicate local alert for $type ($title)');
      return;
    }

    if (incrementUnread) {
      if (type == 'admission') {
        UnreadCounterController.to.incrementAdmission();
      } else if (type == 'teacher_leave') {
        UnreadCounterController.to.incrementTeacherLeave();
      } else if (type == 'student_leave') {
        UnreadCounterController.to.incrementStudentLeave();
      } else if (type == 'gate_pass') {
        UnreadCounterController.to.incrementGatePass();
      } else if (type == 'visitor') {
        UnreadCounterController.to.incrementVisitor();
      } else if (type == 'callback') {
        UnreadCounterController.to.incrementCallback();
      }
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final categoryColor = type == 'admission'
        ? const Color(0xFF4F46E5)
        : type == 'teacher_leave'
            ? const Color(0xFF0284C7)
            : type == 'student_leave'
                ? const Color(0xFFE11D48)
                : type == 'gate_pass'
                    ? const Color(0xFF0D9488)
                    : type == 'visitor'
                        ? const Color(0xFF2563EB)
                        : type == 'callback'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF4E54C8);

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: categoryColor,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: title,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: type == 'admission'
            ? 'Admission Enquiry Alert'
            : type == 'teacher_leave'
                ? 'Teacher Leave Alert'
                : type == 'student_leave'
                    ? 'Student Leave Alert'
                    : type == 'gate_pass'
                        ? 'Gate Pass Alert'
                        : type == 'visitor'
                            ? 'Visitor Log Alert'
                            : type == 'callback'
                                ? 'Callback Alert'
                                : 'Front Desk Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final payloadMap = Map<String, dynamic>.from(data ?? {});
    payloadMap['type'] = type;
    payloadMap['title'] = title;
    payloadMap['body'] = body;

    // Add to history
    NotificationHistoryController.to.addNotification(
      title: title,
      body: body,
      type: type,
      data: payloadMap,
    );

    await _localNotifications.show(
      notificationId,
      title,
      body,
      platformDetails,
      payload: jsonEncode(payloadMap),
    );
    debugPrint('🔊 [Live Local Alert Fired]: $title (Type: $type)');
  }

  /// Request Notification Permissions from the user
  Future<void> _requestPermission() async {
    debugPrint('🔔 [NotificationService] Requesting notification permissions...');
    final settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: false,
      announcement: false,
    );

    debugPrint('🔔 [FCM Permission Status]: ${settings.authorizationStatus}');

    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      debugPrint('🔔 [Android System Notification Permission Granted]: $granted');
    }
  }

  /// Configure flutter_local_notifications plugin
  Future<void> _initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
      defaultPresentAlert: true,
      defaultPresentSound: true,
      defaultPresentBadge: true,
      defaultPresentBanner: true,
      defaultPresentList: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint('👆 Local Notification tapped: ${response.payload}');
        _handleLocalNotificationTap(response.payload);
      },
    );

    // Create Notification Channel for Android
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(_channel);
      debugPrint('🔔 [Android Notification Channel Created]: ${_channel.id}');
    }
  }

  /// Listen to messages while app is in foreground and display banner
  void _listenForegroundMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final rawTitle = message.notification?.title ??
          message.data['title'] ??
          message.data['heading'] ??
          message.data['notification_title'] ??
          'Front Desk Alert';

      final rawBody = message.notification?.body ??
          message.data['body'] ??
          message.data['message'] ??
          message.data['content'] ??
          message.data['notification_body'] ??
          'You have a new request in Front Desk App.';

      final categoryType = detectNotificationCategory(
        data: message.data,
        title: rawTitle,
        body: rawBody,
      );

      final title = formatNotificationTitle(
        data: message.data,
        rawTitle: rawTitle,
        categoryType: categoryType,
      );

      final body = formatNotificationBody(
        data: message.data,
        rawBody: rawBody,
        categoryType: categoryType,
      );

      // Deduplicate foreground FCM message if already processed recently
      if (isDuplicateAndMark(title, body, categoryType)) {
        debugPrint('⚡ [NotificationService] Suppressing duplicate FCM foreground message: $title');
        return;
      }

      debugPrint('📩 [FCM Foreground Message]: ID: ${message.messageId}');
      debugPrint('Title: $title | Body: $body');
      debugPrint('Data: ${message.data}');

      if (categoryType == 'admission') {
        UnreadCounterController.to.incrementAdmission();
        if (Get.isRegistered<AdmissionController>()) {
          try { Get.find<AdmissionController>().fetchAdmissionEnquiries(isSilent: true); } catch (_) {}
        }
      } else if (categoryType == 'teacher_leave') {
        UnreadCounterController.to.incrementTeacherLeave();
        if (Get.isRegistered<TeacherLeaveController>()) {
          try { Get.find<TeacherLeaveController>().fetchTeacherLeaves(isManualRefresh: true); } catch (_) {}
        }
      } else if (categoryType == 'student_leave') {
        UnreadCounterController.to.incrementStudentLeave();
        if (Get.isRegistered<StudentLeaveController>()) {
          try { Get.find<StudentLeaveController>().fetchStudentLeaves(isManualRefresh: true); } catch (_) {}
        }
      } else if (categoryType == 'gate_pass') {
        UnreadCounterController.to.incrementGatePass();
        if (Get.isRegistered<GatePassController>()) {
          try { Get.find<GatePassController>().fetchGatePasses(isRefresh: true); } catch (_) {}
        }
      } else if (categoryType == 'visitor') {
        UnreadCounterController.to.incrementVisitor();
        if (Get.isRegistered<VisitorController>()) {
          try { Get.find<VisitorController>().fetchVisitors(isRefresh: true); } catch (_) {}
        }
      } else if (categoryType == 'callback') {
        UnreadCounterController.to.incrementCallback();
        if (Get.isRegistered<CallbackController>()) {
          try { Get.find<CallbackController>().fetchCallbacks(isRefresh: true); } catch (_) {}
        }
      }

      // Refresh DashboardController silently to update baseline stats immediately and prevent duplicate alerts
      if (Get.isRegistered<DashboardController>()) {
        try { Get.find<DashboardController>().fetchDashboard(isSilent: true); } catch (_) {}
      }

      // Add to NotificationHistoryController
      NotificationHistoryController.to.addNotification(
        title: title,
        body: body,
        type: categoryType,
        data: message.data,
      );

      _showNotificationBanner(message);
    });
  }

  /// Show heads-up notification banner with sound for foreground messages
  Future<void> _showNotificationBanner(RemoteMessage message) async {
    final notification = message.notification;

    final rawTitle = notification?.title ??
        message.data['title'] ??
        message.data['heading'] ??
        message.data['notification_title'] ??
        'Front Desk Alert';

    final rawBody = notification?.body ??
        message.data['body'] ??
        message.data['message'] ??
        message.data['content'] ??
        message.data['notification_body'] ??
        'You have a new request in Front Desk App.';

    final notificationId = message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);

    final categoryType = detectNotificationCategory(
      data: message.data,
      title: rawTitle,
      body: rawBody,
    );

    final title = formatNotificationTitle(
      data: message.data,
      rawTitle: rawTitle,
      categoryType: categoryType,
    );

    final body = formatNotificationBody(
      data: message.data,
      rawBody: rawBody,
      categoryType: categoryType,
    );

    final categoryColor = categoryType == 'admission'
        ? const Color(0xFF4F46E5)
        : categoryType == 'teacher_leave'
            ? const Color(0xFF0284C7)
            : categoryType == 'student_leave'
                ? const Color(0xFFE11D48)
                : categoryType == 'gate_pass'
                    ? const Color(0xFF0D9488)
                    : categoryType == 'visitor'
                        ? const Color(0xFF2563EB)
                        : categoryType == 'callback'
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF4E54C8);

    final androidDetails = AndroidNotificationDetails(
      _channel.id,
      _channel.name,
      channelDescription: _channel.description,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/launcher_icon',
      largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
      color: categoryColor,
      playSound: true,
      enableVibration: true,
      audioAttributesUsage: AudioAttributesUsage.notification,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
      ticker: title,
      styleInformation: BigTextStyleInformation(
        body,
        contentTitle: title,
        summaryText: categoryType == 'admission'
            ? 'Admission Enquiry Alert'
            : categoryType == 'teacher_leave'
                ? 'Teacher Leave Alert'
                : categoryType == 'student_leave'
                    ? 'Student Leave Alert'
                    : categoryType == 'gate_pass'
                        ? 'Gate Pass Alert'
                        : categoryType == 'visitor'
                            ? 'Visitor Log Alert'
                            : categoryType == 'callback'
                                ? 'Callback Alert'
                                : 'Front Desk Alert',
      ),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      presentBanner: true,
      presentList: true,
      interruptionLevel: InterruptionLevel.active,
    );

    final platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      notificationId,
      title,
      body,
      platformDetails,
      payload: jsonEncode(message.data),
    );
    debugPrint('🔊 [Foreground Local Notification Banner Shown]: ID: $notificationId (Type: $categoryType)');
  }

  /// Handle Notification Click when user taps a notification
  Future<void> _setupNotificationInteractions() async {
    try {
      // 1. App opened from TERMINATED state
      final initialMessage = await _fcm.getInitialMessage().timeout(
        const Duration(seconds: 3),
        onTimeout: () => null,
      );
      if (initialMessage != null) {
        debugPrint('🚀 App launched from Terminated notification: ${initialMessage.data}');
        _handleNotificationClick(initialMessage);
      }
    } catch (e) {
      debugPrint('⚠️ Error getting initial FCM message: $e');
    }

    // 2. App opened from BACKGROUND state
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('🚀 App opened from Background notification: ${message.data}');
      _handleNotificationClick(message);
    });
  }

  /// Handle Notification Click - Navigates to NotificationListScreen
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint('🔔 [Notification Click]: User tapped notification. Data: ${message.data}');
    _navigateToNotificationScreen();
  }

  /// Handle local notification banner tap - Navigates to NotificationListScreen
  void _handleLocalNotificationTap(String? payload) {
    debugPrint('👆 [Local Notification Click]: User tapped banner. Payload: $payload');
    _navigateToNotificationScreen();
  }

  void _navigateToNotificationScreen() {
    Future.delayed(const Duration(milliseconds: 300), () {
      try {
        NotificationHistoryController.to.markAllAsRead();
        Get.to(() => const NotificationListScreen());
      } catch (e) {
        debugPrint('⚠️ Error navigating to NotificationListScreen: $e');
      }
    });
  }

  /// Fetch device FCM Token
  Future<String?> getDeviceToken() async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final token = await _fcm.getToken().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('⚠️ FCM getToken timed out.');
          return null;
        },
      );
      return token;
    } catch (e) {
      debugPrint('❌ Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _fcm.subscribeToTopic(topic);
      debugPrint('✅ Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to subscribe to topic $topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _fcm.unsubscribeFromTopic(topic);
      debugPrint('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('❌ Failed to unsubscribe from topic $topic: $e');
    }
  }
}
