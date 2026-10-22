import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../Widgets/custom_shimmer.dart';
import '../../Widgets/menu.dart';
import '../../Widgets/modules.dart';
import '../../models/dashboard_model.dart';
import '../../services/app_update_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../view_models/get_x/dashboard_controller.dart';
import '../../view_models/get_x/notification_history_controller.dart';
import '../../view_models/get_x/policies_controller.dart';
import '../../view_models/get_x/support_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';
import 'notification_list_screen.dart';

class FrontDeskDashboard extends StatefulWidget {
  const FrontDeskDashboard({super.key});

  @override
  State<FrontDeskDashboard> createState() => _FrontDeskDashboardState();
}

class _FrontDeskDashboardState extends State<FrontDeskDashboard> {
  final DashboardController _controller = Get.put(DashboardController());

  @override
  void initState() {
    super.initState();
    Get.put(SupportController());
    Get.put(PoliciesController());
    UnreadCounterController.to.reloadCounters();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateService.checkForUpdates();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawerEnableOpenDragGesture: false,
      drawer: const DashboardDrawer(),
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
              return const DashboardShimmerSkeleton();
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
            final studentLeaves = data?.studentLeaves;
            final teacherLeaves = data?.teacherLeaves;
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),
                          // 1. STAFF PROFILE CARD
                          _buildStaffProfileCard(staff, school),
                          const SizedBox(height: 10),

                          // 2. TODAY'S OVERVIEW / STATS
                          if (todayInfo != null || todayStats != null) ...[
                            _buildTodayStatsSection(todayInfo, todayStats),
                            const SizedBox(height: 10),
                          ],

                          // 3. CALLBACK REQUESTS OVERVIEW
                          if (callbackRequests != null &&
                              ((callbackRequests.pending ?? 0) > 0 || (callbackRequests.inProgress ?? 0) > 0)) ...[
                            _buildCallbackRequestsCard(callbackRequests),
                            const SizedBox(height: 10),
                          ],

                          // 4. STUDENT & TEACHER LEAVE REQUESTS OVERVIEW
                          if (studentLeaves != null &&
                              ((studentLeaves.totalPendingCount ?? 0) > 0 || (studentLeaves.todayPendingCount ?? 0) > 0)) ...[
                            _buildLeaveRequestsCard(
                              title: 'Student Leaves Overview',
                              icon: Icons.event_note_rounded,
                              iconBgColor: const Color(0xFFFFE4E6),
                              iconColor: const Color(0xFFE11D48),
                              leaveStats: studentLeaves,
                              unreadCount: UnreadCounterController.to.studentLeaveCount.value,
                            ),
                            const SizedBox(height: 10),
                          ],

                          if (teacherLeaves != null &&
                              ((teacherLeaves.totalPendingCount ?? 0) > 0 || (teacherLeaves.todayPendingCount ?? 0) > 0)) ...[
                            _buildLeaveRequestsCard(
                              title: 'Teacher Leaves Overview',
                              icon: Icons.assignment_ind_rounded,
                              iconBgColor: const Color(0xFFE0F2FE),
                              iconColor: const Color(0xFF0284C7),
                              leaveStats: teacherLeaves,
                              unreadCount: UnreadCounterController.to.teacherLeaveCount.value,
                            ),
                            const SizedBox(height: 10),
                          ],

                            // 5. FRONT DESK MODULES
                            const DashboardModulesWidget(),
                            const SizedBox(height: 90),
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



  // -------------------------------------------------
  // 1. STAFF PROFILE CARD
  // -------------------------------------------------
  Widget _buildStaffProfileCard(DashboardStaff? staff, DashboardSchool? school) {
    final image = staff?.image;
    final thumb = staff?.thumbnail;
    final imageUrl = (image != null && image.isNotEmpty)
        ? image
        : (thumb != null && thumb.isNotEmpty)
            ? thumb
            : null;
    final staffId = staff?.teacherUniqueId ?? staff?.id?.toString() ?? 'N/A';
    final role = staff?.role ?? staff?.designation ?? staff?.staffType;
    final status = staff?.status;
    final isActive = status == '1' || status?.toLowerCase() == 'active';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 62,
              height: 62,
              color: const Color(0xFFE8EAF6),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      key: ValueKey(imageUrl),
                      width: 62,
                      height: 62,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.person, size: 34, color: Color(0xFF4E54C8)),
                        );
                      },
                    )
                  : const Center(
                      child: Icon(Icons.person, size: 34, color: Color(0xFF4E54C8)),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: staff?.name ?? 'Staff Member',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
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
                                  width: 16,
                                  height: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        softWrap: true,
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
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: school.name!,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
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
                              width: 14,
                              height: 14,
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
  // 4. LEAVE REQUESTS CARD (STUDENT & TEACHER LEAVES)
  // -------------------------------------------------
  Widget _buildLeaveRequestsCard({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required LeaveStats leaveStats,
    required int unreadCount,
  }) {
    final totalPending = leaveStats.totalPendingCount ?? 0;
    final todayPending = leaveStats.todayPendingCount ?? 0;

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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 15,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
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
              Expanded(
                child: _buildCallbackStatItem(
                  count: totalPending,
                  label: 'Total Pending',
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
              Expanded(
                child: _buildCallbackStatItem(
                  count: todayPending,
                  label: "Today's Pending",
                  icon: Icons.today_rounded,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


}


