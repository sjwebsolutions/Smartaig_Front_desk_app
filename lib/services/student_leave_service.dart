import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_leave_model.dart';
import '../utils/token_manager.dart';

class StudentLeaveService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/student-leaves';

  String _parseErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['message'] != null && json['message'].toString().isNotEmpty) {
        return json['message'].toString();
      }
    } catch (_) {}
    return '$fallbackMessage (${response.statusCode})';
  }

  Future<StudentLeaveResponseModel> fetchStudentLeaves({
    String? status,
    String? date,
    String? studentClassId,
    String? studentSectionId,
    String? studentStreamId,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }
    if (studentClassId != null && studentClassId.isNotEmpty) {
      queryParams['student_class_id'] = studentClassId;
    }
    if (studentSectionId != null && studentSectionId.isNotEmpty) {
      queryParams['student_section_id'] = studentSectionId;
    }
    if (studentStreamId != null && studentStreamId.isNotEmpty) {
      queryParams['student_stream_id'] = studentStreamId;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return StudentLeaveResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load student leaves'));
    }
  }

  Future<ActionStudentLeaveResponseModel> approveStudentLeave(
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

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ActionStudentLeaveResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to approve student leave'));
    }
  }

  Future<ActionStudentLeaveResponseModel> rejectStudentLeave(
    int id, {
    required String reason,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id/reject');

    final bodyMap = <String, dynamic>{
      'rejection_reason': reason,
      'reason': reason,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ActionStudentLeaveResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to reject student leave'));
    }
  }
}
