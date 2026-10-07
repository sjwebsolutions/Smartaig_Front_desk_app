import 'package:flutter/material.dart';
import 'package:front_desk_app/view/screens/teacher_leave_screen.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../view/screens/admission_screen.dart';
import '../view/screens/call_back_screen.dart';
import '../view/screens/get_pass_screen.dart';
import '../view/screens/qr_attendance_scanner_screen.dart';
import '../view/screens/student_count_screen.dart';
import '../view/screens/student_leave_screen.dart';
import '../view/screens/visitors_screen.dart';
import '../view_models/get_x/dashboard_controller.dart';
import '../view_models/get_x/unread_counter_controller.dart';

class DashboardModulesWidget extends StatelessWidget {
  const DashboardModulesWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          final dashController = Get.isRegistered<DashboardController>()
              ? Get.find<DashboardController>()
              : null;
          final dashData = dashController?.dashboardData.value;

          final callbackPending = dashData?.callbackRequests?.pending ?? 0;
          final studentLeavePending = dashData?.studentLeaves?.totalPendingCount ?? 0;
          final teacherLeavePending = dashData?.teacherLeaves?.totalPendingCount ?? 0;

          final modules = [
            DashboardModuleItem(
              title: 'Get Pass',
              icon: Icons.badge_outlined,
              iconBg: const Color(0xFFCCFBF1),
              iconColor: const Color(0xFF0D9488),
              screen: const GetPassScreen(),
              badgeCount: unread.gatePassCount.value,
              onClear: () => unread.clearGatePass(),
            ),
            DashboardModuleItem(
              title: 'Visitors',
              icon: Icons.people_alt_rounded,
              iconBg: const Color(0xFFEFF6FF),
              iconColor: const Color(0xFF2563EB),
              screen: const VisitorsScreen(),
              badgeCount: unread.visitorCount.value,
              onClear: () => unread.clearVisitor(),
            ),
            DashboardModuleItem(
              title: 'Call Back',
              icon: Icons.phone_callback_rounded,
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFDC2626),
              screen: const CallBackScreen(),
              badgeCount: callbackPending > 0 ? callbackPending : unread.callbackCount.value,
              onClear: () => unread.clearCallback(),
            ),
            DashboardModuleItem(
              title: 'Admission',
              icon: Icons.school_rounded,
              iconBg: const Color(0xFFE0E7FF),
              iconColor: const Color(0xFF4F46E5),
              screen: const AdmissionScreen(),
              badgeCount: unread.admissionCount.value,
              onClear: () => unread.clearAdmission(),
            ),
            DashboardModuleItem(
              title: 'Students Leave',
              icon: Icons.event_note_rounded,
              iconBg: const Color(0xFFFFE4E6),
              iconColor: const Color(0xFFE11D48),
              screen: const StudentLeaveScreen(),
              badgeCount: studentLeavePending > 0 ? studentLeavePending : unread.studentLeaveCount.value,
              onClear: () => unread.clearStudentLeave(),
            ),
            DashboardModuleItem(
              title: 'Teachers Leave',
              icon: Icons.assignment_ind_rounded,
              iconBg: const Color(0xFFE0F2FE),
              iconColor: const Color(0xFF0284C7),
              screen: const TeacherLeaveScreen(),
              badgeCount: teacherLeavePending > 0 ? teacherLeavePending : unread.teacherLeaveCount.value,
              onClear: () => unread.clearTeacherLeave(),
            ),
            DashboardModuleItem(
              title: 'Student Count',
              icon: Icons.groups_rounded,
              iconBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFD97706),
              screen: const StudentCountScreen(),
              badgeCount: unread.studentCount.value,
              onClear: () => unread.clearStudentCount(),
            ),
            DashboardModuleItem(
              title: 'Scan Attendance',
              icon: Icons.qr_code_scanner_rounded,
              iconBg: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF16A34A),
              screen: const QrAttendanceScannerScreen(),
              badgeCount: unread.scanAttendanceCount.value,
              onClear: () => unread.clearScanAttendance(),
            ),
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
              return DashboardModuleCard(
                title: item.title,
                icon: item.icon,
                iconBg: item.iconBg,
                iconColor: item.iconColor,
                badgeCount: item.badgeCount,
                onTap: () {
                  item.onClear();
                  Get.to(() => item.screen);
                },
              );
            },
          );
        }),
      ],
    );
  }
}

class DashboardModuleItem {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Widget screen;
  final int badgeCount;
  final VoidCallback onClear;

  DashboardModuleItem({
    required this.title,
    required this.icon,
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
  final Color iconBg;
  final Color iconColor;
  final int badgeCount;
  final VoidCallback onTap;

  const DashboardModuleCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.badgeCount = 0,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
