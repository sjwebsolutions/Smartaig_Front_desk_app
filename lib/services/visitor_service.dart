import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/visitor_model.dart';
import '../utils/token_manager.dart';

class VisitorService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/visitors';

  Future<VisitorResponseModel> fetchVisitors({String? date}) async {
    final headers = await TokenManager.getAuthHeaders();

    final queryParams = <String, String>{};
    if (date != null && date.isNotEmpty) {
      queryParams['date'] = date;
    }

    final uri = Uri.parse(baseUrl).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    final response = await http.get(
      uri,
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return VisitorResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load visitors (${response.statusCode}): ${response.body}');
    }
  }
}
