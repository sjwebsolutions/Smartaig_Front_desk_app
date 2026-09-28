import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  static const String currentAppVersion = '2.0.5';
  static const String appBundleId = 'com.smartaig.front.desk.app';

  static bool _hasDialogBeenShown = false;

  /// Checks for app updates. Uses official Google Play InAppUpdate on Android,
  /// and custom iTunes lookup + App Store dialog on iOS.
  static Future<void> checkForUpdates({bool isManualCheck = false}) async {
    if (_hasDialogBeenShown && !isManualCheck) return;

    if (Platform.isAndroid) {
      await _handleAndroidInAppUpdate(isManualCheck: isManualCheck);
    } else if (Platform.isIOS) {
      await _handleIosCustomUpdate(isManualCheck: isManualCheck);
    }
  }

  /// Android: Native Google Play In-App Update API (`in_app_update` package)
  static Future<void> _handleAndroidInAppUpdate({required bool isManualCheck}) async {
    try {
      debugPrint('🤖 [AppUpdateService] Checking Android In-App Update via Google Play API...');
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _hasDialogBeenShown = true;
        if (info.flexibleUpdateAllowed) {
          // Flexible Update: Shows native Play Store "Update / Not now" prompt
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        } else if (info.immediateUpdateAllowed) {
          // Immediate Update: High-priority update
          await InAppUpdate.performImmediateUpdate();
        } else {
          _showCustomUpdateDialog(
            storeVersion: 'Latest',
            updateUrl: 'https://play.google.com/store/apps/details?id=$appBundleId',
            isAndroid: true,
          );
        }
      } else if (info.updateAvailability == UpdateAvailability.developerTriggeredUpdateInProgress) {
        await InAppUpdate.completeFlexibleUpdate();
      } else if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    } catch (e) {
      debugPrint('⚠️ [InAppUpdate Android API Exception]: $e');
      // Fallback to custom Play Store version check if running non-Play Store build
      await _handleAndroidFallbackUpdate(isManualCheck: isManualCheck);
    }
  }

  /// Android Fallback (for side-loaded APKs or when Play Store API returns error)
  static Future<void> _handleAndroidFallbackUpdate({required bool isManualCheck}) async {
    try {
      final url = Uri.parse('https://play.google.com/store/apps/details?id=$appBundleId&hl=en');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final html = response.body;
        final regExp = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"\]\]');
        final match = regExp.firstMatch(html);
        if (match != null && match.groupCount >= 1) {
          final storeVersion = match.group(1);
          if (storeVersion != null && isVersionOlder(currentAppVersion, storeVersion)) {
            _hasDialogBeenShown = true;
            _showCustomUpdateDialog(
              storeVersion: storeVersion,
              updateUrl: 'https://play.google.com/store/apps/details?id=$appBundleId',
              isAndroid: true,
            );
            return;
          }
        }
      }
      if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    } catch (e) {
      debugPrint('⚠️ [Android Fallback Version Check Error]: $e');
      if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    }
  }

  /// iOS: Custom iTunes Lookup + Custom Modal Dialog
  static Future<void> _handleIosCustomUpdate({required bool isManualCheck}) async {
    try {
      debugPrint('🍎 [AppUpdateService] Checking iOS App Store Version via iTunes Lookup...');
      final url = Uri.parse('https://itunes.apple.com/lookup?bundleId=$appBundleId');
      final response = await http.get(url).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        final results = json['results'] as List<dynamic>?;

        if (results != null && results.isNotEmpty) {
          final firstResult = results.first as Map<String, dynamic>;
          final storeVersion = firstResult['version']?.toString();
          final trackUrl = firstResult['trackViewUrl']?.toString() ?? 'https://apps.apple.com';

          if (storeVersion != null && isVersionOlder(currentAppVersion, storeVersion)) {
            _hasDialogBeenShown = true;
            _showCustomUpdateDialog(
              storeVersion: storeVersion,
              updateUrl: trackUrl,
              isAndroid: false,
            );
            return;
          }
        }
      }

      if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    } catch (e) {
      debugPrint('⚠️ [iOS AppStore Lookup Error]: $e');
      if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    }
  }

  /// Compare semantic version numbers (e.g. "2.0.5" vs "2.0.6")
  static bool isVersionOlder(String currentVersion, String storeVersion) {
    try {
      List<int> currentParts = currentVersion
          .split('.')
          .map((e) => int.tryParse(RegExp(r'\d+').stringMatch(e) ?? '0') ?? 0)
          .toList();
      List<int> storeParts = storeVersion
          .split('.')
          .map((e) => int.tryParse(RegExp(r'\d+').stringMatch(e) ?? '0') ?? 0)
          .toList();

      int maxLength = currentParts.length > storeParts.length ? currentParts.length : storeParts.length;
      while (currentParts.length < maxLength) {
        currentParts.add(0);
      }
      while (storeParts.length < maxLength) {
        storeParts.add(0);
      }

      for (int i = 0; i < maxLength; i++) {
        if (storeParts[i] > currentParts[i]) return true;
        if (storeParts[i] < currentParts[i]) return false;
      }
    } catch (_) {}
    return false;
  }

  static void _showUpToDateSnackbar() {
    Get.snackbar(
      'Up to Date',
      'You are using the latest version of Front Desk App (v$currentAppVersion).',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF16A34A),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Shows the Custom Update Modal Dialog with modern UI
  static void _showCustomUpdateDialog({
    required String storeVersion,
    required String updateUrl,
    required bool isAndroid,
  }) {
    Get.dialog(
      PopScope(
        canPop: true,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Colors.white,
          child: Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Rocket / System Update Gradient Badge Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.rocket_launch_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),

                const SizedBox(height: 18),

                // Title
                Text(
                  'New Version Available!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 10),

                // Version Comparison Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'v$currentAppVersion',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF4F46E5)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(
                        'v$storeVersion',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Features Highlight Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome_rounded, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Text(
                            "What's New in this release:",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF334155),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '• New Admission Enquiries Module\n• Performance optimizations & bug fixes\n• Instant real-time notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Action Buttons: "Not Now" & "Update Now"
                Row(
                  children: [
                    // "Not Now" Button
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          'Not Now',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // "Update Now" Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Get.back();
                          final uri = Uri.parse(
                            isAndroid ? 'market://details?id=$appBundleId' : updateUrl,
                          );
                          try {
                            final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
                            if (!launched) {
                              final webUri = Uri.parse(updateUrl);
                              await launchUrl(webUri, mode: LaunchMode.externalApplication);
                            }
                          } catch (_) {
                            final webUri = Uri.parse(updateUrl);
                            try {
                              await launchUrl(webUri, mode: LaunchMode.externalApplication);
                            } catch (_) {}
                          }
                        },
                        icon: const Icon(Icons.download_rounded, size: 18, color: Colors.white),
                        label: Text(
                          'Update Now',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
