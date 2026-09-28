import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSnackbar {
  /// Show a vibrant green success snackbar
  static void showSuccess({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF16A34A), // Vibrant Green
      icon: const Padding(
        padding: EdgeInsets.only(left: 12.0, right: 6.0),
        child: Icon(Icons.check_circle_rounded, color: Colors.white, size: 24),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration,
      animationDuration: const Duration(milliseconds: 600),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
    );
  }

  /// Show a red error snackbar
  static void showError({
    required String title,
    required String message,
    Duration duration = const Duration(seconds: 4),
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.rawSnackbar(
      titleText: Text(
        title,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: Colors.white,
        ),
      ),
      messageText: Text(
        message,
        style: GoogleFonts.poppins(
          fontWeight: FontWeight.normal,
          fontSize: 12,
          color: Colors.white,
        ),
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFDC2626), // Vibrant Red
      icon: const Padding(
        padding: EdgeInsets.only(left: 12.0, right: 6.0),
        child: Icon(Icons.error_outline_rounded, color: Colors.white, size: 24),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      duration: duration,
      animationDuration: const Duration(milliseconds: 600),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      snackStyle: SnackStyle.FLOATING,
      isDismissible: true,
    );
  }
}
