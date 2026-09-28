import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/dashboard_model.dart';
import '../utils/token_manager.dart';

class DashboardService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/dashboard';

  Future<DashboardResponseModel> fetchDashboardData() async {
    final headers = await TokenManager.getAuthHeaders();
    debugPrint('🌐 [DashboardService] GET $baseUrl');
    debugPrint('🌐 [DashboardService] Headers: $headers');

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    debugPrint('📥 [DashboardService] Response Status: ${response.statusCode}');
    debugPrint('📥 [DashboardService] Response Body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return DashboardResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load dashboard data (${response.statusCode}): ${response.body}');
    }
  }
}
