import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/teacher_leave_model.dart';
import '../utils/token_manager.dart';

class TeacherLeaveService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/teacher-leaves';

  String _parseErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['message'] != null && json['message'].toString().isNotEmpty) {
        return json['message'].toString();
      }
    } catch (_) {}
    return '$fallbackMessage (${response.statusCode})';
  }

  Future<TeacherLeaveResponseModel> fetchTeacherLeaves({
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

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return TeacherLeaveResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load teacher leaves'));
    }
  }

  Future<ActionTeacherLeaveResponseModel> approveTeacherLeave(
    int id, {
    String? remarks,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id/approve');

    final bodyMap = <String, dynamic>{};
    if (remarks != null && remarks.isNotEmpty) {
      bodyMap['approver_remarks'] = remarks;
      bodyMap['remarks'] = remarks;
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ActionTeacherLeaveResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await TokenManager.handleUnauthorized();
        throw Exception('Session expired (401). Please log in again.');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) rethrow;
    }

    // Fallback: in case endpoint accepts {id, approver_remarks} at root /approve
    final fallbackUrl = Uri.parse('$baseUrl/approve');
    final fallbackBody = <String, dynamic>{
      'id': id,
      if (remarks != null && remarks.isNotEmpty) 'approver_remarks': remarks,
      if (remarks != null && remarks.isNotEmpty) 'remarks': remarks,
    };

    final fallbackResponse = await http.post(
      fallbackUrl,
      headers: headers,
      body: jsonEncode(fallbackBody),
    );

    if (fallbackResponse.statusCode == 200 || fallbackResponse.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(fallbackResponse.body);
      return ActionTeacherLeaveResponseModel.fromJson(jsonResponse);
    } else if (fallbackResponse.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(fallbackResponse, 'Failed to approve teacher leave'));
    }
  }

  Future<ActionTeacherLeaveResponseModel> rejectTeacherLeave(
    int id, {
    required String reason,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id/reject');

    final bodyMap = <String, dynamic>{
      'rejection_reason': reason,
      'reason': reason,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ActionTeacherLeaveResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await TokenManager.handleUnauthorized();
        throw Exception('Session expired (401). Please log in again.');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) rethrow;
    }

    // Fallback: in case endpoint accepts {id, rejection_reason} at root /reject
    final fallbackUrl = Uri.parse('$baseUrl/reject');
    final fallbackBody = <String, dynamic>{
      'id': id,
      'rejection_reason': reason,
      'reason': reason,
    };

    final fallbackResponse = await http.post(
      fallbackUrl,
      headers: headers,
      body: jsonEncode(fallbackBody),
    );

    if (fallbackResponse.statusCode == 200 || fallbackResponse.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(fallbackResponse.body);
      return ActionTeacherLeaveResponseModel.fromJson(jsonResponse);
    } else if (fallbackResponse.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(fallbackResponse, 'Failed to reject teacher leave'));
    }
  }
}
