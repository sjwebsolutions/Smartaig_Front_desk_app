import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/student_image_classes_model.dart';
import '../utils/token_manager.dart';

class StudentImageClassesService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/student-image-update-requests/classes';

  String _parseErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['message'] != null && json['message'].toString().isNotEmpty) {
        return json['message'].toString();
      }
    } catch (_) {}
    return '$fallbackMessage (${response.statusCode})';
  }

  Future<StudentImageClassesResponseModel> fetchStudentImageClasses() async {
    final headers = await TokenManager.getAuthHeaders();
    final uri = Uri.parse(baseUrl);

    debugPrint('🌐 [StudentImageClassesService] GET request: $uri');

    final response = await http.get(
      uri,
      headers: headers,
    );

    debugPrint('📥 [StudentImageClassesService] Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return StudentImageClassesResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to fetch student image classes'));
    }
  }
}
