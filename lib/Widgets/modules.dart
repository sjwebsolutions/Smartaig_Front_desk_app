import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view/screens/admission_screen.dart';
import '../view/screens/call_back_screen.dart';
import '../view/screens/get_pass_screen.dart';
import '../view/screens/qr_attendance_scanner_screen.dart';
import '../view/screens/student_count_screen.dart';
import '../view/screens/student_leave_screen.dart';
import '../view/screens/teacher_leave_screen.dart';
import '../view/screens/transport_screen.dart';
import '../view/screens/visitors_screen.dart';
import '../view_models/get_x/dashboard_controller.dart';
import '../view_models/get_x/unread_counter_controller.dart';

class DashboardModulesWidget extends StatelessWidget {
  const DashboardModulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final unread = UnreadCounterController.to;
      final dashController = Get.isRegistered<DashboardController>()
          ? Get.find<DashboardController>()
          : null;
      final dashData = dashController?.dashboardData.value;

      final callbackPending = dashData?.callbackRequests?.pending ?? 0;
      final studentLeavePending = dashData?.studentLeaves?.totalPendingCount ?? 0;
      final teacherLeavePending = dashData?.teacherLeaves?.totalPendingCount ?? 0;

      // Section 1: VISITOR & GATE PASS SERVICES
      final visitorModules = [
        DashboardModuleItem(
          title: 'Get Pass',
          icon: Icons.badge_outlined,
          cardBg: const Color(0xFFF0FDFA),
          cardBorder: const Color(0xFF99F6E4),
          iconBg: const Color(0xFFCCFBF1),
          iconColor: const Color(0xFF0D9488),
          screen: const GetPassScreen(showBackButton: true),
          badgeCount: unread.gatePassCount.value,
          onClear: () => unread.clearGatePass(),
        ),
        DashboardModuleItem(
          title: 'Visitors',
          icon: Icons.people_alt_rounded,
          cardBg: const Color(0xFFEFF6FF),
          cardBorder: const Color(0xFFBFDBFE),
          iconBg: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          screen: const VisitorsScreen(showBackButton: true),
          badgeCount: unread.visitorCount.value,
          onClear: () => unread.clearVisitor(),
        ),
        DashboardModuleItem(
          title: 'Call Back',
          icon: Icons.phone_callback_rounded,
          cardBg: const Color(0xFFFEF2F2),
          cardBorder: const Color(0xFFFECACA),
          iconBg: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          screen: const CallBackScreen(),
          badgeCount: callbackPending > 0 ? callbackPending : unread.callbackCount.value,
          onClear: () => unread.clearCallback(),
        ),
      ];

      // Section 2: ACADEMIC & LEAVE MANAGEMENT
      final academicModules = [
        DashboardModuleItem(
          title: 'Admission',
          icon: Icons.school_rounded,
          cardBg: const Color(0xFFF5F3FF),
          cardBorder: const Color(0xFFDDD6FE),
          iconBg: const Color(0xFFEDE9FE),
          iconColor: const Color(0xFF6D28D9),
          screen: const AdmissionScreen(),
          badgeCount: unread.admissionCount.value,
          onClear: () => unread.clearAdmission(),
        ),
        DashboardModuleItem(
          title: 'Student Leave',
          icon: Icons.event_note_rounded,
          cardBg: const Color(0xFFFFF1F2),
          cardBorder: const Color(0xFFFECDD3),
          iconBg: const Color(0xFFFFE4E6),
          iconColor: const Color(0xFFE11D48),
          screen: const StudentLeaveScreen(),
          badgeCount: studentLeavePending > 0 ? studentLeavePending : unread.studentLeaveCount.value,
          onClear: () => unread.clearStudentLeave(),
        ),
        DashboardModuleItem(
          title: 'Teacher Leave',
          icon: Icons.assignment_ind_rounded,
          cardBg: const Color(0xFFF0F9FF),
          cardBorder: const Color(0xFFBAE6FD),
          iconBg: const Color(0xFFE0F2FE),
          iconColor: const Color(0xFF0284C7),
          screen: const TeacherLeaveScreen(),
          badgeCount: teacherLeavePending > 0 ? teacherLeavePending : unread.teacherLeaveCount.value,
          onClear: () => unread.clearTeacherLeave(),
        ),
      ];

