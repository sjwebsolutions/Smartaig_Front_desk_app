import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/policies_model.dart';
import '../utils/token_manager.dart';

class PoliciesService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/policies';

  Future<PoliciesResponseModel> fetchPolicies() async {
    final headers = await TokenManager.getAuthHeaders();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      return PoliciesResponseModel.fromJson(jsonResponse);
    } else if (response.statusCode == 401) {
      await TokenManager.handleUnauthorized();
      throw Exception('Session expired (401). Please log in again.');
    } else {
      throw Exception('Failed to load policies (${response.statusCode}): ${response.body}');
    }
  }
}
