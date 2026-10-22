import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/transport_location_request_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/transport_controller.dart';

class TransportRequestDetailScreen extends StatefulWidget {
  final int requestId;

  const TransportRequestDetailScreen({
    super.key,
    required this.requestId,
  });

  @override
  State<TransportRequestDetailScreen> createState() => _TransportRequestDetailScreenState();
}

class _TransportRequestDetailScreenState extends State<TransportRequestDetailScreen> {
  final TransportController _controller = TransportController.to;

  @override
  void initState() {
    super.initState();
    _controller.fetchLocationRequestDetail(widget.requestId);
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
                          'REQUEST DETAILS',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
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
              // MAIN CONTENT
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isDetailLoading.value && _controller.requestDetail.value == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4E54C8),
                      ),
                    );
                  }

                  if (_controller.detailErrorMessage.value.isNotEmpty && _controller.requestDetail.value == null) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.detailErrorMessage.value);
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
                              isNetErr ? 'No Internet Connection' : 'Failed to Load Request Details',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _controller.detailErrorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchLocationRequestDetail(widget.requestId),
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

                  final detail = _controller.requestDetail.value;
                  if (detail == null) {
                    return Center(
                      child: Text(
                        'No request data found',
                        style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF4E54C8),
                    onRefresh: () => _controller.fetchLocationRequestDetail(widget.requestId, isManualRefresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. STATUS & OVERVIEW CARD
                          _buildStatusOverviewCard(detail),
                          const SizedBox(height: 12),

                          // 2. STUDENT DETAILS CARD
                          _buildStudentInfoCard(detail.student),
                          const SizedBox(height: 12),

                          // 3. REQUESTER & PARENT DETAILS CARD
                          _buildRequesterCard(detail),
                          const SizedBox(height: 12),

                          // 4. TRANSPORT DETAILS CARD
                          _buildTransportCard(detail.transport),
                          const SizedBox(height: 12),

                          // 5. CURRENT VS PROPOSED LOCATION CARD
                          _buildLocationComparisonCard(detail.oldCoordinates, detail.proposedCoordinates, detail.addressNotes),
                          const SizedBox(height: 12),

                          // 6. AUDIT & DECISION INFO CARD (IF ANY)
                          if (detail.actionByName != null || detail.rejectionReason != null) ...[
                            _buildAuditCard(detail),
                            const SizedBox(height: 12),
                          ],

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Obx(() {
        final detail = _controller.requestDetail.value;
        if (detail == null || detail.status.toLowerCase() != 'pending') {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.isActionLoading.value
                        ? null
                        : () => _showRejectDialog(detail.id, detail.student?.name ?? 'Student'),
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                    label: Text(
                      'Reject',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _controller.isActionLoading.value
                        ? null
                        : () => _showApproveConfirmation(detail.id, detail.student?.name ?? 'Student'),
                    icon: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    label: Text(
                      'Approve',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildStatusOverviewCard(TransportLocationRequestDetailItem detail) {
    final status = detail.status.toLowerCase();
    Color statusBg = const Color(0xFFFFFBEB);
    Color statusBorder = const Color(0xFFFDE68A);
    Color statusColor = const Color(0xFFD97706);

    if (status == 'approved') {
      statusBg = const Color(0xFFECFDF5);
      statusBorder = const Color(0xFFA7F3D0);
      statusColor = const Color(0xFF059669);
    } else if (status == 'rejected') {
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusColor = const Color(0xFFDC2626);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Request ID: ${detail.id}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusBorder),
                ),
                child: Text(
                  detail.statusLabel,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildInfoRow('Location Change Type', detail.locationType?.toUpperCase() ?? 'N/A'),
          const SizedBox(height: 6),
          _buildInfoRow('Requested Via', detail.requestedVia?.replaceAll('_', ' ').toUpperCase() ?? 'N/A'),
          if (detail.requestedAt != null) ...[
            const SizedBox(height: 6),
            _buildInfoRow('Requested Date & Time', detail.requestedAt!),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentInfoCard(TransportStudentInfo? student) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Student Information',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildInfoRow('Student Name', student?.name ?? 'N/A'),
          const SizedBox(height: 6),
          _buildInfoRow('Class & Section', student?.fullClassSection ?? 'N/A'),
          const SizedBox(height: 6),
          _buildInfoRow('Student Unique ID', student?.uniqueId ?? 'N/A'),
          if (student?.parentPhone != null && student!.parentPhone!.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildInfoRow('Parent Phone', student.parentPhone!),
          ],
        ],
      ),
    );
  }

  Widget _buildRequesterCard(TransportLocationRequestDetailItem detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_pin_rounded, color: Color(0xFF2563EB), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Requester Information',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildInfoRow('Requested By', detail.requestedByName ?? 'N/A'),
          const SizedBox(height: 6),
          _buildInfoRow('Role', detail.requestedByRole ?? 'Parent'),
        ],
      ),
    );
  }

  Widget _buildTransportCard(TransportInfo? transport) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F9FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus_rounded, color: Color(0xFF0284C7), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Current Bus & Route Info',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          _buildInfoRow('Bus Number', transport?.busNumber ?? 'N/A'),
          const SizedBox(height: 6),
          _buildInfoRow('Route Name', transport?.routeName ?? 'N/A'),
          const SizedBox(height: 6),
          _buildInfoRow('Current Stoppage', transport?.stoppageName ?? 'N/A'),
        ],
      ),
    );
  }

  Widget _buildLocationComparisonCard(
    TransportCoordinates? oldCoord,
    TransportCoordinates? proposedCoord,
    String? addressNotes,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.add_location_alt_rounded, color: Color(0xFFEA580C), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Location & Address Details',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // Current Location
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
                    const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      'Current Address',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  oldCoord?.address ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                if (oldCoord?.pickupLatitude != null && oldCoord?.pickupLongitude != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Coordinates: (${oldCoord!.pickupLatitude}, ${oldCoord.pickupLongitude})',
                    style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF64748B)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Proposed Location
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.my_location_rounded, size: 16, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 6),
                    Text(
                      'Proposed New Address',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4F46E5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  proposedCoord?.address ?? 'N/A',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1E1B4B),
                  ),
                ),
                if (proposedCoord?.pickupLatitude != null && proposedCoord?.pickupLongitude != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Coordinates: (${proposedCoord!.pickupLatitude}, ${proposedCoord.pickupLongitude})',
                    style: GoogleFonts.poppins(fontSize: 10.5, color: const Color(0xFF6366F1)),
                  ),
                ],
              ],
            ),
          ),

          // Notes / Reason
          if ((proposedCoord?.notes != null && proposedCoord!.notes!.isNotEmpty) ||
              (addressNotes != null && addressNotes.isNotEmpty)) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.note_alt_outlined, size: 16, color: Color(0xFFD97706)),
                      const SizedBox(width: 6),
                      Text(
                        'Reason / Address Notes',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    proposedCoord?.notes ?? addressNotes ?? 'N/A',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAuditCard(TransportLocationRequestDetailItem detail) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF475569), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Action & Decision Audit',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          if (detail.actionByName != null) ...[
            _buildInfoRow('Action By', '${detail.actionByName} (${detail.actionByRole ?? ''})'),
            const SizedBox(height: 6),
          ],
          if (detail.actionViaLabel != null || detail.actionVia != null) ...[
            _buildInfoRow('Action Channel', detail.actionViaLabel ?? detail.actionVia ?? 'N/A'),
            const SizedBox(height: 6),
          ],
          if (detail.actionAt != null) ...[
            _buildInfoRow('Action Time', detail.actionAt!),
            const SizedBox(height: 6),
          ],
          if (detail.rejectionReason != null && detail.rejectionReason!.isNotEmpty)
            _buildInfoRow('Rejection Reason', detail.rejectionReason!, valueColor: const Color(0xFFDC2626)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 130,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  void _showApproveConfirmation(int requestId, String studentName) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Approve Request?',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
        content: Text(
          'Are you sure you want to approve doorstep GPS location change request for $studentName?',
          style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          Obx(() => ElevatedButton(
                onPressed: _controller.isActionLoading.value
                    ? null
                    : () async {
                        Navigator.pop(ctx);
                        await _controller.approveLocationRequest(requestId);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _controller.isActionLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );
  }

  void _showRejectDialog(int requestId, String studentName) {
    final reasonController = TextEditingController(
      text: 'Proposed location pin is outside bus route boundary.',
    );
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reject Request?',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter reason for rejecting location request for $studentName:',
              style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason',
                hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                contentPadding: const EdgeInsets.all(10),
              ),
              style: GoogleFonts.poppins(fontSize: 12.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.poppins(color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          Obx(() => ElevatedButton(
                onPressed: _controller.isActionLoading.value
                    ? null
                    : () async {
                        final reason = reasonController.text.trim();
                        if (reason.isEmpty) {
                          AppSnackbar.showError(
                            title: 'Reason Required',
                            message: 'Please enter rejection reason',
                          );
                          return;
                        }
                        Navigator.pop(ctx);
                        await _controller.rejectLocationRequest(requestId, reason: reason);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDC2626),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: _controller.isActionLoading.value
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
        ],
      ),
    );
  }
}
