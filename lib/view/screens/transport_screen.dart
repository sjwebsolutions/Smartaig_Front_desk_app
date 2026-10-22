import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/transport_alert_model.dart';
import '../../models/transport_halt_model.dart';
import '../../models/transport_live_overview_model.dart';
import '../../models/transport_location_request_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/transport_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';
import 'transport_request_detail_screen.dart';

class TransportScreen extends StatefulWidget {
  final int initialTabIndex;

  const TransportScreen({
    super.key,
    this.initialTabIndex = 0,
  });

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final TransportController _controller = TransportController.to;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTabIndex.clamp(0, 3),
    );
    UnreadCounterController.to.clearTransportCount();

    // Fetch initial data for all transport sub-modules
    _controller.fetchLocationRequests();
    _controller.fetchLiveOverview();
    _controller.fetchTransportHalts();
    _controller.fetchTransportAlerts();
  }

  @override
  void dispose() {
    _tabController.dispose();
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
                          'TRANSPORT SERVICES',
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
              // TAB BAR
              // -------------------------------------------------
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  labelColor: Colors.white,
                  unselectedLabelColor: const Color(0xFF64748B),
                  labelStyle: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.bold),
                  unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w500),
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                  tabs: const [
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.assignment_turned_in_rounded, size: 16),
                          SizedBox(height: 2),
                          Text('Requests'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.gps_fixed_rounded, size: 16),
                          SizedBox(height: 2),
                          Text('Live GPS'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.report_problem_rounded, size: 16),
                          SizedBox(height: 2),
                          Text('Halts'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_active_rounded, size: 16),
                          SizedBox(height: 2),
                          Text('Alerts'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // -------------------------------------------------
              // TAB VIEWS BODY
              // -------------------------------------------------
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildRequestsTab(),
                    _buildLiveGpsTab(),
                    _buildHaltsTab(),
                    _buildAlertsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // TAB 1: LOCATION CHANGE REQUESTS
  // ===========================================================================
  Widget _buildRequestsTab() {
    return Obx(() {
      if (_controller.isLoading.value && _controller.requestsList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
        );
      }

      if (_controller.errorMessage.value.isNotEmpty && _controller.requestsList.isEmpty) {
        final isNetErr = AppErrorFormatter.isNetworkError(_controller.errorMessage.value);
        return _buildErrorState(
          title: isNetErr ? 'No Internet Connection' : 'Failed to Load Requests',
          message: _controller.errorMessage.value,
          isNetErr: isNetErr,
          onRetry: () => _controller.fetchLocationRequests(),
        );
      }

      final filteredList = _controller.filteredRequests;

      return RefreshIndicator(
        color: const Color(0xFF4E54C8),
        onRefresh: () => _controller.fetchLocationRequests(isManualRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              // SUMMARY CARDS
              _buildRequestsSummaryCard(),
              const SizedBox(height: 12),

              // STATUS FILTER CHIPS
              _buildFilterTabs(),
              const SizedBox(height: 12),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LOCATION CHANGE REQUESTS',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${filteredList.length} Items',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (filteredList.isEmpty)
                _buildEmptyState(
                  title: 'No Location Requests Found',
                  subtitle: 'There are no location change requests under this status filter.',
                  icon: Icons.directions_bus_filled_outlined,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length,
                  itemBuilder: (context, index) {
                    final item = filteredList[index];
                    return _buildRequestCard(item);
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildRequestsSummaryCard() {
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
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.directions_bus_rounded, color: Color(0xFFEA580C), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Location Change Requests',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Address & Stoppage change requests overview',
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
                  title: 'Total',
                  value: '${_controller.totalCount}',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Pending',
                  value: '${_controller.pendingCount}',
                  color: const Color(0xFFD97706),
                  bgColor: const Color(0xFFFFFBEB),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Approved',
                  value: '${_controller.approvedCount}',
                  color: const Color(0xFF059669),
                  bgColor: const Color(0xFFECFDF5),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Rejected',
                  value: '${_controller.rejectedCount}',
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      {'key': 'all', 'label': 'All'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'approved', 'label': 'Approved'},
      {'key': 'rejected', 'label': 'Rejected'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final isSelected = _controller.selectedStatusFilter.value == f['key'];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(
                f['label']!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
              selectedColor: const Color(0xFF4F46E5),
              backgroundColor: Colors.white,
              checkmarkColor: Colors.white,
              side: BorderSide(
                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
              ),
              onSelected: (_) => _controller.changeStatusFilter(f['key']!),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRequestCard(TransportLocationRequestItem item) {
    final status = item.status.toLowerCase();
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

    final student = item.student;
    final transport = item.transport;
    final oldCoord = item.oldCoordinates;
    final proposedCoord = item.proposedCoordinates;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.to(() => TransportRequestDetailScreen(requestId: item.id)),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ID: ${item.id}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4F46E5),
                            ),
                          ),
                        ),
                        if (item.locationType != null && item.locationType!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.locationType!.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF475569),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusBorder),
                      ),
                      child: Text(
                        item.statusLabel,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE0F2FE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(Icons.school_rounded, color: Color(0xFF0284C7), size: 22),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            student?.name ?? 'Unknown Student',
                            style: GoogleFonts.poppins(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${student?.fullClassSection ?? 'N/A'}${student?.uniqueId != null ? ' • ID: ${student!.uniqueId}' : ''}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBAE6FD)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.directions_bus_rounded, size: 16, color: Color(0xFF0284C7)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${transport?.busNumber ?? 'Bus N/A'} • ${transport?.routeName ?? 'Route N/A'}${transport?.stoppageName != null ? ' (${transport!.stoppageName})' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0369A1),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF64748B)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Current',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                oldCoord?.address ?? transport?.stoppageName ?? 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: const Color(0xFF334155),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEEF2FF),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFC7D2FE)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.my_location_rounded, size: 13, color: Color(0xFF4F46E5)),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Proposed',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4F46E5),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                proposedCoord?.address ?? 'N/A',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF1E1B4B),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (proposedCoord?.notes != null && proposedCoord!.notes!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      'Note: ${proposedCoord.notes}',
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF92400E),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
                if (status == 'pending') ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _showRejectDialog(item.id, student?.name ?? 'Student'),
                          icon: const Icon(Icons.close_rounded, size: 15, color: Color(0xFFDC2626)),
                          label: Text(
                            'Reject',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFFDC2626)),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFFECACA)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _showApproveConfirmation(item.id, student?.name ?? 'Student'),
                          icon: const Icon(Icons.check_rounded, size: 15, color: Colors.white),
                          label: Text(
                            'Approve',
                            style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'By ${item.requestedByName ?? 'Parent'} • ${item.requestedVia?.replaceAll('_', ' ').toUpperCase() ?? 'APP'}',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.requestedAtTime != null)
                      Text(
                        item.requestedAtTime!,
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: const Color(0xFF94A3B8),
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
  }

  // ===========================================================================
  // TAB 2: LIVE GPS OVERVIEW
  // ===========================================================================
  Widget _buildLiveGpsTab() {
    return Obx(() {
      if (_controller.isLiveLoading.value && _controller.fleetList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
        );
      }

      if (_controller.liveErrorMessage.value.isNotEmpty && _controller.fleetList.isEmpty) {
        final isNetErr = AppErrorFormatter.isNetworkError(_controller.liveErrorMessage.value);
        return _buildErrorState(
          title: isNetErr ? 'No Internet Connection' : 'Failed to Load Live GPS',
          message: _controller.liveErrorMessage.value,
          isNetErr: isNetErr,
          onRetry: () => _controller.fetchLiveOverview(),
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

              if (summary != null) ...[
                _buildLiveSummaryCard(summary),
                const SizedBox(height: 14),
              ],

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
                _buildEmptyState(
                  title: 'No Live Bus Fleet Found',
                  subtitle: 'There are currently no active buses or fleet records.',
                  icon: Icons.directions_bus_outlined,
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
    });
  }

  Widget _buildLiveSummaryCard(TransportLiveOverviewSummary summary) {
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

  // ===========================================================================
  // TAB 3: VEHICLE HALTS
  // ===========================================================================
  Widget _buildHaltsTab() {
    return Obx(() {
      if (_controller.isHaltsLoading.value && _controller.haltsList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
        );
      }

      if (_controller.haltsErrorMessage.value.isNotEmpty && _controller.haltsList.isEmpty) {
        final isNetErr = AppErrorFormatter.isNetworkError(_controller.haltsErrorMessage.value);
        return _buildErrorState(
          title: isNetErr ? 'No Internet Connection' : 'Failed to Load Vehicle Halts',
          message: _controller.haltsErrorMessage.value,
          isNetErr: isNetErr,
          onRetry: () => _controller.fetchTransportHalts(),
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

              _buildHaltSummaryCard(halts.length, ongoingCount),
              const SizedBox(height: 14),

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
                _buildEmptyState(
                  title: 'No Active Halts or Alerts',
                  subtitle: 'All fleet buses are operating smoothly without active halts or emergency alerts.',
                  icon: Icons.check_circle_outline_rounded,
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
    });
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

  // ===========================================================================
  // TAB 4: TRANSPORT ALERTS
  // ===========================================================================
  Widget _buildAlertsTab() {
    return Obx(() {
      if (_controller.isAlertsLoading.value && _controller.realAlertsList.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFF4E54C8)),
        );
      }

      if (_controller.alertsErrorMessage.value.isNotEmpty && _controller.realAlertsList.isEmpty) {
        final isNetErr = AppErrorFormatter.isNetworkError(_controller.alertsErrorMessage.value);
        return _buildErrorState(
          title: isNetErr ? 'No Internet Connection' : 'Failed to Load Transport Alerts',
          message: _controller.alertsErrorMessage.value,
          isNetErr: isNetErr,
          onRetry: () => _controller.fetchTransportAlerts(),
        );
      }

      final alerts = _controller.realAlertsList;
      final criticalCount = alerts.where((a) => a.severity.toLowerCase() == 'critical').length;
      final unresolvedCount = alerts.where((a) => !a.isResolved).length;

      return RefreshIndicator(
        color: const Color(0xFF4E54C8),
        onRefresh: () => _controller.fetchTransportAlerts(isManualRefresh: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),

              _buildAlertSummaryCard(alerts.length, criticalCount, unresolvedCount),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'UNRESOLVED EMERGENCY ALERTS',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '${alerts.length} Alerts',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (alerts.isEmpty)
                _buildEmptyState(
                  title: 'No Active Alerts',
                  subtitle: 'Great! There are currently no unresolved emergency or telemetry alerts.',
                  icon: Icons.check_circle_outline_rounded,
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final item = alerts[index];
                    return _buildRealAlertCard(item);
                  },
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAlertSummaryCard(int total, int critical, int unresolved) {
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
                child: const Icon(Icons.notifications_active_rounded, color: Color(0xFFDC2626), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Alerts Overview',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Text(
                      'Live SOS alerts, halt delays & emergency broadcasts',
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
                  title: 'Total Alerts',
                  value: '$total',
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Critical Severity',
                  value: '$critical',
                  color: const Color(0xFFDC2626),
                  bgColor: const Color(0xFFFEF2F2),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryBadge(
                  title: 'Unresolved',
                  value: '$unresolved',
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

  Widget _buildRealAlertCard(TransportAlertItem item) {
    final route = item.route;
    final driver = item.driver;
    final location = item.location;
    final isCritical = item.severity.toLowerCase() == 'critical';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isCritical ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: isCritical ? const Color(0xFFDC2626).withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isCritical ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    isCritical ? Icons.notifications_active_rounded : Icons.warning_amber_rounded,
                    color: isCritical ? const Color(0xFFDC2626) : const Color(0xFFEA580C),
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCritical ? const Color(0xFFFEF2F2) : const Color(0xFFFFF7ED),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isCritical ? const Color(0xFFFECACA) : const Color(0xFFFFEDD5)),
                          ),
                          child: Text(
                            item.severity.toUpperCase(),
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isCritical ? const Color(0xFFDC2626) : const Color(0xFFEA580C),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.alertTypeLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        height: 1.25,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFEDD5)),
            ),
            child: Text(
              item.message,
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF9A3412),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (driver != null || route?.name != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  if (driver != null)
                    Row(
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
                  if (route?.name != null) ...[
                    if (driver != null) const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.directions_bus_rounded, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          'Route: ${route!.name}',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF475569),
                            fontWeight: FontWeight.w500,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (location?.locationName != null)
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location!.locationName!,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              if (item.createdAtAgo != null || item.createdAtTime != null)
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 13, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 4),
                    Text(
                      item.createdAtAgo ?? item.createdAtTime!,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // COMMON HELPER WIDGETS
  // ===========================================================================
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

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 48, color: const Color(0xFF94A3B8)),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState({
    required String title,
    required String message,
    required bool isNetErr,
    required VoidCallback onRetry,
  }) {
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
              title,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C3E50),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
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
