import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/transport_halt_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../view_models/get_x/transport_controller.dart';

class TransportHaltScreen extends StatefulWidget {
  const TransportHaltScreen({super.key});

  @override
  State<TransportHaltScreen> createState() => _TransportHaltScreenState();
}

class _TransportHaltScreenState extends State<TransportHaltScreen> {
  final TransportController _controller = TransportController.to;

  @override
  void initState() {
    super.initState();
    _controller.fetchTransportHalts();
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
                          'VEHICLE HALTS & ALERTS',
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
                  if (_controller.isHaltsLoading.value && _controller.haltsList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4E54C8),
                      ),
                    );
                  }

                  if (_controller.haltsErrorMessage.value.isNotEmpty && _controller.haltsList.isEmpty) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.haltsErrorMessage.value);
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
                              isNetErr ? 'No Internet Connection' : 'Failed to Load Vehicle Halts',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _controller.haltsErrorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchTransportHalts(),
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

                  final halts = _controller.haltsList;
                  final ongoingCount = halts.where((h) => h.isOngoing).length;

                  return RefreshIndicator(
                    color: const Color(0xFF4E54C8),
                    onRefresh: () => _controller.fetchTransportHalts(isManualRefresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          // SUMMARY SECTION
                          _buildHaltSummaryCard(halts.length, ongoingCount),
                          const SizedBox(height: 14),

                          // HALTED LIST HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'ACTIVE & RECENT HALTS',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '${halts.length} Items',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (halts.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(28),
                              margin: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.check_circle_outline_rounded, size: 48, color: Color(0xFF10B981)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No Active Halts or Alerts',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'All fleet buses are operating smoothly without active halts or emergency alerts.',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            )
                          else
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: halts.length,
                              itemBuilder: (context, index) {
                                final item = halts[index];
                                return _buildHaltCard(item);
                              },
                            ),

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
    );
  }

  Widget _buildHaltSummaryCard(int total, int ongoing) {
    return Container(
      padding: const EdgeInsets.all(14),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vehicle Halts Overview',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Live active halts & emergency alerts',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Total Halts',
                  value: '$total',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Ongoing Halts',
                  value: '$ongoing',
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Completed',
                  value: '${total - ongoing}',
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBadge({
    required String title,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHaltCard(TransportHaltItem item) {
    final bus = item.bus;
    final trip = item.trip;
    final location = item.location;

    final isOngoing = item.isOngoing;
    final durationText = item.durationFormatted ?? (isOngoing ? 'Ongoing' : 'Completed');
    final haltReason = item.reason ?? 'Vehicle Halted / Emergency';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFEDD5)),
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
          // ----------------- BUS & STATUS HEADER -----------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.report_problem_rounded, color: Color(0xFFDC2626), size: 24),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        Text(
                          bus?.busNumber ?? 'Bus',
                          style: GoogleFonts.poppins(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        if (bus?.plateNumber != null && bus!.plateNumber!.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              bus.plateNumber!,
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (trip?.routeName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        trip!.routeName!,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isOngoing ? const Color(0xFFFEF2F2) : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isOngoing ? const Color(0xFFFECACA) : const Color(0xFFA7F3D0)),
                ),
                child: Text(
                  isOngoing ? 'ONGOING' : 'COMPLETED',
                  style: GoogleFonts.poppins(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isOngoing ? const Color(0xFFDC2626) : const Color(0xFF059669),
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // ----------------- HALT REASON & DURATION -----------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HALT REASON / EMERGENCY',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFC2410C),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEA580C),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        durationText,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  haltReason,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF9A3412),
                  ),
                ),
                if (item.startedAtTime != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Started At: ${item.startedAtTime}',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFFC2410C),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ----------------- DRIVER DETAILS -----------------
          if (trip?.driverName != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_pin_rounded, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: 'Driver: ',
                            style: GoogleFonts.poppins(fontSize: 11, color: const Color(0xFF64748B)),
                          ),
                          TextSpan(
                            text: trip!.driverName!,
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (trip.driverPhone != null && trip.driverPhone!.isNotEmpty) ...[
                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF0284C7)),
                    const SizedBox(width: 4),
                    Text(
                      trip.driverPhone!,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0284C7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // ----------------- LOCATION AT HALT -----------------
          if (location != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (location.address != null && location.address!.isNotEmpty)
                  Expanded(
                    child: Text(
                      'Address: ${location.address}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                if (location.latitude != null && location.longitude != null)
                  Text(
                    'GPS: (${location.latitude}, ${location.longitude})',
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: const Color(0xFF4F46E5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
