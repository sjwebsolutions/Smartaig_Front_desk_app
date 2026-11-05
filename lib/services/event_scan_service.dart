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

  Future<PassCheckinResponseModel> checkInAttendees({
    dynamic passId,
    String? passNumber,
    required List<dynamic> attendeeIds,
    String? gateName,
    String? remarks,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final uri = Uri.parse('https://smartaig.com/api/v1/front-desk/events/passes/check-in');

    final bodyMap = <String, dynamic>{
      'attendee_ids': attendeeIds,
    };

    if (passId != null) {
      bodyMap['pass_id'] = passId;
    }
    if (passNumber != null && passNumber.isNotEmpty) {
      bodyMap['pass_number'] = passNumber;
    }
    if (gateName != null && gateName.isNotEmpty) {
      bodyMap['gate_name'] = gateName;
    }
    if (remarks != null && remarks.isNotEmpty) {
      bodyMap['remarks'] = remarks;
    }

    debugPrint('🌐 [EventScanService] POST check-in request: $uri with body: $bodyMap');

    final response = await http.post(uri, headers: headers, body: jsonEncode(bodyMap));

    debugPrint('📥 [EventScanService] Check-in response code: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return PassCheckinResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      String msg = 'Check-in failed (${response.statusCode})';
      try {
        final json = jsonDecode(response.body);
        if (json['message'] != null) {
          msg = json['message'].toString();
        } else if (json['error'] != null) {
          msg = json['error'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<EventSearchStudentResponseModel> searchStudents({
    required dynamic eventId,
    required String query,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{
      'event_id': eventId.toString(),
      'query': query,
    };

    final uri = Uri.parse('https://smartaig.com/api/v1/front-desk/events/passes/search-students')
        .replace(queryParameters: queryParams);

    debugPrint('🌐 [EventScanService] GET search-students request: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('📥 [EventScanService] search-students status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return EventSearchStudentResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to search students (${response.statusCode}): ${response.body}');
    }
  }

  Future<PassApplicationResponseModel> fetchPassApplications({
    required dynamic eventId,
    int? page,
    int? perPage,
    String? status,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{
      'event_id': eventId.toString(),
    };
    if (page != null) queryParams['page'] = page.toString();
    if (perPage != null) queryParams['per_page'] = perPage.toString();
    if (status != null && status.isNotEmpty) queryParams['status'] = status;

    final uri = Uri.parse('https://smartaig.com/api/v1/front-desk/events/passes/applications')
        .replace(queryParameters: queryParams);

    debugPrint('🌐 [EventScanService] GET applications request: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('📥 [EventScanService] applications status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return PassApplicationResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load pass applications (${response.statusCode}): ${response.body}');
    }
  }

  Future<IssueWalkInPassResponseModel> issueWalkInPass({
    required dynamic eventId,
    required dynamic studentId,
    bool autoApprove = true,
    bool autoCheckin = true,
    String? gateName,
    String? remarks,
    required String personType,
    required String attendeeName,
    required String mobileNo,
    String? whatsappNo,
    String? aadhaarNumber,
    dynamic photoFile,
    String? existingPhotoPath,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final uri = Uri.parse('https://smartaig.com/api/v1/front-desk/events/passes/issue-walk-in');

    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll(headers);

    request.fields['event_id'] = eventId.toString();
    request.fields['student_id'] = studentId.toString();
    request.fields['auto_approve'] = autoApprove.toString();
    request.fields['auto_checkin'] = autoCheckin.toString();
    if (gateName != null && gateName.isNotEmpty) {
      request.fields['gate_name'] = gateName;
    }
    if (remarks != null && remarks.isNotEmpty) {
      request.fields['remarks'] = remarks;
    }

    request.fields['attendees[0][person_type]'] = personType;
    request.fields['attendees[0][name]'] = attendeeName;
    request.fields['attendees[0][mobile_no]'] = mobileNo;
    if (whatsappNo != null && whatsappNo.isNotEmpty) {
      request.fields['attendees[0][whatsapp_no]'] = whatsappNo;
    }
    if (aadhaarNumber != null && aadhaarNumber.isNotEmpty) {
      request.fields['attendees[0][aadhaar_number]'] = aadhaarNumber;
    }
    if (existingPhotoPath != null && existingPhotoPath.isNotEmpty) {
      request.fields['attendees[0][existing_photo_path]'] = existingPhotoPath;
    }

    if (photoFile != null) {
      if (photoFile is String && photoFile.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('attendees[0][photo]', photoFile));
      }
    }

    debugPrint('🌐 [EventScanService] POST issue-walk-in request: $uri with fields: ${request.fields}');

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('📥 [EventScanService] issue-walk-in status: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return IssueWalkInPassResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      String msg = 'Failed to issue walk-in pass (${response.statusCode})';
      try {
        final json = jsonDecode(response.body);
        if (json['message'] != null) {
          msg = json['message'].toString();
        } else if (json['error'] != null) {
          msg = json['error'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }

  Future<UpdatePassStatusResponseModel> updatePassStatus({
    required dynamic passId,
    required String action,
    String? remarks,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    headers['Content-Type'] = 'application/json';

    final uri = Uri.parse('https://smartaig.com/api/v1/front-desk/events/passes/update-status');

    final bodyMap = <String, dynamic>{
      'pass_id': passId,
      'action': action,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    };

    debugPrint('🌐 [EventScanService] POST update-status request: $uri with body: $bodyMap');

    final response = await http.post(uri, headers: headers, body: jsonEncode(bodyMap));

    debugPrint('📥 [EventScanService] update-status response: ${response.statusCode}, body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return UpdatePassStatusResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      String msg = 'Failed to update pass status (${response.statusCode})';
      try {
        final json = jsonDecode(response.body);
        if (json['message'] != null) {
          msg = json['message'].toString();
        } else if (json['error'] != null) {
          msg = json['error'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
