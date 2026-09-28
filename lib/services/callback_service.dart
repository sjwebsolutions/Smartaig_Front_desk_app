import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/callback_model.dart';
import '../utils/token_manager.dart';

class CallbackService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/callback-requests';

  Future<CallbackResponseModel> fetchCallbackRequests({
    String? status,
    String? date,
    int page = 1,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }
    queryParams['page'] = page.toString();

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return CallbackResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load callback requests (${response.statusCode}): ${response.body}');
    }
  }

  Future<CallbackDetailResponseModel> fetchCallbackDetail(int id) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return CallbackDetailResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load callback request detail (${response.statusCode}): ${response.body}');
    }
  }

  Future<StoreCallbackNoteResponseModel> storeCallbackNote({
    required int callbackId,
    required String notes,
    String? callStatus,
    String? updateStatusTo,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$callbackId/notes');

    final bodyMap = <String, dynamic>{
      'notes': notes,
      if (callStatus != null && callStatus.isNotEmpty) 'call_status': callStatus,
      if (updateStatusTo != null && updateStatusTo.isNotEmpty) 'update_status_to': updateStatusTo,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return StoreCallbackNoteResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to store callback note (${response.statusCode}): ${response.body}');
    }
  }

  Future<UpdateCallbackStatusResponseModel> updateCallbackStatus({
    required int callbackId,
    required String status,
    String? notes,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$callbackId/status');

    final bodyMap = <String, dynamic>{
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(bodyMap),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return UpdateCallbackStatusResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await TokenManager.handleUnauthorized();
        throw Exception('Session expired (401). Please log in again.');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) rethrow;
    }

    // Fallback endpoint
    final urlFallback = Uri.parse('$baseUrl/change-status');
    final bodyFallback = <String, dynamic>{
      'id': callbackId,
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };

    final resFallback = await http.post(
      urlFallback,
      headers: headers,
      body: jsonEncode(bodyFallback),
    );

    if (resFallback.statusCode == 200 || resFallback.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(resFallback.body);
      return UpdateCallbackStatusResponseModel.fromJson(jsonResponse);
    } else if (resFallback.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to update callback status (${resFallback.statusCode}): ${resFallback.body}');
    }
  }
}
