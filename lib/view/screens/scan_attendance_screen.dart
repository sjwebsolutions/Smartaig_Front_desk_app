import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/scan_attendance_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../view_models/get_x/scan_attendance_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';
import 'qr_attendance_scanner_screen.dart';

class ScanAttendanceScreen extends StatefulWidget {
  const ScanAttendanceScreen({super.key});

  @override
  State<ScanAttendanceScreen> createState() => _ScanAttendanceScreenState();
}

class _ScanAttendanceScreenState extends State<ScanAttendanceScreen> {
  final ScanAttendanceController _controller = Get.put(ScanAttendanceController());
  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    UnreadCounterController.to.reloadCounters();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _handleSubmitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) return;

    final success = await _controller.markScanAttendance(code);
    if (success) {
      _codeController.clear();
      _codeFocusNode.requestFocus();
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
              Color(0xFFD1E9FF), // Vibrant Light Blue
              Color(0xFFE9D5FF), // Vibrant Light Purple
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 30, minHeight: 30),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => Get.back(),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'SCAN ATTENDANCE',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 1.1,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer to balance back icon
                  ],
                ),
              ),

              // -------------------------------------------------
              // SUMMARY STATS OVERVIEW CARD
              // -------------------------------------------------
              Obx(() => _buildSummaryCard()),

              const SizedBox(height: 6),

              // -------------------------------------------------
              // SCANNER / INPUT CONTROL CARD
              // -------------------------------------------------
              _buildScanInputCard(),

              const SizedBox(height: 6),

              // -------------------------------------------------
              // LAST SCANNED RESULT POPUP/BANNER
              // -------------------------------------------------
              Obx(() {
                final lastRec = _controller.lastScannedRecord.value;
                if (lastRec == null) return const SizedBox.shrink();
                return _buildLastScannedCard(lastRec);
              }),

              // -------------------------------------------------
              // LOGS FILTER TABS
              // -------------------------------------------------
              Obx(() => _buildLogsFilterTabs()),

              const SizedBox(height: 4),

              // -------------------------------------------------
              // MAIN LIST / STATES
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value && _controller.scanLogs.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF16A34A)),
                    );
                  }

                  if (_controller.errorMessage.value.isNotEmpty && _controller.scanLogs.isEmpty) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.errorMessage.value);
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: isNetErr ? const Color(0xFFFFF7ED) : const Color(0xFFFEF2F2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isNetErr ? Icons.wifi_off_rounded : Icons.error_outline_rounded,
                                color: isNetErr ? const Color(0xFFEA580C) : const Color(0xFFD32F2F),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              isNetErr ? 'No Internet Connection' : 'Oops! Something went wrong',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchScanLogs(),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                              label: Text('Retry', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = _controller.filteredLogs;

                  if (list.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: const BoxDecoration(
                                color: Color(0xFFDCFCE7),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.qr_code_scanner_rounded,
                                color: Color(0xFF16A34A),
                                size: 42,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No Attendance Scans Yet',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use the scan input above to mark attendance.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                            if (_controller.selectedFilter.value != 'all') ...[
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _controller.changeFilter('all');
                                },
                                icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                                label: Text('Clear Filters', style: GoogleFonts.poppins(fontSize: 12)),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF16A34A),
                    onRefresh: () async => _controller.fetchScanLogs(isManualRefresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 20),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        return _buildAttendanceCard(list[index]);
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // 1. SUMMARY STATS CARD
  // -------------------------------------------------
  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStatItem(
            label: 'Total Scans',
            count: _controller.totalScans.value,
            color: const Color(0xFF16A34A),
            bgColor: const Color(0xFFDCFCE7),
            icon: Icons.qr_code_2_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Students',
            count: _controller.studentScans.value,
            color: const Color(0xFF2563EB),
            bgColor: const Color(0xFFEFF6FF),
            icon: Icons.school_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Teachers',
            count: _controller.teacherScans.value,
            color: const Color(0xFFD97706),
            bgColor: const Color(0xFFFFFBEB),
            icon: Icons.person_search_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Check-In',
            count: _controller.checkInsCount.value,
            color: const Color(0xFF0D9488),
            bgColor: const Color(0xFFCCFBF1),
            icon: Icons.login_rounded,
          ),
          _buildStatDivider(),
          _buildStatItem(
            label: 'Check-Out',
            count: _controller.checkOutsCount.value,
            color: const Color(0xFFDC2626),
            bgColor: const Color(0xFFFEF2F2),
            icon: Icons.logout_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required int count,
    required Color color,
    required Color bgColor,
    required IconData icon,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(3.5),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 12, color: color),
              ),
              const SizedBox(width: 4),
              Text(
                '$count',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      height: 24,
      width: 1,
      color: const Color(0xFFE2E8F0),
      margin: const EdgeInsets.symmetric(horizontal: 2),
    );
  }

  // -------------------------------------------------
  // 2. SCAN INPUT PANEL CARD
  // -------------------------------------------------
  Widget _buildScanInputCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mode Toggles: Attendance Type & User Type Selection
          Row(
            children: [
              // Attendance Action Mode Toggle (Auto / Check-In / Check-Out)
              Expanded(
                flex: 3,
                child: Obx(() {
                  final current = _controller.selectedAttendanceMode.value;
                  return Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildSubTab(
                          label: 'Auto',
                          isSelected: current == 'auto',
                          activeColor: const Color(0xFF16A34A),
                          onTap: () => _controller.changeAttendanceMode('auto'),
                        ),
                        _buildSubTab(
                          label: 'In',
                          isSelected: current == 'check_in',
                          activeColor: const Color(0xFF2563EB),
                          onTap: () => _controller.changeAttendanceMode('check_in'),
                        ),
                        _buildSubTab(
                          label: 'Out',
                          isSelected: current == 'check_out',
                          activeColor: const Color(0xFFDC2626),
                          onTap: () => _controller.changeAttendanceMode('check_out'),
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),

              // User Type Selection
              Expanded(
                flex: 2,
                child: Obx(() {
                  final currentType = _controller.selectedUserType.value;
                  return Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildSubTab(
                          label: 'All',
                          isSelected: currentType == 'all',
                          activeColor: const Color(0xFF475569),
                          onTap: () => _controller.changeUserType('all'),
                        ),
                        _buildSubTab(
                          label: 'Student',
                          isSelected: currentType == 'student',
                          activeColor: const Color(0xFF2563EB),
                          onTap: () => _controller.changeUserType('student'),
                        ),
                        _buildSubTab(
                          label: 'Teacher',
                          isSelected: currentType == 'teacher',
                          activeColor: const Color(0xFFD97706),
                          onTap: () => _controller.changeUserType('teacher'),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Code Input Field with QR Scan Button & Submit Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  textInputAction: TextInputAction.go,
                  onSubmitted: (_) => _handleSubmitCode(),
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Enter/Scan Code or QR ID...',
                    hintStyle: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    prefixIcon: const Icon(Icons.center_focus_weak_rounded, color: Color(0xFF16A34A), size: 20),
                    suffixIcon: _codeController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, size: 18, color: Color(0xFF94A3B8)),
                            onPressed: () {
                              setState(() {
                                _codeController.clear();
                              });
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: Color(0xFF16A34A)),
                            onPressed: () => Get.to(() => const QrAttendanceScannerScreen()),
                            tooltip: 'Open Camera QR Scanner',
                          ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(width: 8),
              Obx(() => ElevatedButton(
                    onPressed: _controller.isSubmitting.value ? null : _handleSubmitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF16A34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: _controller.isSubmitting.value
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'MARK',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                            ),
                          ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubTab({
    required String label,
    required bool isSelected,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(6),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------
  // 3. LAST SCANNED RESULT CARD
  // -------------------------------------------------
  Widget _buildLastScannedCard(AttendanceRecordItem record) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: record.isCheckIn ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: record.isCheckIn ? const Color(0xFFBBF7D0) : const Color(0xFFFECACA),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: record.isCheckIn ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
            child: Icon(
              record.isCheckIn ? Icons.check_circle_rounded : Icons.logout_rounded,
              color: record.isCheckIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'INSTANT MARKED',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: record.isCheckIn ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: record.isCheckIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.isCheckIn ? 'CHECK IN' : 'CHECK OUT',
                        style: GoogleFonts.poppins(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  record.name ?? 'Unknown',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  '${record.subInfo} • ${record.time ?? "Just now"}',
                  style: GoogleFonts.poppins(fontSize: 10, color: const Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
            onPressed: () => _controller.clearLastScannedRecord(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------
  // 4. LOGS FILTER TABS
  // -------------------------------------------------
  Widget _buildLogsFilterTabs() {
    final filters = [
      {'label': 'All Logs', 'key': 'all', 'color': const Color(0xFF16A34A)},
      {'label': 'Students', 'key': 'student', 'color': const Color(0xFF2563EB)},
      {'label': 'Teachers', 'key': 'teacher', 'color': const Color(0xFFD97706)},
      {'label': 'Check-In', 'key': 'check_in', 'color': const Color(0xFF0D9488)},
      {'label': 'Check-Out', 'key': 'check_out', 'color': const Color(0xFFDC2626)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      child: Row(
        children: filters.map((f) {
          final label = f['label'] as String;
          final key = f['key'] as String;
          final color = f['color'] as Color;
          final isSelected = _controller.selectedFilter.value == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              showCheckmark: false,
              selected: isSelected,
              label: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                child: Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : color,
                  ),
                ),
              ),
              selectedColor: color,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? color : color.withValues(alpha: 0.35),
                  width: 1.2,
                ),
              ),
              onSelected: (_) => _controller.changeFilter(key),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------
  // 5. ATTENDANCE ITEM CARD
  // -------------------------------------------------
  Widget _buildAttendanceCard(AttendanceRecordItem item) {
    final isCheckIn = item.isCheckIn;
    final statusColor = isCheckIn ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    final statusBg = isCheckIn ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2);
    final isStudent = item.userType?.toLowerCase() == 'student';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: isStudent ? const Color(0xFFEFF6FF) : const Color(0xFFFFFBEB),
              backgroundImage: item.avatar != null && item.avatar!.isNotEmpty
                  ? NetworkImage(item.avatar!)
                  : null,
              child: item.avatar == null || item.avatar!.isEmpty
                  ? Icon(
                      isStudent ? Icons.school_rounded : Icons.person_rounded,
                      color: isStudent ? const Color(0xFF2563EB) : const Color(0xFFD97706),
                      size: 20,
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subInfo,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  if (item.code != null && item.code!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Code: ${item.code}',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCheckIn ? Icons.login_rounded : Icons.logout_rounded,
                        size: 11,
                        color: statusColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        isCheckIn ? 'Check In' : 'Check Out',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.time ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
