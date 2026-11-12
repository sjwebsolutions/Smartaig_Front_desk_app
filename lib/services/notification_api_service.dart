import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/token_manager.dart';

class NotificationApiService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/notifications';

  /// Fetches notifications list from backend API
  Future<NotificationResponseModel> fetchNotifications({
    int page = 1,
    String? module,
  }) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    queryParams['page'] = page.toString();
    if (module != null && module.isNotEmpty && module != 'all') {
      queryParams['module'] = module;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams);
    debugPrint('🌐 [NotificationApiService] GET $uri');

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        return NotificationResponseModel.fromJson(jsonResponse);
      } else if (response.statusCode == 401) {
        await TokenManager.handleUnauthorized();
        throw Exception('Session expired (401). Please log in again.');
      } else {
        throw Exception(
          'Failed to load notifications (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('❌ [NotificationApiService Error]: $e');
      rethrow;
    }
  }
}
