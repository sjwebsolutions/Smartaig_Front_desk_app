import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/scan_attendance_model.dart';
import '../utils/token_manager.dart';

class ScanAttendanceService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/scan-attendance';

  String _parseErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['message'] != null && json['message'].toString().isNotEmpty) {
        return json['message'].toString();
      }
    } catch (_) {}
    return '$fallbackMessage (${response.statusCode})';
  }

  Future<ScanAttendanceResponseModel> fetchTodayLogs({String? date, String? type}) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (date != null && date.isNotEmpty) queryParams['date'] = date;
    if (type != null && type.isNotEmpty && type != 'all') queryParams['type'] = type;

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    debugPrint('🌐 [ScanAttendanceService] GET request: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('📥 [ScanAttendanceService] Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ScanAttendanceResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to fetch scan logs'));
    }
  }

  Future<ScanSubmitResponseModel> markAttendanceScan({
    required String code,
    required String attendanceType, // 'auto', 'check_in', 'check_out'
    required String userType, // 'student', 'teacher', 'all'
    String? remarks,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final body = jsonEncode({
      'code': code.trim(),
      'attendance_type': attendanceType,
      'user_type': userType,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    });

    final uri = Uri.parse('$baseUrl/mark');

    debugPrint('🌐 [ScanAttendanceService] POST request: $uri');
    debugPrint('📤 [ScanAttendanceService] Body: $body');

    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );

    debugPrint('📥 [ScanAttendanceService] Mark Response (${response.statusCode}): ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ScanSubmitResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to mark attendance scan'));
    }
  }

  Future<QrAttendanceSettingsResponseModel> fetchQrSettings({
    String? status,
    String? date,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
      queryParams['status'] = status.toLowerCase();
    }
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }

    final primaryUri = Uri.parse('https://smartaig.com/api/v1/front-desk/student-attendance/qr-settings')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    debugPrint('🌐 [ScanAttendanceService] GET QR Settings: $primaryUri');

    final response = await http.get(primaryUri, headers: headers);
    debugPrint('📥 [ScanAttendanceService] QR Settings response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return QrAttendanceSettingsResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      // Fallback in case endpoint is under scan-attendance/qr-settings
      final fallbackUri = Uri.parse('https://smartaig.com/api/v1/front-desk/scan-attendance/qr-settings')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);
      try {
        final fallbackResponse = await http.get(fallbackUri, headers: headers);
        if (fallbackResponse.statusCode == 200) {
          final Map<String, dynamic> jsonResponse = jsonDecode(fallbackResponse.body);
          return QrAttendanceSettingsResponseModel.fromJson(jsonResponse);
        }
      } catch (_) {}

      throw Exception(_parseErrorMessage(response, 'Failed to fetch QR settings'));
    }
  }

  Future<QrScanAttendanceResponseModel> scanQrAttendance({
    required String qrPayload,
    String? sourceApp,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final platformSource = sourceApp ?? (kIsWeb ? 'web' : (Platform.isIOS ? 'ios' : 'android'));

    final body = jsonEncode({
      'qr_payload': qrPayload.trim(),
      'source_app': platformSource,
    });

    final primaryUri = Uri.parse('https://smartaig.com/api/v1/front-desk/student-attendance/qr-scan');

    debugPrint('🌐 [ScanAttendanceService] POST QR Scan: $primaryUri');
    debugPrint('📤 [ScanAttendanceService] Body: $body');

    final response = await http.post(
      primaryUri,
      headers: headers,
      body: body,
    );

    debugPrint('📥 [ScanAttendanceService] QR Scan Response (${response.statusCode}): ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return QrScanAttendanceResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 400 || response.statusCode == 422) {
      try {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        if (jsonResponse['already_marked'] == true || jsonResponse['data'] != null) {
          return QrScanAttendanceResponseModel.fromJson(jsonResponse);
        }
      } catch (_) {}
      throw Exception(_parseErrorMessage(response, 'Failed to process QR attendance scan'));
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      // Fallback in case route is scan-attendance/qr-scan
      final fallbackUri = Uri.parse('https://smartaig.com/api/v1/front-desk/scan-attendance/qr-scan');
      try {
        final fallbackResponse = await http.post(fallbackUri, headers: headers, body: body);
        if (fallbackResponse.statusCode == 200 || fallbackResponse.statusCode == 201) {
          final Map<String, dynamic> jsonResponse = jsonDecode(fallbackResponse.body);
          return QrScanAttendanceResponseModel.fromJson(jsonResponse);
        }
      } catch (_) {}

      throw Exception(_parseErrorMessage(response, 'Failed to process QR attendance scan'));
    }
  }
}