      // Section 3: ATTENDANCE & RECORDS
      final attendanceModules = [
        DashboardModuleItem(
          title: 'Student Count',
          icon: Icons.groups_rounded,
          cardBg: const Color(0xFFFFFBEB),
          cardBorder: const Color(0xFFFDE68A),
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          screen: const StudentCountScreen(),
          badgeCount: unread.studentCount.value,
          onClear: () => unread.clearStudentCount(),
        ),
        DashboardModuleItem(
          title: 'Scan Attendance',
          icon: Icons.qr_code_scanner_rounded,
          cardBg: const Color(0xFFF0FDF4),
          cardBorder: const Color(0xFFBBF7D0),
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          screen: const QrAttendanceScannerScreen(),
          badgeCount: unread.scanAttendanceCount.value,
          onClear: () => unread.clearScanAttendance(),
        ),
        DashboardModuleItem(
          title: 'Transport',
          icon: Icons.directions_bus_rounded,
          cardBg: const Color(0xFFFFF7ED),
          cardBorder: const Color(0xFFFFEDD5),
          iconBg: const Color(0xFFFFEDD5),
          iconColor: const Color(0xFFEA580C),
          screen: const TransportScreen(initialTabIndex: 0),
          badgeCount: unread.transportCount.value,
          onClear: () => unread.clearTransportCount(),
        ),
      ];

      return Column(
        children: [
          // Section 1
          _buildSectionCard(
            context: context,
            title: 'VISITOR & GATE PASS SERVICES',
            headerIcon: Icons.badge_rounded,
            headerIconBg: const Color(0xFFEEF2FF),
            headerIconColor: const Color(0xFF4F46E5),
            items: visitorModules,
          ),
          const SizedBox(height: 10),

          // Section 2
          _buildSectionCard(
            context: context,
            title: 'ACADEMIC & LEAVE MANAGEMENT',
            headerIcon: Icons.school_rounded,
            headerIconBg: const Color(0xFFF3E8FF),
            headerIconColor: const Color(0xFF7C3AED),
            items: academicModules,
          ),
          const SizedBox(height: 10),

          // Section 3
          _buildSectionCard(
            context: context,
            title: 'ATTENDANCE & RECORDS',
            headerIcon: Icons.fact_check_rounded,
            headerIconBg: const Color(0xFFECFDF5),
            headerIconColor: const Color(0xFF059669),
            items: attendanceModules,
          ),
        ],
      );
    });
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData headerIcon,
    required Color headerIconBg,
    required Color headerIconColor,
    required List<DashboardModuleItem> items,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final int crossAxisCount = isTablet ? 4 : 3;
    final double aspectRatio = isTablet ? 1.2 : 1.05;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
          // Section Header
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: headerIconBg,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Center(
                  child: Icon(
                    headerIcon,
                    color: headerIconColor,
                    size: 17,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Module Cards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: aspectRatio,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return DashboardModuleCard(
                title: item.title,
                icon: item.icon,
                cardBg: item.cardBg,
                cardBorder: item.cardBorder,
                iconBg: item.iconBg,
                iconColor: item.iconColor,
                badgeCount: item.badgeCount,
                onTap: () {
                  item.onClear();
                  Get.to(() => item.screen);
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class DashboardModuleItem {
  final String title;
  final IconData icon;
  final Color cardBg;
  final Color cardBorder;
  final Color iconBg;
  final Color iconColor;
  final Widget screen;
  final int badgeCount;
  final VoidCallback onClear;

  DashboardModuleItem({
    required this.title,
    required this.icon,
    required this.cardBg,
    required this.cardBorder,
    required this.iconBg,
    required this.iconColor,
    required this.screen,
    required this.badgeCount,
    required this.onClear,
  });
}

class DashboardModuleCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color cardBg;
  final Color cardBorder;
  final Color iconBg;
  final Color iconColor;
  final int badgeCount;
  final VoidCallback onTap;

  const DashboardModuleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.cardBg,
    required this.cardBorder,
    required this.iconBg,
    required this.iconColor,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;

    final double iconContainerSize = isTablet ? 42 : 36;
    final double iconSize = isTablet ? 22 : 18;
    final double titleFontSize = isTablet ? 11.5 : 10.5;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cardBorder,
          width: 1,
        ),
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
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: iconContainerSize,
                        height: iconContainerSize,
                        decoration: BoxDecoration(
                          color: iconBg,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            color: iconColor,
                            size: iconSize,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                          height: 1.15,
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
                  top: 5,
                  right: 5,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Center(
                      child: Text(
                        badgeCount > 99 ? '99+' : '$badgeCount',
                        style: GoogleFonts.poppins(
                          fontSize: isTablet ? 9.5 : 8.5,
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
