import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/student_image_store_model.dart';
import '../models/student_image_students_model.dart';
import '../utils/token_manager.dart';

class StudentImageStudentsService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/student-image-update-requests/students';
  static const String storeUrl = 'https://smartaig.com/api/v1/front-desk/student-image-update-requests/store';

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

  Future<StudentImageStoreResponseModel> submitStudentImageRequest({
    required dynamic studentId,
    dynamic profileImageFile,
    dynamic fatherImageFile,
    dynamic motherImageFile,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final uri = Uri.parse(storeUrl);

    debugPrint('🌐 [StudentImageStudentsService] POST Multipart request: $uri');

    final request = http.MultipartRequest('POST', uri);
    headers.forEach((key, value) {
      if (key.toLowerCase() != 'content-type') {
        request.headers[key] = value;
      }
    });

    request.fields['student_id'] = studentId.toString();

    if (profileImageFile != null) {
      final path = profileImageFile is String ? profileImageFile : profileImageFile.path;
      if (path != null && path.toString().isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('profile_image', path));
      }
    }

    if (fatherImageFile != null) {
      final path = fatherImageFile is String ? fatherImageFile : fatherImageFile.path;
      if (path != null && path.toString().isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('father_image', path));
      }
    }

    if (motherImageFile != null) {
      final path = motherImageFile is String ? motherImageFile : motherImageFile.path;
      if (path != null && path.toString().isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('mother_image', path));
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('📥 [StudentImageStudentsService] Response status: ${response.statusCode}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return StudentImageStoreResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to submit student image request'));
    }
  }
}
