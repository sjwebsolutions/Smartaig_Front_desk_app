import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gate_pass_model.dart';
import '../utils/token_manager.dart';

class GatePassService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/gate-passes';

  String _parseErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['message'] != null && json['message'].toString().isNotEmpty) {
        return json['message'].toString();
      }
    } catch (_) {}
    return '$fallbackMessage (${response.statusCode})';
  }

  Future<GatePassResponseModel> fetchGatePasses({String? status}) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty && status != 'all') {
      queryParams['status'] = status;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return GatePassResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load gate passes'));
    }
  }

  Future<ApproveGatePassResponseModel> approveGatePass(int id) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id/approve');

    try {
      final response = await http.post(
        url,
        headers: headers,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return ApproveGatePassResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await TokenManager.handleUnauthorized();
        throw Exception('Session expired (401). Please log in again.');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) rethrow;
    }

    // Fallback endpoint
    final urlFallback = Uri.parse('$baseUrl/approve');
    final responseFallback = await http.post(
      urlFallback,
      headers: headers,
      body: jsonEncode({'id': id}),
    );

    if (responseFallback.statusCode == 200 || responseFallback.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(responseFallback.body);
      return ApproveGatePassResponseModel.fromJson(jsonResponse);
    } else if (responseFallback.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(responseFallback, 'Failed to approve gate pass'));
    }
  }

  Future<RejectGatePassResponseModel> rejectGatePass(int id, {String? reason}) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id/reject');

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({if (reason != null && reason.isNotEmpty) 'reason': reason}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return RejectGatePassResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await TokenManager.handleUnauthorized();
        throw Exception('Session expired (401). Please log in again.');
      }
    } catch (e) {
      if (e.toString().contains('Session expired')) rethrow;
    }

    // Fallback endpoint
    final urlFallback = Uri.parse('$baseUrl/reject');
    final responseFallback = await http.post(
      urlFallback,
      headers: headers,
      body: jsonEncode({'id': id, if (reason != null && reason.isNotEmpty) 'reason': reason}),
    );

    if (responseFallback.statusCode == 200 || responseFallback.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(responseFallback.body);
      return RejectGatePassResponseModel.fromJson(jsonResponse);
    } else if (responseFallback.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(responseFallback, 'Failed to reject gate pass'));
    }
  }
}
