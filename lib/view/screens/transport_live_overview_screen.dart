import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/transport_live_overview_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../view_models/get_x/transport_controller.dart';

class TransportLiveOverviewScreen extends StatefulWidget {
  const TransportLiveOverviewScreen({super.key});

  @override
  State<TransportLiveOverviewScreen> createState() => _TransportLiveOverviewScreenState();
}

class _TransportLiveOverviewScreenState extends State<TransportLiveOverviewScreen> {
  final TransportController _controller = TransportController.to;

  @override
  void initState() {
    super.initState();
    _controller.fetchLiveOverview();
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
                          'LIVE LOCATION',
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
              // MAIN CONTENT
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isLiveLoading.value && _controller.fleetList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4E54C8),
                      ),
                    );
                  }

                  if (_controller.liveErrorMessage.value.isNotEmpty && _controller.fleetList.isEmpty) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.liveErrorMessage.value);
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
                              isNetErr ? 'No Internet Connection' : 'Failed to Load Live Overview',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _controller.liveErrorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: const Color(0xFF64748B),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchLiveOverview(),
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

                  final summary = _controller.liveSummary.value;
                  final fleet = _controller.fleetList;

                  return RefreshIndicator(
                    color: const Color(0xFF4E54C8),
                    onRefresh: () => _controller.fetchLiveOverview(isManualRefresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),

                          // 1. SUMMARY CARDS
                          if (summary != null) ...[
                            _buildSummaryCard(summary),
                            const SizedBox(height: 14),
                          ],

                          // 2. FLEET LIST HEADER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FLEET BUSES & TRIPS',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2C3E50),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                '${fleet.length} Vehicles',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          if (fleet.isEmpty)
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
                                  const Icon(Icons.directions_bus_outlined, size: 48, color: Color(0xFF94A3B8)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No Live Bus Fleet Found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'There are currently no active buses or fleet records.',
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
                              itemCount: fleet.length,
                              itemBuilder: (context, index) {
                                final item = fleet[index];
                                return _buildFleetCard(item);
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

  Widget _buildSummaryCard(TransportLiveOverviewSummary summary) {
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gps_fixed_rounded, color: Color(0xFF059669), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Fleet Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    if (summary.updatedAt != null)
                      Text(
                        'Updated: ${summary.updatedAt}',
                        style: GoogleFonts.poppins(
                          fontSize: 10.5,
                          color: const Color(0xFF64748B),
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
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF059669),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'LIVE GPS',
                      style: GoogleFonts.poppins(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
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
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),

          // ----------------- ROW 1: TOTAL BUSES & ACTIVE TRIPS -----------------
          Row(
            children: [
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Total Buses',
                  value: '${summary.totalBuses}',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Active Trips',
                  value: '${summary.activeTrips}',
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ----------------- ROW 2: MOVING, HALTED, SIGNAL LOST -----------------
          Row(
            children: [
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Moving',
                  value: '${summary.movingBuses}',
                  color: const Color(0xFF10B981),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Halted',
                  value: '${summary.haltedBuses}',
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Signal Lost',
                  value: '${summary.signalLost}',
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ----------------- ROW 3: STUDENTS ON BOARD & ALERTS -----------------
          Row(
            children: [
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Students On Board',
                  value: '${summary.studentsOnBoard}',
                  color: const Color(0xFF4F46E5),
                  bgColor: const Color(0xFFEEF2FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Unresolved Alerts',
                  value: '${summary.unresolvedAlerts}',
                  color: const Color(0xFFEA580C),
                  bgColor: const Color(0xFFFFF7ED),
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

  Widget _buildFleetCard(TransportFleetItem item) {
    final status = item.vehicleStatus.toLowerCase();
    Color statusBg = const Color(0xFFF1F5F9);
    Color statusBorder = const Color(0xFFCBD5E1);
    Color statusColor = const Color(0xFF475569);
    IconData statusIcon = Icons.directions_bus_rounded;

    if (status == 'moving') {
      statusBg = const Color(0xFFECFDF5);
      statusBorder = const Color(0xFFA7F3D0);
      statusColor = const Color(0xFF059669);
      statusIcon = Icons.navigation_rounded;
    } else if (status == 'signal_lost' || status.contains('lost')) {
      statusBg = const Color(0xFFFEF2F2);
      statusBorder = const Color(0xFFFECACA);
      statusColor = const Color(0xFFDC2626);
      statusIcon = Icons.portable_wifi_off_rounded;
    } else if (status == 'halted') {
      statusBg = const Color(0xFFFFFBEB);
      statusBorder = const Color(0xFFFDE68A);
      statusColor = const Color(0xFFD97706);
      statusIcon = Icons.report_problem_rounded;
    }

    final route = item.assignedRoute;
    final driver = item.driver;
    final trip = item.activeTrip;
    final telemetry = trip?.telemetry;
    final manifest = trip?.passengerManifest;
    final halt = trip?.activeHalt;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------- HEADER: BUS NUMBER, PLATE & STATUS -----------------
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(statusIcon, color: statusColor, size: 22),
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
                            item.busNumber,
                            style: GoogleFonts.poppins(
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          if (item.plateNumber != null && item.plateNumber!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.plateNumber!,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${route?.name ?? 'Assigned Route N/A'}${route?.code != null ? ' (${route!.code})' : ''}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusBorder),
                  ),
                  child: Text(
                    item.vehicleStatusText,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
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

            // ----------------- DRIVER INFO BAR -----------------
            if (driver != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, size: 16, color: Color(0xFF475569)),
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
                              text: driver.name,
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
                    if (driver.phone != null && driver.phone!.isNotEmpty) ...[
                      const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF0284C7)),
                      const SizedBox(width: 4),
                      Text(
                        driver.phone!,
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
              const SizedBox(height: 10),
            ],

            // ----------------- ACTIVE TRIP & TELEMETRY BOX -----------------
            if (trip != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.departure_board_rounded, size: 16, color: Color(0xFF4F46E5)),
                            const SizedBox(width: 6),
                            Text(
                              trip.tripTypeLabel,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4F46E5),
                              ),
                            ),
                          ],
                        ),
                        if (trip.startedAtTime != null)
                          Text(
                            'Started: ${trip.startedAtTime}${trip.elapsedFormatted != null ? ' (${trip.elapsedFormatted})' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4338CA),
                            ),
                          ),
                      ],
                    ),

                    if (telemetry != null) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Text(
                            '${telemetry.speed} km/h',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Last Ping: ${telemetry.lastPingAgo ?? 'N/A'}',
                              style: GoogleFonts.poppins(
                                fontSize: 10.5,
                                color: const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ----------------- PASSENGER MANIFEST -----------------
            if (manifest != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.groups_rounded, size: 16, color: Color(0xFF16A34A)),
                            const SizedBox(width: 6),
                            Text(
                              'Boarded Progress',
                              style: GoogleFonts.poppins(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${manifest.boarded} / ${manifest.totalAllocated} (${manifest.progressPercent}%)',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (manifest.totalAllocated > 0)
                            ? (manifest.boarded / manifest.totalAllocated).clamp(0.0, 1.0)
                            : 0.0,
                        backgroundColor: const Color(0xFFDCFCE7),
                        color: const Color(0xFF16A34A),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ----------------- EMERGENCY / HALT ALERT -----------------
            if (halt != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFDC2626)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Alert: ${halt.reason ?? 'Active Halt'} (${halt.durationText ?? 'Ongoing'})',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFDC2626),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
