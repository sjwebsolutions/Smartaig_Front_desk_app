import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/transport_alert_model.dart';
import '../models/transport_halt_model.dart';
import '../models/transport_live_overview_model.dart';
import '../models/transport_location_request_model.dart';
import '../utils/token_manager.dart';

class TransportService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/transport/location-requests';
  static const String liveOverviewUrl = 'https://smartaig.com/api/v1/front-desk/transport/live-overview';
  static const String haltsUrl = 'https://smartaig.com/api/v1/front-desk/transport/halts';
  static const String alertsUrl = 'https://smartaig.com/api/v1/front-desk/transport/alerts';

  String _parseErrorMessage(http.Response response, String fallbackMessage) {
    try {
      final Map<String, dynamic> json = jsonDecode(response.body);
      if (json['message'] != null && json['message'].toString().isNotEmpty) {
        return json['message'].toString();
      }
    } catch (_) {}
    return '$fallbackMessage (${response.statusCode})';
  }

  Future<TransportLocationRequestsResponseModel> fetchLocationRequests({
    String? status,
    int? page,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    if (page != null && page > 0) {
      queryParams['page'] = page.toString();
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return TransportLocationRequestsResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load transport location requests'));
    }
  }

  Future<TransportLocationRequestDetailResponseModel> fetchLocationRequestDetail(int id) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id');

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return TransportLocationRequestDetailResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load transport request detail'));
    }
  }

  Future<ActionTransportLocationResponseModel> approveLocationRequest(
    int id, {
    String? remarks,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id/approve');

    final bodyMap = <String, dynamic>{};
    if (remarks != null && remarks.isNotEmpty) {
      bodyMap['remarks'] = remarks;
    }

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ActionTransportLocationResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to approve transport location request'));
    }
  }

  Future<ActionTransportLocationResponseModel> rejectLocationRequest(
    int id, {
    String? reason,
  }) async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse('$baseUrl/$id/reject');

    final rejectionReason = (reason != null && reason.trim().isNotEmpty)
        ? reason.trim()
        : 'Proposed location pin is outside bus route boundary.';

    final bodyMap = <String, dynamic>{
      'rejection_reason': rejectionReason,
      'reason': rejectionReason,
    };

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ActionTransportLocationResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to reject transport location request'));
    }
  }

  Future<TransportLiveOverviewResponseModel> fetchLiveOverview() async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse(liveOverviewUrl);

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return TransportLiveOverviewResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load live transport overview'));
    }
  }

  Future<TransportHaltResponseModel> fetchTransportHalts() async {
    final headers = await TokenManager.getAuthHeaders();
    final url = Uri.parse(haltsUrl);

    final response = await http.get(
      url,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return TransportHaltResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load transport halts'));
    }
  }

  Future<TransportAlertResponseModel> fetchTransportAlerts({String? isResolved}) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (isResolved != null && isResolved.isNotEmpty) {
      queryParams['is_resolved'] = isResolved;
    }

    final uri = Uri.parse(alertsUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return TransportAlertResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception(_parseErrorMessage(response, 'Failed to load transport alerts'));
    }
  }
}
