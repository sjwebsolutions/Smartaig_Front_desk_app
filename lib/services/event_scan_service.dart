import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/event_scan_model.dart';
import '../utils/token_manager.dart';

class EventScanService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/events/passes/today-scans';

  Future<EventScanResponseModel> fetchTodayScans({
    String? eventId,
    String? gateName,
    bool? myScansOnly,
    int? limit,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (eventId != null && eventId.isNotEmpty) {
      queryParams['event_id'] = eventId;
    }
    if (gateName != null && gateName.isNotEmpty) {
      queryParams['gate_name'] = gateName;
    }
    if (myScansOnly == true) {
      queryParams['my_scans_only'] = 'true';
    }
    if (limit != null && limit > 0) {
      queryParams['limit'] = limit.toString();
    }

    final uri = Uri.parse(baseUrl).replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    debugPrint('🌐 [EventScanService] GET request: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('📥 [EventScanService] Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return EventScanResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load today scans (${response.statusCode}): ${response.body}');
    }
  }

  Future<Map<String, dynamic>> scanPass({
    required String passNumber,
    String? gateName,
    String? eventId,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final uri = Uri.parse('https://smartaig.com/api/v1/front-desk/events/passes/scan');

    final bodyMap = <String, dynamic>{};

    final isQrPayload = passNumber.startsWith('ey') || passNumber.contains('{') || passNumber.contains('token') || passNumber.length > 50;

    if (isQrPayload) {
      bodyMap['qr_payload'] = passNumber;
    } else {
      bodyMap['pass_number'] = passNumber;
    }

    if (gateName != null && gateName.isNotEmpty) {
      bodyMap['gate_name'] = gateName;
    }

    if (eventId != null && eventId.isNotEmpty) {
      bodyMap['event_id'] = eventId;
    }

    debugPrint('🌐 [EventScanService] POST scan request: $uri with body: $bodyMap');

    http.Response response = await http.post(uri, headers: headers, body: jsonEncode(bodyMap));

    if (response.statusCode != 200 && response.statusCode != 201) {
      final checkInUri = Uri.parse('https://smartaig.com/api/v1/front-desk/events/passes/check-in');
      final fallbackResp = await http.post(checkInUri, headers: headers, body: jsonEncode(bodyMap));
      if (fallbackResp.statusCode == 200 || fallbackResp.statusCode == 201) {
        response = fallbackResp;
      }
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse;
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      String msg = 'Scan failed (${response.statusCode})';
      try {
        final json = jsonDecode(response.body);
        if (json['message'] != null) {
          msg = json['message'].toString();
        } else if (json['warning'] != null) {
          msg = json['warning'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
