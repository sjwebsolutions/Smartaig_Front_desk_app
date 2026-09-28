import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/auth_modle.dart';

class AuthService {
  static const String baseUrl = 'https://smartaig.com/api/v1/front-desk/auth';

  Future<OtpResponseModel> requestOtp(OtpRequestModel requestModel) async {
    final url = '$baseUrl/otp/request';
    debugPrint('🌐 [AuthService] POST $url');
    debugPrint('📤 [AuthService] Body: ${jsonEncode(requestModel.toJson())}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      debugPrint('📥 [AuthService] Response (${response.statusCode}): ${response.body}');
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return OtpResponseModel.fromJson(decoded);
      }
      return OtpResponseModel(
        success: false,
        message: 'Invalid response format from server.',
      );
    } catch (e, stack) {
      debugPrint('❌ [AuthService requestOtp Exception]: $e\n$stack');
      if (e is FormatException) {
        return OtpResponseModel(
          success: false,
          message: 'Server error: Invalid response format',
        );
      }
      rethrow;
    }
  }

  Future<VerifyOtpResponseModel> verifyOtp(VerifyOtpRequestModel requestModel) async {
    final url = '$baseUrl/otp/verify';
    debugPrint('🌐 [AuthService] POST $url');
    debugPrint('📤 [AuthService] Body: ${jsonEncode(requestModel.toJson())}');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(requestModel.toJson()),
      );

      debugPrint('📥 [AuthService] Response (${response.statusCode}): ${response.body}');
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return VerifyOtpResponseModel.fromJson(decoded);
      }
      return VerifyOtpResponseModel(
        success: false,
        message: 'Invalid response format from server.',
      );
    } catch (e, stack) {
      debugPrint('❌ [AuthService verifyOtp Exception]: $e\n$stack');
      if (e is FormatException) {
        return VerifyOtpResponseModel(
          success: false,
          message: 'Server error: Invalid response format',
        );
      }
      rethrow;
    }
  }
}
