import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/gate_pass_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/gate_pass_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';

class GetPassScreen extends StatefulWidget {
  final bool showBackButton;
  const GetPassScreen({super.key, this.showBackButton = false});

  @override
  State<GetPassScreen> createState() => _GetPassScreenState();
}

class _GetPassScreenState extends State<GetPassScreen> {
  final GatePassController _controller = Get.put(GatePassController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    UnreadCounterController.to.clearGatePass();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    if (widget.showBackButton && Navigator.canPop(context)) ...[
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
                    ],
                    Expanded(
                      child: Center(
                        child: Text(
                          'GATE PASSES',
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
                    if (widget.showBackButton && Navigator.canPop(context))
                      const SizedBox(width: 30), // Balance spacing
                  ],
                ),
              ),

              // -------------------------------------------------
              // STATUS FILTER CHIPS
              // -------------------------------------------------
              Obx(() => _buildStatusFilterTabs()),

              const SizedBox(height: 6),

              // -------------------------------------------------
              // SEARCH BAR
              // -------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Container(
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
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      _controller.searchQuery.value = val;
                    },
                    style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1E293B)),
                    decoration: InputDecoration(
                      hintText: 'Search by Pass No, Student, Guardian...',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0D9488), size: 22),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Color(0xFF94A3B8), size: 18),
                              onPressed: () {
                                _searchController.clear();
                                _controller.searchQuery.value = '';
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // -------------------------------------------------
              // MAIN LIST
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value && _controller.gatePassList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF0D9488)),
                    );
                  }

                  if (_controller.errorMessage.value.isNotEmpty && _controller.gatePassList.isEmpty) {
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
                            const SizedBox(height: 14),
                            Text(
                              isNetErr ? 'No Internet Connection' : 'Failed to load Gate Passes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
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
                              onPressed: () => _controller.fetchGatePasses(isRefresh: true),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                              label: Text(
                                isNetErr ? 'Retry Connection' : 'Retry',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0D9488),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = _controller.filteredGatePasses;

                  if (list.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.badge_outlined, size: 50, color: Color(0xFF0D9488)),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No Gate Passes Found',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'There are currently no gate pass records under this filter.',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF0D9488),
                    onRefresh: () => _controller.fetchGatePasses(isRefresh: true),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 90),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final item = list[index];
                        return _buildGatePassCard(context, item);
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
  // STATUS FILTER CHIPS
  // -------------------------------------------------
  Widget _buildStatusFilterTabs() {
    final selected = _controller.selectedStatus.value;

    final tabs = [
      {'id': 'pending', 'label': 'Pending', 'color': const Color(0xFFD97706)},
      {'id': 'approved', 'label': 'Approved', 'color': const Color(0xFF059669)},
      {'id': 'rejected', 'label': 'Rejected', 'color': const Color(0xFFDC2626)},
      {'id': 'all', 'label': 'All', 'color': const Color(0xFF0D9488)},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: tabs.map((tab) {
          final id = tab['id'] as String;
          final label = tab['label'] as String;
          final color = tab['color'] as Color;
          final isSelected = selected == id;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              showCheckmark: false,
              label: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF334155),
                ),
              ),
              selectedColor: color,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected ? color : Colors.white,
                  width: 1,
                ),
              ),
              elevation: isSelected ? 2 : 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              onSelected: (_) => _controller.filterByStatus(id),
            ),
          );
        }).toList(),
      ),
    );
  }

  // -------------------------------------------------
  // GATE PASS CARD ITEM
  // -------------------------------------------------
  Widget _buildGatePassCard(BuildContext context, GatePassItem item) {
    final passNo = item.gatePassNo ?? 'N/A';
    final status = (item.status ?? 'pending').toLowerCase();
    final studentName = item.student?.name ?? 'Student Name N/A';
    final className = item.student?.className ?? '';
    final sectionName = item.student?.sectionName ?? '';
    final rollNo = item.student?.rollNo ?? '';
    final guardianName = item.guardian?.personName ?? 'Guardian N/A';
    final relation = item.guardian?.relation ?? '';
    final contactNo = item.guardian?.contactNo ?? '';
    final reason = item.reason ?? 'No reason specified';
    final date = item.date ?? '';
    final time = item.time ?? item.exitTime ?? '';
    final createdBy = item.createdBy ?? '';

    Color statusBg;
    Color statusTextColor;
    BorderSide statusBorder;
    String statusDisplay;

    switch (status) {
      case 'approved':
        statusBg = const Color(0xFFECFDF5);
        statusTextColor = const Color(0xFF059669);
        statusBorder = const BorderSide(color: Color(0xFFA7F3D0));
        statusDisplay = 'APPROVED';
        break;
      case 'rejected':
        statusBg = const Color(0xFFFEF2F2);
        statusTextColor = const Color(0xFFDC2626);
        statusBorder = const BorderSide(color: Color(0xFFFECACA));
        statusDisplay = 'REJECTED';
        break;
      default:
        statusBg = const Color(0xFFFFFBEB);
        statusTextColor = const Color(0xFFD97706);
        statusBorder = const BorderSide(color: Color(0xFFFDE68A));
        statusDisplay = 'PENDING';
        break;
    }

    final isCallDisabled = status == 'approved' || status == 'rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------- Header: Status Badge & Pass No -----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.fromBorderSide(statusBorder),
                  ),
                  child: Text(
                    statusDisplay,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    passNo,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D9488),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ----------------- Student Details -----------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCCFBF1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.school_rounded, color: Color(0xFF0D9488), size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Class: $className${sectionName.isNotEmpty ? ' ($sectionName)' : ''}${rollNo.isNotEmpty ? ' | Roll: $rollNo' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
            ),

            // ----------------- Guardian Info & Call Action -----------------
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Guardian / Relative',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$guardianName${relation.isNotEmpty ? ' ($relation)' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF334155),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (contactNo.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          '+91 $contactNo',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (contactNo.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: isCallDisabled ? null : () => _makePhoneCall(contactNo),
                    icon: Icon(
                      Icons.call_rounded,
                      size: 16,
                      color: isCallDisabled ? const Color(0xFF94A3B8) : Colors.white,
                    ),
                    label: Text(
                      'Call',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isCallDisabled ? const Color(0xFF94A3B8) : Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCallDisabled ? const Color(0xFFE2E8F0) : const Color(0xFF10B981),
                      disabledBackgroundColor: const Color(0xFFE2E8F0),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // ----------------- Reason Box -----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
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
                      const Icon(Icons.assignment_outlined, size: 14, color: Color(0xFF0D9488)),
                      const SizedBox(width: 6),
                      Text(
                        'Reason for Exit:',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0D9488),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reason,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ----------------- Date, Time & Created By -----------------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(
                      '$date $time'.trim(),
                      style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                    ),
                  ],
                ),
                if (createdBy.isNotEmpty)
                  Text(
                    'Created: $createdBy',
                    style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF94A3B8)),
                  ),
              ],
            ),

            // ----------------- Action Buttons (Equal width & confirmation dialog) -----------------
            if (status == 'pending' && item.id != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showApprovalConfirmDialog(context, item.id!, isApprove: false),
                      icon: const Icon(Icons.close_rounded, size: 16, color: Color(0xFFDC2626)),
                      label: Text(
                        'Reject',
                        style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFFDC2626), fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFDC2626)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _showApprovalConfirmDialog(context, item.id!, isApprove: true),
                      icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
                      label: Text(
                        'Approve',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF059669),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showApprovalConfirmDialog(BuildContext context, int gatePassId, {required bool isApprove}) {
    final actionTitle = isApprove ? 'Approve' : 'Reject';
    final themeColor = isApprove ? const Color(0xFF059669) : const Color(0xFFDC2626);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: themeColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isApprove ? Icons.check_circle_outline_rounded : Icons.cancel_outlined,
                  color: themeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Confirm $actionTitle',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to $actionTitle.toLowerCase() Gate Pass #$gatePassId?',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Obx(() => ElevatedButton(
                  onPressed: _controller.isUpdatingStatus.value
                      ? null
                      : () async {
                          bool success;
                          if (isApprove) {
                            success = await _controller.approvePass(gatePassId);
                          } else {
                            success = await _controller.rejectPass(gatePassId);
                          }
                          if (success && dialogCtx.mounted) {
                            Navigator.pop(dialogCtx);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _controller.isUpdatingStatus.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Confirm',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                )),
          ],
        );
      },
    );
  }

  Future<void> _makePhoneCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) return;
    final url = Uri.parse('tel:$clean');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(
          title: 'Dialer Error',
          message: 'Could not open phone dialer for $phone',
        );
      }
    } catch (e) {
      AppSnackbar.showError(
        title: 'Dialer Error',
        message: 'Could not open phone dialer for $phone',
      );
    }
  }
}
