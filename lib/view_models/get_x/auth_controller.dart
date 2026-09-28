import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/auth_modle.dart';
import '../../services/auth_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/token_manager.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var token = ''.obs;

  Future<bool> sendOtp({
    required String whatsappNumber,
    required String deviceUuid,
    required String deviceName,
    required String deviceOs,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';
    
    try {
      debugPrint('🚀 [AuthController] Fetching FCM device token for requestOtp...');
      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getDeviceToken();
        debugPrint('🔥 [AuthController] FCM Token: $fcmToken');
      } catch (fcmErr, fcmStack) {
        debugPrint('❌ [Firebase Error in AuthController sendOtp]: $fcmErr\n$fcmStack');
      }

      final request = OtpRequestModel(
        whatsappNumber: whatsappNumber,
        deviceUuid: deviceUuid,
        deviceName: deviceName,
        deviceOs: deviceOs,
        fcmToken: fcmToken,
      );

      debugPrint('📤 [AuthController sendOtp] Sending OTP request for $whatsappNumber');
      final response = await _authService.requestOtp(request);
      debugPrint('📥 [AuthController sendOtp] Response success=${response.success}, msg=${response.message}');
      
      if (response.success == true) {
        AppSnackbar.showSuccess(
          title: 'OTP Sent Successfully',
          message: response.message ?? 'A 6-digit OTP code has been sent to your WhatsApp number.',
        );
        return true;
      } else {
        final rawMsg = response.message?.trim() ?? '';
        final lowerMsg = rawMsg.toLowerCase();
        
        final isUnregistered = lowerMsg.contains('not register') ||
            lowerMsg.contains('not found') ||
            lowerMsg.contains('unregister') ||
            lowerMsg.contains('does not exist') ||
            lowerMsg.contains('no staff') ||
            lowerMsg.contains('no user') ||
            lowerMsg.contains('record not found');

        final title = isUnregistered ? 'Number Not Registered' : 'OTP Request Failed';
        final displayMsg = rawMsg.isNotEmpty
            ? rawMsg
            : 'This mobile number is not registered with any school. Please contact admin.';

        errorMessage.value = displayMsg;
        AppSnackbar.showError(
          title: title,
          message: displayMsg,
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint('❌ [AuthController sendOtp Exception]: $e\n$stack');
      errorMessage.value = AppErrorFormatter.format(e, defaultMessage: 'Unable to connect to server. Please check your internet connection.');
      AppSnackbar.showError(
        title: AppErrorFormatter.getTitle(e, defaultTitle: 'Connection Error'),
        message: errorMessage.value,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyOtp({
    required String whatsappNumber,
    required String otpCode,
    required String deviceUuid,
    required String deviceName,
    required String deviceOs,
  }) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      debugPrint('🚀 [AuthController] Fetching FCM device token for verifyOtp...');
      String? fcmToken;
      try {
        fcmToken = await NotificationService.instance.getDeviceToken();
        debugPrint('🔥 [AuthController] FCM Token: $fcmToken');
      } catch (fcmErr, fcmStack) {
        debugPrint('❌ [Firebase Error in AuthController verifyOtp]: $fcmErr\n$fcmStack');
      }

      final request = VerifyOtpRequestModel(
        whatsappNumber: whatsappNumber,
        otpCode: otpCode,
        deviceUuid: deviceUuid,
        deviceName: deviceName,
        deviceOs: deviceOs,
        fcmToken: fcmToken,
      );

      debugPrint('📤 [AuthController verifyOtp] Verifying OTP code for $whatsappNumber');
      final response = await _authService.verifyOtp(request);
      debugPrint('📥 [AuthController verifyOtp] Response success=${response.success}, token=${response.data?.token}');

      final extractedToken = response.data?.token;

      if (response.success == true || (extractedToken != null && extractedToken.isNotEmpty)) {
        if (extractedToken != null && extractedToken.isNotEmpty) {
          token.value = extractedToken;
          await TokenManager.saveToken(extractedToken);
          debugPrint('🔑 [AuthController verifyOtp] Token saved successfully');
        } else {
          debugPrint('⚠️ [AuthController verifyOtp] Warning: Verify OTP succeeded but token was empty');
        }
        AppSnackbar.showSuccess(
          title: 'Login Successful',
          message: response.message ?? 'Welcome to Smart AIG Front Desk!',
        );
        return true;
      } else {
        final rawMsg = response.message?.trim() ?? '';
        final lowerMsg = rawMsg.toLowerCase();

        final isInvalidOtp = lowerMsg.contains('invalid') ||
            lowerMsg.contains('incorrect') ||
            lowerMsg.contains('wrong') ||
            lowerMsg.contains('expired') ||
            lowerMsg.contains('mismatch') ||
            lowerMsg.contains('otp');

        final title = isInvalidOtp ? 'Invalid OTP' : 'Verification Failed';
        final displayMsg = rawMsg.isNotEmpty
            ? rawMsg
            : 'The OTP entered is incorrect or expired. Please try again.';

        errorMessage.value = displayMsg;
        AppSnackbar.showError(
          title: title,
          message: displayMsg,
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint('❌ [AuthController verifyOtp Exception]: $e\n$stack');
      errorMessage.value = AppErrorFormatter.format(e, defaultMessage: 'Unable to complete verification. Please check your network and try again.');
      AppSnackbar.showError(
        title: AppErrorFormatter.getTitle(e, defaultTitle: 'Verification Error'),
        message: errorMessage.value,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
