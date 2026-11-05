import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/active_event_model.dart';
import '../utils/token_manager.dart';

class ActiveEventService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/events/active';

  Future<ActiveEventResponseModel> fetchActiveEvents() async {
    final headers = await TokenManager.getAuthHeaders();
    final uri = Uri.parse(baseUrl);

    debugPrint('🌐 [ActiveEventService] GET request: $uri');

    final response = await http.get(uri, headers: headers);

    debugPrint('📥 [ActiveEventService] Response status: ${response.statusCode}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return ActiveEventResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load active events (${response.statusCode}): ${response.body}');
    }
  }
}
