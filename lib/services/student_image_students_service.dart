import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/student_image_students_model.dart';
import '../utils/token_manager.dart';

class StudentImageStudentsService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/student-image-update-requests/students';

  String _parseErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['message'] != null && json['message'].toString().isNotEmpty) {
        return json['message'].toString();
      }
    } catch (_) {}
    return '$fallbackMessage (${response.statusCode})';
  }

  Future<StudentImageStudentsResponseModel> fetchStudents({
    required dynamic classId,
    dynamic sectionId,
    dynamic streamId,
    String? search,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (classId != null) {
      queryParams['class_id'] = classId.toString();
    }
    if (sectionId != null) {
      queryParams['section_id'] = sectionId.toString();
    }
    if (streamId != null) {
      queryParams['stream_id'] = streamId.toString();
    }
    if (search != null && search.trim().isNotEmpty) {
      queryParams['search'] = search.trim();
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    debugPrint('🌐 [StudentImageStudentsService] GET request: $uri');

    final response = await http.get(
      uri,
      headers: headers,
    );

    debugPrint('📥 [StudentImageStudentsService] Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return StudentImageStudentsResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to fetch students list'));
    }
  }
}
