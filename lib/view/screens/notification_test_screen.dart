import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/notification_service.dart';
import '../../utils/app_snackbar.dart';

class NotificationTestScreen extends StatefulWidget {
  const NotificationTestScreen({super.key});

  @override
  State<NotificationTestScreen> createState() => _NotificationTestScreenState();
}

class _NotificationTestScreenState extends State<NotificationTestScreen> {
  String? _fcmToken;
  bool _isLoadingToken = false;
  String _permissionStatus = 'Checking...';
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionAndToken();
  }

  Future<void> _checkPermissionAndToken() async {
    setState(() {
      _isLoadingToken = true;
    });

    try {
      final settings = await FirebaseMessaging.instance.getNotificationSettings();
      setState(() {
        _permissionStatus = settings.authorizationStatus.name.toUpperCase();
        _isPermissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;
      });

      final token = await NotificationService.instance.getDeviceToken();
      setState(() {
        _fcmToken = token;
      });
    } catch (e) {
      setState(() {
        _fcmToken = 'Error fetching token: $e';
      });
    } finally {
      setState(() {
        _isLoadingToken = false;
      });
    }
  }

  void _copyTokenToClipboard() {
    if (_fcmToken != null && _fcmToken!.isNotEmpty && !_fcmToken!.startsWith('Error')) {
      Clipboard.setData(ClipboardData(text: _fcmToken!));
      AppSnackbar.showSuccess(
        title: 'Token Copied!',
        message: 'FCM Device Token copied to clipboard.',
      );
    } else {
      AppSnackbar.showError(
        title: 'No Token Available',
        message: 'FCM Token is empty or not fetched yet.',
      );
    }
  }

  void _requestNotificationPermission() async {
    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    setState(() {
      _permissionStatus = settings.authorizationStatus.name.toUpperCase();
      _isPermissionGranted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    });

    if (_isPermissionGranted) {
      AppSnackbar.showSuccess(
        title: 'Permission Granted',
        message: 'Notification permission is active on your device.',
      );
    } else {
      AppSnackbar.showError(
        title: 'Permission Declined',
        message: 'Notification permission was declined. Please enable in Android Settings.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD1E9FF), // Light Blue
              Color(0xFFE9D5FF), // Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // -------------------------------------------------
              // TOP APP BAR
              // -------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF2C3E50), size: 22),
                      onPressed: () => Get.back(),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'NOTIFICATION & FCM TEST',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 1.0,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4E54C8), size: 24),
                      onPressed: _checkPermissionAndToken,
                      tooltip: 'Refresh Token & Status',
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // -------------------------------------------------
                      // 1. PERMISSION STATUS CARD
                      // -------------------------------------------------
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _isPermissionGranted
                                        ? const Color(0xFFECFDF5)
                                        : const Color(0xFFFEF2F2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _isPermissionGranted
                                        ? Icons.verified_user_rounded
                                        : Icons.gpp_maybe_rounded,
                                    color: _isPermissionGranted
                                        ? const Color(0xFF059669)
                                        : const Color(0xFFDC2626),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Notification Permission',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                      ),
                                      Text(
                                        'Status: $_permissionStatus',
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: _isPermissionGranted
                                              ? const Color(0xFF059669)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _requestNotificationPermission,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4E54C8),
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    'Request',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // -------------------------------------------------
                      // 2. FCM DEVICE TOKEN CARD
                      // -------------------------------------------------
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFFFFBEB),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.key_rounded,
                                    color: Color(0xFFD97706),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Firebase FCM Device Token',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: _isLoadingToken
                                  ? const Center(
                                      child: SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            color: Color(0xFF4E54C8), strokeWidth: 2),
                                      ),
                                    )
                                  : SelectableText(
                                      _fcmToken ?? 'Fetching token...',
                                      style: GoogleFonts.firaCode(
                                        fontSize: 11,
                                        color: const Color(0xFF334155),
                                        height: 1.4,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: _checkPermissionAndToken,
                                    icon: const Icon(Icons.refresh_rounded, size: 16, color: Color(0xFF4E54C8)),
                                    label: Text(
                                      'Refresh Token',
                                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4E54C8), fontWeight: FontWeight.bold),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(color: Color(0xFF4E54C8)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _copyTokenToClipboard,
                                    icon: const Icon(Icons.copy_rounded, size: 16, color: Colors.white),
                                    label: Text(
                                      'Copy Token',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4E54C8),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // -------------------------------------------------
                      // 3. LOCAL NOTIFICATION & SOUND TEST BUTTONS
                      // -------------------------------------------------
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFEFF6FF),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.volume_up_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Test Local Notifications & Sound',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap any button below to trigger a live local notification banner with sound on your phone.',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Button 1: Test Admission Notification
                            _buildTestButton(
                              icon: Icons.school_rounded,
                              label: 'Test Admission Alert + Sound',
                              color: const Color(0xFF4F46E5),
                              bgColor: const Color(0xFFEEF2FF),
                              onTap: () {
                                NotificationService.instance.showTestAdmissionNotification();
                                AppSnackbar.showSuccess(
                                  title: 'Admission Sound Test',
                                  message: 'Check your phone status bar for Admission alert & sound!',
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            // Button 2: Test Callback Notification
                            _buildTestButton(
                              icon: Icons.phone_callback_rounded,
                              label: 'Test Callback Alert + Sound',
                              color: const Color(0xFFDC2626),
                              bgColor: const Color(0xFFFEF2F2),
                              onTap: () {
                                NotificationService.instance.showTestCallbackNotification();
                                AppSnackbar.showSuccess(
                                  title: 'Callback Sound Test',
                                  message: 'Check your phone status bar for heads-up banner & sound!',
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            // Button 3: Test Gate Pass Notification
                            _buildTestButton(
                              icon: Icons.badge_outlined,
                              label: 'Test Gate Pass Alert + Sound',
                              color: const Color(0xFF0D9488),
                              bgColor: const Color(0xFFCCFBF1),
                              onTap: () {
                                NotificationService.instance.showTestGatePassNotification();
                                AppSnackbar.showSuccess(
                                  title: 'Gate Pass Sound Test',
                                  message: 'Check your status bar for Gate Pass alert & sound!',
                                );
                              },
                            ),

                            const SizedBox(height: 10),

                            // Button 4: Test Visitor Notification
                            _buildTestButton(
                              icon: Icons.people_alt_rounded,
                              label: 'Test Visitor Log Alert + Sound',
                              color: const Color(0xFF2563EB),
                              bgColor: const Color(0xFFEFF6FF),
                              onTap: () {
                                NotificationService.instance.showTestVisitorNotification();
                                AppSnackbar.showSuccess(
                                  title: 'Visitor Sound Test',
                                  message: 'Check your status bar for Visitor alert & sound!',
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // -------------------------------------------------
                      // 4. TOPIC SUBSCRIPTION STATUS CARD
                      // -------------------------------------------------
                      _buildCardContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFECFDF5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.topic_rounded,
                                    color: Color(0xFF059669),
                                    size: 22,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Subscribed FCM Topics',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                'all',
                                'front_desk',
                                'admission',
                                'admissions',
                                'admission_enquiries',
                                'gate_pass',
                                'gate_passes',
                                'visitor',
                                'visitors',
                                'callbacks',
                                'callback_requests',
                              ].map((topic) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFECFDF5),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFA7F3D0)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF059669)),
                                      const SizedBox(width: 4),
                                      Text(
                                        topic,
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF059669),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  try {
                                    final topics = [
                                      'all',
                                      'front_desk',
                                      'frontdesk',
                                      'front_desk_app',
                                      'admission',
                                      'admissions',
                                      'admission_enquiries',
                                      'admission_enquiry',
                                      'enquiry',
                                      'enquiries',
                                      'gate_pass',
                                      'gate_passes',
                                      'gate_pass_requests',
                                      'gate_pass_request',
                                      'gatepass',
                                      'gatepasses',
                                      'visitor',
                                      'visitors',
                                      'visitor_requests',
                                      'visitor_entry',
                                      'callback',
                                      'callbacks',
                                      'callback_requests',
                                    ];
                                    for (final topic in topics) {
                                      await NotificationService.instance.subscribeToTopic(topic);
                                    }
                                    AppSnackbar.showSuccess(
                                      title: 'Topics Subscribed',
                                      message: 'Re-subscribed to all Front Desk push topics.',
                                    );
                                  } catch (e) {
                                    AppSnackbar.showError(
                                      title: 'Subscription Error',
                                      message: 'Failed to subscribe to topics: $e',
                                    );
                                  }
                                },
                                icon: const Icon(Icons.sync_rounded, size: 18, color: Colors.white),
                                label: Text(
                                  'Re-Subscribe All Topics',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF059669),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  elevation: 0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildTestButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Icon(Icons.play_circle_fill_rounded, color: color, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
