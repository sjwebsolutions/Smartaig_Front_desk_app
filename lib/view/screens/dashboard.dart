import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/dashboard_model.dart';
import '../../services/app_update_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../utils/token_manager.dart';
import '../../view_models/get_x/dashboard_controller.dart';
import '../../view_models/get_x/notification_history_controller.dart';
import '../../view_models/get_x/policies_controller.dart';
import '../../view_models/get_x/support_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';
import 'admission_screen.dart';
import 'auth/login_screen.dart';
import 'call_back_screen.dart';
import 'get_pass_screen.dart';
import 'notification_list_screen.dart';
import 'visitors_screen.dart';

class FrontDeskDashboard extends StatefulWidget {
  const FrontDeskDashboard({super.key});

  @override
  State<FrontDeskDashboard> createState() => _FrontDeskDashboardState();
}

class _FrontDeskDashboardState extends State<FrontDeskDashboard> {
  final DashboardController _controller = Get.put(DashboardController());
  final SupportController _supportController = Get.put(SupportController());
  final PoliciesController _policiesController = Get.put(PoliciesController());

  @override
  void initState() {
    super.initState();
    UnreadCounterController.to.reloadCounters();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Obx(() => _buildDrawer(context, _controller.dashboardData.value)),
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
          child: Obx(() {
            if (_controller.isLoading.value && _controller.dashboardData.value == null) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4E54C8),
                ),
              );
            }

            if (_controller.errorMessage.value.isNotEmpty && _controller.dashboardData.value == null) {
              final isNetErr = AppErrorFormatter.isNetworkError(_controller.errorMessage.value);
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: isNetErr ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isNetErr ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                          color: isNetErr ? const Color(0xFFEA580C) : const Color(0xFFD32F2F),
                          size: 54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isNetErr ? 'No Internet Connection' : 'Oops! Something went wrong',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _controller.errorMessage.value,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _controller.fetchDashboard(),
                        icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                        label: Text(
                          isNetErr ? 'Retry Connection' : 'Retry',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4E54C8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = _controller.dashboardData.value;
            final staff = data?.staff;
            final school = data?.school;
            final todayStats = data?.todayStats;
            final callbackRequests = data?.callbackRequests;
            final todayInfo = data?.todayInfo;

            return RefreshIndicator(
              color: const Color(0xFF4E54C8),
              onRefresh: () => _controller.fetchDashboard(isManualRefresh: true),
              child: Column(
                children: [
                  // -------------------------------------------------
                  // COMPACT TOP APP BAR (MENU ON LEFT, DASHBOARD IN CENTER)
                  // -------------------------------------------------
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu_rounded, color: Color(0xFF2C3E50), size: 26),
                            tooltip: 'Open Menu',
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'DASHBOARD',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                        Obx(() {
                          final unreadCount = NotificationHistoryController.to.unreadCount;
                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2C3E50), size: 26),
                                tooltip: 'Notifications',
                                onPressed: () {
                                  NotificationHistoryController.to.markAllAsRead();
                                  Get.to(() => const NotificationListScreen());
                                },
                              ),
                              if (unreadCount > 0)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEF4444),
                                      shape: BoxShape.rectangle,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                    child: Center(
                                      child: Text(
                                        unreadCount > 99 ? '99+' : '$unreadCount',
                                        style: GoogleFonts.poppins(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        }),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          // -------------------------------------------------
                          // 1. STAFF PROFILE CARD
                          // -------------------------------------------------
                          _buildStaffProfileCard(staff, school),
                          const SizedBox(height: 16),

                          // -------------------------------------------------
                          // 2. TODAY'S OVERVIEW / STATS
                          // -------------------------------------------------
                          if (todayInfo != null || todayStats != null) ...[
                            _buildTodayStatsSection(todayInfo, todayStats),
                            const SizedBox(height: 16),
                          ],

                          // -------------------------------------------------
                          // 3. CALLBACK REQUESTS OVERVIEW
                          // -------------------------------------------------
                          if (callbackRequests != null &&
                              ((callbackRequests.pending ?? 0) > 0 || (callbackRequests.inProgress ?? 0) > 0)) ...[
                            _buildCallbackRequestsCard(callbackRequests),
                            const SizedBox(height: 16),
                          ],

                          // -------------------------------------------------
                          // 4. FRONT DESK MODULES
                          // -------------------------------------------------
                          _buildModulesSection(context),
                          const SizedBox(height: 25),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, DashboardData? data) {
    final staff = data?.staff;
    final school = data?.school;

    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
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
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              // -------------------------------------------------
              // PROFILE CARD AT TOP OF MENU
              // -------------------------------------------------
              Container(
                padding: const EdgeInsets.all(14),
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
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFE8EAF6),
                      backgroundImage: (staff?.image != null && staff!.image!.isNotEmpty)
                          ? NetworkImage(staff.image!)
                          : (staff?.thumbnail != null && staff!.thumbnail!.isNotEmpty)
                              ? NetworkImage(staff.thumbnail!)
                              : null,
                      child: (staff?.image == null || staff!.image!.isEmpty) &&
                              (staff?.thumbnail == null || staff!.thumbnail!.isEmpty)
                          ? const Icon(Icons.person, size: 28, color: Color(0xFF4E54C8))
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff?.name ?? 'Staff Name',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2C3E50),
                              height: 1.25,
                            ),
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
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0F2FE),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    staff?.role ?? staff?.staffType ?? '',
                                    style: GoogleFonts.poppins(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF0284C7),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (school?.name != null && school!.name!.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              school.name!,
                              softWrap: true,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: const Color(0xFF4E54C8),
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),

              // 1. Registered Mobile Card
              _buildMenuCard(
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
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
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
              const SizedBox(height: 15),

              // 2. Support Card
              _buildMenuCard(
                icon: Icons.headset_mic_rounded,
                iconColor: const Color(0xFF3B82F6),
                iconBg: const Color(0xFFEFF6FF),
                title: 'Contact Support',
                subtitle: 'Help & Customer Assistance',
                onTap: () {
                  Navigator.pop(context);
                  _showSupportDialog(context);
                },
              ),
                const SizedBox(height: 15),

                // 2. Privacy Policy Card
                _buildMenuCard(
                  icon: Icons.privacy_tip_rounded,
                  iconColor: const Color(0xFF10B981),
                  iconBg: const Color(0xFFECFDF5),
                  title: 'Privacy Policy',
                  subtitle: 'Data security & privacy rules',
                  onTap: () {
                    Navigator.pop(context);
                    _showPrivacyPolicyDialog(context);
                  },
                ),
                const SizedBox(height: 15),

                // 3. Terms of Use Card
                _buildMenuCard(
                  icon: Icons.gavel_rounded,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBg: const Color(0xFFF5F3FF),
                  title: 'Terms of Use',
                  subtitle: 'Service rules & agreements',
                  onTap: () {
                    Navigator.pop(context);
                    _showTermsOfUseDialog(context);
                  },
                ),
                const SizedBox(height: 15),

                // 4. Version Info Card
                _buildMenuCard(
                  icon: Icons.system_update_rounded,
                  iconColor: const Color(0xFF0EA5E9),
                  iconBg: const Color(0xFFF0F9FF),
                  title: 'App Version',
                  subtitle: 'v2.0.5 (Check for Updates)',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Check',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    AppUpdateService.checkForUpdates(isManualCheck: true);
                  },
                ),
                const SizedBox(height: 15),

                // 5. Logout Card
                _buildMenuCard(
                  icon: Icons.logout_rounded,
                  iconColor: const Color(0xFFDC2626),
                  iconBg: const Color(0xFFFEE2E2),
                  title: 'Logout',
                  subtitle: 'Sign out of Front Desk',
                  cardBg: const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFFECACA),
                  titleColor: const Color(0xFFDC2626),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildMenuCard({
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

  // -------------------------------------------------
  // 1. STAFF PROFILE CARD
  // -------------------------------------------------
  Widget _buildStaffProfileCard(DashboardStaff? staff, DashboardSchool? school) {
    final image = staff?.image;
    final thumb = staff?.thumbnail;
    final hasImage = image != null && image.isNotEmpty;
    final hasThumb = thumb != null && thumb.isNotEmpty;
    final staffId = staff?.teacherUniqueId ?? staff?.id?.toString() ?? 'N/A';
    final role = staff?.role ?? staff?.designation ?? staff?.staffType;
    final status = staff?.status;
    final isActive = status == '1' || status?.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xFFE8EAF6),
            backgroundImage: hasImage
                ? NetworkImage(image)
                : hasThumb
                    ? NetworkImage(thumb)
                    : null,
            child: (!hasImage && !hasThumb)
                ? const Icon(Icons.person, size: 32, color: Color(0xFF4E54C8))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        staff?.name ?? 'Staff Member',
                        softWrap: true,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2C3E50),
                          height: 1.25,
                        ),
                      ),
                    ),
                    if (status != null && status.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isActive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isActive ? 'Active' : status,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: isActive ? const Color(0xFF059669) : const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'ID: $staffId',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (role != null && role.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          role,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                  ],
                ),
                if (school?.name != null && school!.name!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    school.name!,
                    softWrap: true,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF4E54C8),
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // 2. TODAY'S OVERVIEW / STATS SECTION (SINGLE COMPACT CARD)
  // -------------------------------------------------
  Widget _buildTodayStatsSection(TodayInfo? todayInfo, TodayStats? todayStats) {
    final dayName = todayInfo?.dayName ?? 'Today';
    final date = todayInfo?.date ?? '';
    final visitors = todayStats?.visitorsCount ?? 0;
    final gatePasses = todayStats?.gatePassesCount ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------- Top Row: Day, Date & Live Badge -----------------
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: Color(0xFF4F46E5),
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dayName,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        height: 1.2,
                      ),
                    ),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                          height: 1.2,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),

                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(10)),
                        color: Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live Stats',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              thickness: 1,
              color: Color(0xFFF1F5F9),
            ),
          ),

          // ----------------- Bottom Row: Stats (Visitors & Gate Passes) -----------------
          Row(
            children: [
              // Stat 1: Visitors
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Color(0xFF2563EB),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$visitors',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Visitors',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                height: 30,
                width: 1,
                color: const Color(0xFFE2E8F0),
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),

              // Stat 2: Gate Passes
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.confirmation_number_rounded,
                        color: Color(0xFF059669),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$gatePasses',
                            style: GoogleFonts.poppins(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0F172A),
                              height: 1.1,
                            ),
                          ),
                          Text(
                            'Gate Passes',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // 3. CALLBACK REQUESTS CARD
  // -------------------------------------------------
  Widget _buildCallbackRequestsCard(CallbackRequests callbackRequests) {
    final pending = callbackRequests.pending ?? 0;
    final inProgress = callbackRequests.inProgress ?? 0;
    final completed = callbackRequests.completedToday ?? 0;

    if (pending == 0 && inProgress == 0) {
      return const SizedBox.shrink();
    }

    return Obx(() {
      final unreadCount = UnreadCounterController.to.callbackCount.value;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              UnreadCounterController.to.clearCallback();
              Get.to(() => const CallBackScreen());
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.phone_callback_rounded,
                          color: Color(0xFFDC2626),
                          size: 15,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Callback Requests',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (unreadCount > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount NEW',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF1F5F9),
                    ),
                  ),
                  Row(
                    children: [
                      // Pending
                      Expanded(
                        child: _buildCallbackStatItem(
                          count: pending,
                          label: 'Pending',
                          icon: Icons.hourglass_top_rounded,
                          color: const Color(0xFFD97706),
                          bgColor: const Color(0xFFFFFBEB),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: const Color(0xFFE2E8F0),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      // In Progress
                      Expanded(
                        child: _buildCallbackStatItem(
                          count: inProgress,
                          label: 'In Progress',
                          icon: Icons.sync_rounded,
                          color: const Color(0xFF2563EB),
                          bgColor: const Color(0xFFEFF6FF),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: const Color(0xFFE2E8F0),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                      ),
                      // Completed Today
                      Expanded(
                        child: _buildCallbackStatItem(
                          count: completed,
                          label: 'Completed',
                          icon: Icons.check_circle_outline_rounded,
                          color: const Color(0xFF059669),
                          bgColor: const Color(0xFFECFDF5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCallbackStatItem({
    required int count,
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF64748B),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // -------------------------------------------------
  // 4. FRONT DESK MODULES GRID
  // -------------------------------------------------
  Widget _buildModulesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MODULES',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF2C3E50),
          ),
        ),
        const SizedBox(height: 12),
        Obx(() {
          final unread = UnreadCounterController.to;
          final modules = [
            {
              'title': 'Get Pass',
              'icon': Icons.badge_outlined,
              'iconBg': const Color(0xFFCCFBF1),
              'iconColor': const Color(0xFF0D9488),
              'screen': const GetPassScreen(),
              'badge': unread.gatePassCount.value,
              'onClear': () => unread.clearGatePass(),
            },
            {
              'title': 'Visitors',
              'icon': Icons.people_alt_rounded,
              'iconBg': const Color(0xFFEFF6FF),
              'iconColor': const Color(0xFF2563EB),
              'screen': const VisitorsScreen(),
              'badge': unread.visitorCount.value,
              'onClear': () => unread.clearVisitor(),
            },
            {
              'title': 'Call Back',
              'icon': Icons.phone_callback_rounded,
              'iconBg': const Color(0xFFFEF2F2),
              'iconColor': const Color(0xFFDC2626),
              'screen': const CallBackScreen(),
              'badge': unread.callbackCount.value,
              'onClear': () => unread.clearCallback(),
            },
            {
              'title': 'Admission',
              'icon': Icons.school_rounded,
              'iconBg': const Color(0xFFE0E7FF),
              'iconColor': const Color(0xFF4F46E5),
              'screen': const AdmissionScreen(),
              'badge': unread.admissionCount.value,
              'onClear': () => unread.clearAdmission(),
            },
          ];

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final item = modules[index];
              return _buildModuleCard(
                title: item['title'] as String,
                icon: item['icon'] as IconData,
                iconBg: item['iconBg'] as Color,
                iconColor: item['iconColor'] as Color,
                badgeCount: item['badge'] as int,
                onTap: () {
                  final onClear = item['onClear'] as VoidCallback;
                  onClear();
                  Get.to(() => item['screen'] as Widget);
                },
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildModuleCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    int badgeCount = 0,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2C3E50),
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              if (badgeCount > 0)
                Positioned(
                  top: 6,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


