import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/student_count_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../view_models/get_x/student_count_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';

class StudentCountScreen extends StatefulWidget {
  const StudentCountScreen({super.key});

  @override
  State<StudentCountScreen> createState() => _StudentCountScreenState();
}

class _StudentCountScreenState extends State<StudentCountScreen> {
  final StudentCountController _controller = Get.put(StudentCountController());
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    UnreadCounterController.to.clearStudentCount();
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 22),
                      onPressed: () => Get.back(),
                      tooltip: 'Back',
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'STUDENT COUNT',
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
                  if (_controller.isLoading.value && _controller.studentCountData.value == null) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4E54C8),
                      ),
                    );
                  }

                  if (_controller.errorMessage.value.isNotEmpty && _controller.studentCountData.value == null) {
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
                              isNetErr ? 'No Internet Connection' : 'Failed to Load Data',
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
                              onPressed: () => _controller.fetchStudentCount(),
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

                  final data = _controller.studentCountData.value;
                  final overallStats = data?.overallStats;
                  final filteredList = _controller.filteredClassWiseCounts;

                  return RefreshIndicator(
                    color: const Color(0xFF4E54C8),
                    onRefresh: () => _controller.fetchStudentCount(isManualRefresh: true),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 6),

                          // -------------------------------------------------
                          // OVERVIEW SUMMARY CARD
                          // -------------------------------------------------
                          _buildOverviewCard(data, overallStats),
                          const SizedBox(height: 16),

                          // -------------------------------------------------
                          // SEARCH BOX
                          // -------------------------------------------------
                          _buildSearchBox(),
                          const SizedBox(height: 16),

                          // -------------------------------------------------
                          // CLASS WISE COUNT LIST
                          // -------------------------------------------------
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CLASS-WISE BREAKDOWN',
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
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              margin: const EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const Icon(Icons.search_off_rounded, size: 48, color: Color(0xFF94A3B8)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'No Class Records Found',
                                    style: GoogleFonts.poppins(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _searchController.text.isNotEmpty
                                        ? 'No records match "${_searchController.text}". Try another query.'
                                        : 'No student count records available.',
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
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                final item = filteredList[index];
                                return _buildClassCard(item);
                              },
                            ),

                          const SizedBox(height: 25),
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

  Widget _buildOverviewCard(StudentCountData? data, OverallStats? stats) {
    final overallTotal = stats?.overallTotal ?? 0;
    final boysTotal = stats?.boysTotal ?? 0;
    final girlsTotal = stats?.girlsTotal ?? 0;
    final date = data?.date ?? '';
    final academicYear = data?.academicYear ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.groups_rounded, color: Color(0xFFD97706), size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overall Student Strength',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$overallTotal Total Students',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ),
              if (academicYear.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Text(
                    academicYear,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                ),
            ],
          ),
          if (date.isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 12, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  'As of $date',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
          Row(
            children: [
              Expanded(
                child: _buildStatBadge(
                  title: 'Boys Total',
                  value: '$boysTotal',
                  icon: Icons.boy_rounded,
                  color: const Color(0xFF2563EB),
                  bgColor: const Color(0xFFEFF6FF),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatBadge(
                  title: 'Girls Total',
                  value: '$girlsTotal',
                  icon: Icons.girl_rounded,
                  color: const Color(0xFFEC4899),
                  bgColor: const Color(0xFFFCE7F3),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatBadge(
                  title: 'Overall Total',
                  value: '$overallTotal',
                  icon: Icons.school_rounded,
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

  Widget _buildStatBadge({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          _controller.searchQuery.value = val;
        },
        style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: 'Search Class, Section, or Stream...',
          hintStyle: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF94A3B8)),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B), size: 20),
          suffixIcon: Obx(() => _controller.searchQuery.value.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B), size: 18),
                  onPressed: () {
                    _searchController.clear();
                    _controller.searchQuery.value = '';
                  },
                )
              : const SizedBox.shrink()),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildClassCard(ClassWiseCount item) {
    final className = item.className ?? 'N/A';
    final sectionName = item.sectionName ?? 'N/A';
    final streamName = item.streamName ?? 'N/A';
    final boys = item.boys ?? 0;
    final girls = item.girls ?? 0;
    final total = item.total ?? 0;

    final showStream = streamName.isNotEmpty && streamName.toLowerCase() != 'n/a';
    final showSection = sectionName.isNotEmpty && sectionName.toLowerCase() != 'n/a';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
                child: const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class $className',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      children: [
                        if (showSection)
                          Text(
                            'Section: ${sectionName.toUpperCase()}',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (showStream)
                          Text(
                            'Stream: $streamName',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: const Color(0xFF4F46E5),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$total Total',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  children: [
                    const Icon(Icons.boy_rounded, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 4),
                    Text(
                      'Boys: $boys',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Container(
                  height: 16,
                  width: 1,
                  color: const Color(0xFFCBD5E1),
                ),
                Row(
                  children: [
                    const Icon(Icons.girl_rounded, size: 16, color: Color(0xFFEC4899)),
                    const SizedBox(width: 4),
                    Text(
                      'Girls: $girls',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
