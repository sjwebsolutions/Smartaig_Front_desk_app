import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class AppUpdateService {
  static String currentAppVersion = '2.0.8';
  static String appBundleId = 'com.smartaig.front.desk.app';

  static bool _hasDialogBeenShown = false;
  static bool _isChecking = false;

  /// Initializes app version and package name dynamically from the device
  static Future<void> initPackageInfo() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty && info.version != '1.0.0') {
        currentAppVersion = info.version;
      }
      if (info.packageName.isNotEmpty) {
        appBundleId = info.packageName;
      }
      debugPrint('📱 [AppUpdateService] Running version: v$currentAppVersion ($appBundleId)');
    } catch (e) {
      debugPrint('⚠️ [AppUpdateService] initPackageInfo fallback: $e');
    }
  }

  /// Checks for app updates.
  /// Works in the background on app open / dashboard load for both iOS and Android.
  static Future<void> checkForUpdates({bool isManualCheck = false}) async {
    if (_isChecking) return;
    if (_hasDialogBeenShown && !isManualCheck) return;

    // Do not pop up automatic update dialogs during debug / local development
    if (kDebugMode && !isManualCheck) {
      debugPrint('ℹ️ [AppUpdateService] Skipping automatic update check in debug mode.');
      return;
    }

    _isChecking = true;
    try {
      await initPackageInfo();

      if (Platform.isAndroid) {
        await _handleAndroidUpdate(isManualCheck: isManualCheck);
      } else if (Platform.isIOS) {
        await _handleIosUpdate(isManualCheck: isManualCheck);
      }
    } catch (e) {
      debugPrint('⚠️ [AppUpdateService] General checkForUpdates error: $e');
      if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    } finally {
      _isChecking = false;
    }
  }

  /// Android Update Checker (Uses Google Play In-App Update API + Play Store Web scraping fallback)
  static Future<void> _handleAndroidUpdate({required bool isManualCheck}) async {
    debugPrint('🤖 [AppUpdateService] Checking Android updates for $appBundleId (current: v$currentAppVersion)...');
    
    // 1. Try Google Play In-App Update API
    try {
      final AppUpdateInfo info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        _hasDialogBeenShown = true;
        _showCustomUpdateDialog(
          storeVersion: 'Latest',
          updateUrl: 'https://play.google.com/store/apps/details?id=$appBundleId',
          isAndroid: true,
          inAppUpdateInfo: info,
        );
        return;
      }
    } catch (e) {
      debugPrint('ℹ️ [InAppUpdate API not available or sideloaded build]: $e');
    }

    // 2. Play Store HTML details fallback
    try {
      final url = Uri.parse('https://play.google.com/store/apps/details?id=$appBundleId&hl=en');
      final response = await http.get(url, headers: {
        'User-Agent': 'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36',
      }).timeout(const Duration(seconds: 6));

      if (response.statusCode == 200) {
        final html = response.body;
        String? storeVersion;

        // Try various Play Store regex matchers
        final regExp1 = RegExp(r'\[\[\["(\d+\.\d+\.\d+)"\]\]');
        final match1 = regExp1.firstMatch(html);
        if (match1 != null && match1.groupCount >= 1) {
          storeVersion = match1.group(1);
        }

        if (storeVersion == null) {
          final regExp2 = RegExp(r'\["(\d+\.\d+\.\d+)"\]');
          final match2 = regExp2.firstMatch(html);
          if (match2 != null && match2.groupCount >= 1) {
            storeVersion = match2.group(1);
          }
        }

        if (storeVersion == null) {
          final regExp3 = RegExp(r'Current Version.*?(\d+\.\d+\.\d+)', dotAll: true);
          final match3 = regExp3.firstMatch(html);
          if (match3 != null && match3.groupCount >= 1) {
            storeVersion = match3.group(1);
          }
        }

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
    } catch (e) {
      debugPrint('⚠️ [Android Play Store Fallback Error]: $e');
    }

    if (isManualCheck) {
      _showUpToDateSnackbar();
    }
  }

  /// iOS Update Checker (Uses iTunes Lookup API with region fallback)
  static Future<void> _handleIosUpdate({required bool isManualCheck}) async {
    debugPrint('🍎 [AppUpdateService] Checking iOS App Store updates for $appBundleId (current: v$currentAppVersion)...');
    try {
      // 1. Check primary iTunes lookup
      var url = Uri.parse('https://itunes.apple.com/lookup?bundleId=$appBundleId');
      var response = await http.get(url).timeout(const Duration(seconds: 6));

      Map<String, dynamic> json = {};
      List<dynamic>? results;

      if (response.statusCode == 200) {
        json = jsonDecode(response.body);
        results = json['results'] as List<dynamic>?;
      }

      // 2. Region fallback (India store)
      if (results == null || results.isEmpty) {
        url = Uri.parse('https://itunes.apple.com/lookup?bundleId=$appBundleId&country=in');
        response = await http.get(url).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          json = jsonDecode(response.body);
          results = json['results'] as List<dynamic>?;
        }
      }

      // 3. Region fallback (US store)
      if (results == null || results.isEmpty) {
        url = Uri.parse('https://itunes.apple.com/lookup?bundleId=$appBundleId&country=us');
        response = await http.get(url).timeout(const Duration(seconds: 6));
        if (response.statusCode == 200) {
          json = jsonDecode(response.body);
          results = json['results'] as List<dynamic>?;
        }
      }

      if (results != null && results.isNotEmpty) {
        final firstResult = results.first as Map<String, dynamic>;
        final storeVersion = firstResult['version']?.toString();
        final trackUrl = firstResult['trackViewUrl']?.toString() ?? 'https://apps.apple.com';
        final releaseNotes = firstResult['releaseNotes']?.toString();

        if (storeVersion != null && isVersionOlder(currentAppVersion, storeVersion)) {
          _hasDialogBeenShown = true;
          _showCustomUpdateDialog(
            storeVersion: storeVersion,
            updateUrl: trackUrl,
            isAndroid: false,
            releaseNotes: releaseNotes,
          );
          return;
        }
      }

      if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    } catch (e) {
      debugPrint('⚠️ [iOS App Store Lookup Error]: $e');
      if (isManualCheck) {
        _showUpToDateSnackbar();
      }
    }
  }

  /// Compares semantic versions (e.g. "2.0.8" vs "2.0.9", "2.1.0", "3.0.0")
  static bool isVersionOlder(String currentVersion, String storeVersion) {
    try {
      final cleanCurrent = currentVersion.split('+').first.replaceAll(RegExp(r'[^\d.]'), '');
      final cleanStore = storeVersion.split('+').first.replaceAll(RegExp(r'[^\d.]'), '');

      List<int> currentParts = cleanCurrent
          .split('.')
          .where((s) => s.isNotEmpty)
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      List<int> storeParts = cleanStore
          .split('.')
          .where((s) => s.isNotEmpty)
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      int maxLength = currentParts.length > storeParts.length
          ? currentParts.length
          : storeParts.length;

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
    } catch (e) {
      debugPrint('⚠️ [isVersionOlder Error]: $e');
    }
    return false;
  }

  /// Shows friendly snackbar if already on the latest version
  static void _showUpToDateSnackbar() {
    if (Get.isSnackbarOpen) return;
    Get.snackbar(
      'App is Up to Date',
      'You are already using the latest version of Front Desk App ($currentAppVersion).',
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFF10B981),
      colorText: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      borderRadius: 14,
      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 28),
      duration: const Duration(seconds: 3),
      boxShadows: [
        BoxShadow(
          color: const Color(0xFF10B981).withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  /// Launches the App Store or Google Play Store for updating
  static Future<void> launchAppStore({
    required bool isAndroid,
    required String updateUrl,
    AppUpdateInfo? inAppUpdateInfo,
  }) async {
    // If Android Flexible / Immediate Update is supported
    if (isAndroid && inAppUpdateInfo != null) {
      try {
        if (inAppUpdateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
          return;
        } else if (inAppUpdateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
          return;
        }
      } catch (e) {
        debugPrint('⚠️ InAppUpdate direct trigger fallback to Play Store url: $e');
      }
    }

    if (isAndroid) {
      final marketUri = Uri.parse('market://details?id=$appBundleId');
      final webUri = Uri.parse('https://play.google.com/store/apps/details?id=$appBundleId');

      try {
        final launched = await launchUrl(marketUri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        try {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('⚠️ Error launching Android Play Store: $e');
        }
      }
    } else {
      // iOS
      final storeLink = updateUrl.isNotEmpty ? updateUrl : 'https://apps.apple.com/app/id$appBundleId';
      final itmsUri = Uri.parse(storeLink.replaceFirst('https://', 'itms-apps://'));
      final webUri = Uri.parse(storeLink);

      try {
        final launched = await launchUrl(itmsUri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        }
      } catch (_) {
        try {
          await launchUrl(webUri, mode: LaunchMode.externalApplication);
        } catch (e) {
          debugPrint('⚠️ Error launching iOS App Store: $e');
        }
      }
    }
  }

  /// Displays the Premium Update Dialog on the Dashboard
  static void _showCustomUpdateDialog({
    required String storeVersion,
    required String updateUrl,
    required bool isAndroid,
    String? releaseNotes,
    AppUpdateInfo? inAppUpdateInfo,
  }) {
    if (Get.isDialogOpen == true) return;

    Get.dialog(
      PopScope(
        canPop: true,
        child: Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 16,
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E1B4B).withValues(alpha: 0.18),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Gradient Header with Badge & Illustration
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 26, 20, 20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF4338CA), // Deep Indigo
                          Color(0xFF6366F1), // Indigo
                          Color(0xFF8B5CF6), // Purple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Floating Glowing Circle Icon
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.15),
                              ),
                            ),
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.rocket_launch_rounded,
                                  color: Color(0xFF4F46E5),
                                  size: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Pill Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFFFDE047), size: 14),
                              const SizedBox(width: 5),
                              Text(
                                isAndroid ? 'GOOGLE PLAY UPDATE' : 'APP STORE UPDATE',
                                style: GoogleFonts.poppins(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.1,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Title
                        Text(
                          'New Version Available!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Body Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Version Switcher Row (Current -> Latest)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Installed Version
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Installed',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      currentAppVersion.replaceAll(RegExp(r'^[vV]'), ''),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Arrow
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEEF2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 16,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),

                              // New Version
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Latest',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF16A34A),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFDCFCE7),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'NEW',
                                          style: GoogleFonts.poppins(
                                            fontSize: 8.5,
                                            fontWeight: FontWeight.w800,
                                            color: const Color(0xFF15803D),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFC7D2FE)),
                                    ),
                                    child: Text(
                                      storeVersion == 'Latest'
                                          ? 'Latest Build'
                                          : storeVersion.replaceAll(RegExp(r'^[vV]'), ''),
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Release Highlights Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9).withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: Color(0xFFF59E0B), size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    "What's New in this update:",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              if (releaseNotes != null && releaseNotes.trim().isNotEmpty) ...[
                                Text(
                                  releaseNotes.trim(),
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                    height: 1.4,
                                  ),
                                ),
                              ] else ...[
                                _buildHighlightRow(Icons.bolt_rounded, 'Performance enhancements & speed boosts'),
                                _buildHighlightRow(Icons.security_rounded, 'Latest bug fixes & security improvements'),
                                _buildHighlightRow(Icons.touch_app_rounded, 'Refined UI & seamless user experience'),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Two Action Buttons: "Cancel" & "Update"
                        Row(
                          children: [
                            // 1. Cancel Button
                            Expanded(
                              flex: 4,
                              child: OutlinedButton(
                                onPressed: () {
                                  Get.back();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 13),
                                  backgroundColor: Colors.white,
                                ),
                                child: Text(
                                  'Cancel',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // 2. Update Button
                            Expanded(
                              flex: 6,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF4F46E5),
                                      Color(0xFF7C3AED),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    Get.back();
                                    await launchAppStore(
                                      isAndroid: isAndroid,
                                      updateUrl: updateUrl,
                                      inAppUpdateInfo: inAppUpdateInfo,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.download_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Update',
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 13),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
    );
  }

  static Widget _buildHighlightRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: const Color(0xFF64748B),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
