import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/app_update_service.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/token_manager.dart';
import '../../view_models/get_x/dashboard_controller.dart';
import '../../view_models/get_x/policies_controller.dart';
import '../../view_models/get_x/support_controller.dart';
import 'auth/login_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  DashboardController get _dashController => Get.isRegistered<DashboardController>()
      ? Get.find<DashboardController>()
      : Get.put(DashboardController());

  SupportController get _supportController => Get.isRegistered<SupportController>()
      ? Get.find<SupportController>()
      : Get.put(SupportController());

  PoliciesController get _policiesController => Get.isRegistered<PoliciesController>()
      ? Get.find<PoliciesController>()
      : Get.put(PoliciesController());

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
              Color(0xFFD1E9FF), // Vibrant Light Blue
              Color(0xFFE9D5FF), // Vibrant Light Purple
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ----------------- TOP BAR -----------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    if (Navigator.canPop(context))
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 22),
                        onPressed: () => Navigator.pop(context),
                      )
                    else
                      const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'SETTINGS',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
              ),

              // ----------------- MAIN CONTENT LIST -----------------
              Expanded(
                child: Obx(() {
                  final data = _dashController.dashboardData.value;
                  final staff = data?.staff;
                  final school = data?.school;

                  return ListView(
                    padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 90),
                    physics: const BouncingScrollPhysics(),
                    children: [
                      // 1. PROFILE HEADER CARD
                      _buildProfileCard(staff, school),
                      const SizedBox(height: 10),

                      // 2. REGISTERED MOBILE CARD
                      _buildSettingsCard(
                        icon: Icons.phone_android_rounded,
                        iconColor: const Color(0xFF6366F1),
                        iconBg: const Color(0xFFEEF2FF),
                        title: 'Registered Mobile',
                        subtitle: staff?.whatsappNumber != null && staff!.whatsappNumber!.isNotEmpty
                            ? '+91 ${staff.whatsappNumber}'
                            : staff?.phone != null && staff!.phone!.isNotEmpty
                                ? '+91 ${staff.phone}'
                                : 'Not Available',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFA7F3D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.verified_rounded, size: 12, color: Color(0xFF059669)),
                              const SizedBox(width: 3),
                              Text(
                                'Verified',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF059669),
                                ),
                              ),
                            ],
                          ),
                        ),
                        onTap: () {},
                      ),
                      const SizedBox(height: 10),

                      // 3. CONTACT SUPPORT
                      _buildSettingsCard(
                        icon: Icons.headset_mic_rounded,
                        iconColor: const Color(0xFF3B82F6),
                        iconBg: const Color(0xFFEFF6FF),
                        title: 'Contact Support',
                        subtitle: 'Help & Customer Assistance',
                        onTap: () => _showSupportDialog(context),
                      ),
                      const SizedBox(height: 10),

                      // 4. PRIVACY POLICY
                      _buildSettingsCard(
                        icon: Icons.privacy_tip_rounded,
                        iconColor: const Color(0xFF10B981),
                        iconBg: const Color(0xFFECFDF5),
                        title: 'Privacy Policy',
                        subtitle: 'Data security & privacy rules',
                        onTap: () => _showPrivacyPolicyDialog(context),
                      ),
                      const SizedBox(height: 10),

                      // 5. TERMS OF USE
                      _buildSettingsCard(
                        icon: Icons.gavel_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBg: const Color(0xFFF5F3FF),
                        title: 'Terms of Use',
                        subtitle: 'Service rules & agreements',
                        onTap: () => _showTermsOfUseDialog(context),
                      ),
                      const SizedBox(height: 10),

                      // 6. APP VERSION & UPDATE CHECK
                      _buildSettingsCard(
                        icon: Icons.system_update_rounded,
                        iconColor: const Color(0xFF0EA5E9),
                        iconBg: const Color(0xFFF0F9FF),
                        title: 'App Version',
                        subtitle: '${AppUpdateService.currentAppVersion.replaceAll(RegExp(r'^[vV]'), '')} (Tap to Check)',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0F2FE),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Check',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ),
                        onTap: () => AppUpdateService.checkForUpdates(isManualCheck: true),
                      ),
                      const SizedBox(height: 10),

                      // 7. LOGOUT CARD
                      _buildSettingsCard(
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFDC2626),
                        iconBg: const Color(0xFFFEE2E2),
                        title: 'Logout',
                        subtitle: 'Sign out of Front Desk',
                        cardBg: const Color(0xFFFEF2F2),
                        borderColor: const Color(0xFFFECACA),
                        titleColor: const Color(0xFFDC2626),
                        onTap: () => _showLogoutDialog(context),
                      ),
                      const SizedBox(height: 25),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(dynamic staff, dynamic school) {
    final imageUrl = (staff?.image != null && staff!.image!.isNotEmpty)
        ? staff.image!
        : (staff?.thumbnail != null && staff!.thumbnail!.isNotEmpty)
            ? staff.thumbnail!
            : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 58,
              height: 58,
              color: const Color(0xFFE8EAF6),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      key: ValueKey(imageUrl),
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.person, size: 30, color: Color(0xFF4E54C8)),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.person, size: 30, color: Color(0xFF4E54C8)),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: staff?.name ?? 'Staff Name',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                          height: 1.25,
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Image.asset(
                            'assets/images/blue_tick.png',
                            width: 15,
                            height: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 3),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'ID: ${staff?.teacherUniqueId ?? staff?.id?.toString() ?? 'N/A'}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (staff?.role != null || staff?.staffType != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          staff?.role ?? staff?.staffType ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                  ],
                ),
                if (school?.name != null && school!.name!.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: school.name!,
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            color: const Color(0xFF4E54C8),
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 4),
                            child: Image.asset(
                              'assets/images/blue_tick.png',
                              width: 13,
                              height: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    softWrap: true,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    Color cardBg = Colors.white,
    Color? borderColor,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 70),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: borderColor ?? Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: titleColor ?? const Color(0xFF1E293B),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: const Color(0xFF64748B),
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (trailing != null)
                  trailing
                else
                  const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSupportDialog(BuildContext context) {
    if (_supportController.supportData.value == null && !_supportController.isLoading.value) {
      _supportController.fetchSupportSettings();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.headset_mic_rounded, color: Color(0xFF3B82F6), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Support & Help',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
        content: Obx(() {
          if (_supportController.isLoading.value && _supportController.supportData.value == null) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF4E54C8)),
                  SizedBox(height: 12),
                  Text('Loading support info...', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
            );
          }

          if (_supportController.errorMessage.value.isNotEmpty && _supportController.supportData.value == null) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 36),
                  const SizedBox(height: 8),
                  Text(
                    _supportController.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => _supportController.fetchSupportSettings(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E54C8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                ],
              ),
            );
          }

          final support = _supportController.supportData.value;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (support?.name != null && support!.name!.isNotEmpty) ...[
                  Text(
                    support.name!,
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  'For technical issues or customer support, reach out to us:',
                  style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                ),
                const SizedBox(height: 14),
                if (support?.whatsapp != null && support!.whatsapp!.isNotEmpty)
                  _buildSupportContactTile(
                    icon: FontAwesomeIcons.whatsapp,
                    iconColor: const Color(0xFF25D366),
                    iconBg: const Color(0xFFDCFCE7),
                    label: 'WhatsApp Support',
                    value: support.whatsapp!,
                    actionLabel: 'Chat',
                    onTap: () => _launchWhatsApp(support.whatsapp!),
                  ),
                if (support?.email != null && support!.email!.isNotEmpty)
                  _buildSupportContactTile(
                    icon: FontAwesomeIcons.envelope,
                    iconColor: const Color(0xFF7C3AED),
                    iconBg: const Color(0xFFF5F3FF),
                    label: 'Email Support',
                    value: support.email!,
                    actionLabel: 'Mail',
                    onTap: () => _launchEmail(support.email!),
                  ),
                if (support?.mobile != null && support!.mobile!.isNotEmpty)
                  _buildSupportContactTile(
                    icon: FontAwesomeIcons.phone,
                    iconColor: const Color(0xFF2563EB),
                    iconBg: const Color(0xFFEFF6FF),
                    label: 'Mobile / Call',
                    value: support.mobile!,
                    actionLabel: 'Call',
                    onTap: () => _launchCall(support.mobile!),
                  ),
              ],
            ),
          );
        }),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E54C8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Close', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _launchWhatsApp(String phone) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final fullNumber = clean.length == 10 ? '91$clean' : clean;
    final url = Uri.parse('https://wa.me/$fullNumber?text=${Uri.encodeComponent('Hello, I need assistance regarding Smart AIG Front Desk App.')}');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(
          title: 'WhatsApp Not Available',
          message: 'Could not open WhatsApp app. You can reach out at $phone.',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'WhatsApp Notice',
        message: 'Unable to open WhatsApp. Please check the app and try again.',
      );
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse('mailto:$email?subject=${Uri.encodeComponent('Smart AIG Front Desk App Support')}');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(
          title: 'Email App Not Available',
          message: 'Could not open email client. Please send your email to $email.',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Email Notice',
        message: 'Unable to open email app. Please write directly to $email.',
      );
    }
  }

  Future<void> _launchCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$clean');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(
          title: 'Dialer Not Available',
          message: 'Could not open dialer. Please call directly on $phone.',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Call Notice',
        message: 'Unable to open dialer. Please call directly on $phone.',
      );
    }
  }

  Widget _buildSupportContactTile({
    required FaIconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required String value,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: FaIcon(icon, color: iconColor, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        value,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        actionLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: iconColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 12, color: iconColor),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    if (_policiesController.policiesData.value == null && !_policiesController.isLoading.value) {
      _policiesController.fetchPolicies();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFECFDF5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.privacy_tip_rounded, color: Color(0xFF10B981), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Privacy Policy',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (_policiesController.isLoading.value && _policiesController.policiesData.value == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF10B981)),
                    SizedBox(height: 12),
                    Text('Loading Privacy Policy...', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              );
            }

            if (_policiesController.errorMessage.value.isNotEmpty && _policiesController.policiesData.value == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 36),
                    const SizedBox(height: 8),
                    Text(
                      _policiesController.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _policiesController.fetchPolicies(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              );
            }

            final privacyHtml = _policiesController.policiesData.value?.privacyPolicy;

            return SingleChildScrollView(
              child: _buildHtmlContent(privacyHtml),
            );
          }),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('I Understand', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTermsOfUseDialog(BuildContext context) {
    if (_policiesController.policiesData.value == null && !_policiesController.isLoading.value) {
      _policiesController.fetchPolicies();
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F3FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.gavel_rounded, color: Color(0xFF8B5CF6), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Terms of Use',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Obx(() {
            if (_policiesController.isLoading.value && _policiesController.policiesData.value == null) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                    SizedBox(height: 12),
                    Text('Loading Terms of Use...', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ],
                ),
              );
            }

            if (_policiesController.errorMessage.value.isNotEmpty && _policiesController.policiesData.value == null) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFFD32F2F), size: 36),
                    const SizedBox(height: 8),
                    Text(
                      _policiesController.errorMessage.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => _policiesController.fetchPolicies(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              );
            }

            final termsHtml = _policiesController.policiesData.value?.termsOfUse;

            return SingleChildScrollView(
              child: _buildHtmlContent(termsHtml),
            );
          }),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Accept', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildHtmlContent(String? htmlContent) {
    if (htmlContent == null || htmlContent.trim().isEmpty) {
      return Text(
        'No content available.',
        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
      );
    }

    final String content = htmlContent.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');
    final RegExp tagRegex = RegExp(r'<(h[1-6]|p|li)[^>]*>(.*?)</\1>', caseSensitive: false, dotAll: true);
    final matches = tagRegex.allMatches(content);

    if (matches.isEmpty) {
      final cleanText = content.replaceAll(RegExp(r'<[^>]*>'), '').trim();
      return Text(
        cleanText,
        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF475569), height: 1.5),
      );
    }

    List<Widget> widgets = [];
    for (final match in matches) {
      final tag = match.group(1)?.toLowerCase() ?? 'p';
      final innerHtml = match.group(2) ?? '';

      if (tag.startsWith('h')) {
        final headingText = innerHtml.replaceAll(RegExp(r'<[^>]*>'), '').trim();
        if (headingText.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                _decodeHtmlEntities(headingText),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ),
          );
        }
      } else {
        final spans = _parseInlineSpans(innerHtml);
        if (spans.isNotEmpty) {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RichText(
                text: TextSpan(
                  children: spans,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
              ),
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  List<InlineSpan> _parseInlineSpans(String html) {
    List<InlineSpan> spans = [];
    final RegExp inlineRegex = RegExp(r'<(strong|b)[^>]*>(.*?)</\1>', caseSensitive: false, dotAll: true);
    int currentIndex = 0;

    for (final match in inlineRegex.allMatches(html)) {
      if (match.start > currentIndex) {
        final plainText = html.substring(currentIndex, match.start).replaceAll(RegExp(r'<[^>]*>'), '');
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(text: _decodeHtmlEntities(plainText)));
        }
      }

      final boldText = match.group(2)?.replaceAll(RegExp(r'<[^>]*>'), '') ?? '';
      if (boldText.isNotEmpty) {
        spans.add(
          TextSpan(
            text: _decodeHtmlEntities(boldText),
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
        );
      }
      currentIndex = match.end;
    }

    if (currentIndex < html.length) {
      final remaining = html.substring(currentIndex).replaceAll(RegExp(r'<[^>]*>'), '');
      if (remaining.isNotEmpty) {
        spans.add(TextSpan(text: _decodeHtmlEntities(remaining)));
      }
    }

    return spans;
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 22),
            ),
            const SizedBox(width: 10),
            Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out from Front Desk?',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // Close dialog
              await TokenManager.removeToken();
              Get.offAll(() => const LoginScreen(justLoggedOut: true));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
