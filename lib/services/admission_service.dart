import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/admission_model.dart';
import '../utils/token_manager.dart';

class AdmissionService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/admission-enquiries';

  Future<AdmissionResponseModel> fetchAdmissionEnquiries({
    String? status,
    String? sessionYear,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (sessionYear != null && sessionYear.isNotEmpty && sessionYear != 'all') {
      queryParams['session_year'] = sessionYear;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return AdmissionResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load admission enquiries (${response.statusCode}): ${response.body}');
    }
  }

  Future<AdmissionDetailResponseModel> fetchAdmissionDetail(int id) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return AdmissionDetailResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load admission enquiry detail (${response.statusCode}): ${response.body}');
    }
  }

  Future<AddAdmissionFollowupResponseModel> addAdmissionFollowup({
    required int enquiryId,
    required String note,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$enquiryId/followups');

    final bodyMap = <String, dynamic>{
      'note': note,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return AddAdmissionFollowupResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to add follow-up note (${response.statusCode}): ${response.body}');
    }
  }

  Future<AdmissionClassResponseModel> fetchAdmissionClasses() async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/classes');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return AdmissionClassResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load admission classes (${response.statusCode}): ${response.body}');
    }
  }

  Future<AddAdmissionResponseModel> addAdmissionEnquiry({
    required String fullName,
    required String gender,
    required String fatherMobile,
    required String address,
    String? studentClassId,
    String? dob,
    String? aadhaarNo,
    String? fatherName,
    String? motherName,
    String? motherMobile,
    String? alternateContact,
    String? locality,
    String? city,
    String? state,
    String? pincode,
    String? category,
    String? religion,
    String? caste,
    String? previousSchool,
    String? lastClassAttended,
    String? reasonForLeaving,
    String? interestLevel,
    String? remarks,
    dynamic imageFile,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final uri = Uri.parse(baseUrl);

    final request = http.MultipartRequest('POST', uri);
    headers.forEach((key, value) {
      if (key.toLowerCase() != 'content-type') {
        request.headers[key] = value;
      }
    });

    request.fields['full_name'] = fullName;
    request.fields['gender'] = gender;
    request.fields['father_mobile'] = fatherMobile;
    request.fields['address'] = address;

    if (studentClassId != null && studentClassId.isNotEmpty) request.fields['student_class_id'] = studentClassId;
    if (dob != null && dob.isNotEmpty) request.fields['dob'] = dob;
    if (aadhaarNo != null && aadhaarNo.isNotEmpty) request.fields['aadhaar_no'] = aadhaarNo;
    if (fatherName != null && fatherName.isNotEmpty) request.fields['father_name'] = fatherName;
    if (motherName != null && motherName.isNotEmpty) request.fields['mother_name'] = motherName;
    if (motherMobile != null && motherMobile.isNotEmpty) request.fields['mother_mobile'] = motherMobile;
    if (alternateContact != null && alternateContact.isNotEmpty) request.fields['alternate_contact'] = alternateContact;
    if (locality != null && locality.isNotEmpty) request.fields['locality'] = locality;
    if (city != null && city.isNotEmpty) request.fields['city'] = city;
    if (state != null && state.isNotEmpty) request.fields['state'] = state;
    if (pincode != null && pincode.isNotEmpty) request.fields['pincode'] = pincode;
    if (category != null && category.isNotEmpty) request.fields['category'] = category;
    if (religion != null && religion.isNotEmpty) request.fields['religion'] = religion;
    if (caste != null && caste.isNotEmpty) request.fields['caste'] = caste;
    if (previousSchool != null && previousSchool.isNotEmpty) request.fields['previous_school'] = previousSchool;
    if (lastClassAttended != null && lastClassAttended.isNotEmpty) request.fields['last_class_attended'] = lastClassAttended;
    if (reasonForLeaving != null && reasonForLeaving.isNotEmpty) request.fields['reason_for_leaving'] = reasonForLeaving;
    if (interestLevel != null && interestLevel.isNotEmpty) request.fields['interest_level'] = interestLevel;
    if (remarks != null && remarks.isNotEmpty) request.fields['remarks'] = remarks;

    if (imageFile != null) {
      final path = imageFile is String ? imageFile : imageFile.path;
      request.files.add(await http.MultipartFile.fromPath('student_image', path));
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return AddAdmissionResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      String msg = 'Failed to register admission enquiry (${response.statusCode})';
      try {
        final Map<String, dynamic> errJson = jsonDecode(response.body);
        if (errJson['message'] != null) {
          msg = errJson['message'].toString();
        }
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
