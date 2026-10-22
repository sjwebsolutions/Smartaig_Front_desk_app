import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/admission_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/admission_controller.dart';
import '../../view_models/get_x/unread_counter_controller.dart';
import 'add_admission_enquiry_screen.dart';
import 'admission_detail_screen.dart';

class AdmissionScreen extends StatefulWidget {
  const AdmissionScreen({super.key});

  @override
  State<AdmissionScreen> createState() => _AdmissionScreenState();
}

class _AdmissionScreenState extends State<AdmissionScreen> {
  final AdmissionController _controller = Get.put(AdmissionController());

  @override
  void initState() {
    super.initState();
    UnreadCounterController.to.clearAdmission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const AddAdmissionEnquiryScreen()),
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
        label: Text(
          'Add Enquiry',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 13,
          ),
        ),
      ),
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
                          'ADMISSION ENQUIRIES',
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
              // STATUS FILTER CHIPS
              // -------------------------------------------------
              _buildFilterChips(),

              const SizedBox(height: 6),

              // -------------------------------------------------
              // MAIN LIST / STATES
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value && _controller.enquiryList.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                    );
                  }

                  if (_controller.errorMessage.value.isNotEmpty && _controller.enquiryList.isEmpty) {
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
                              isNetErr ? 'No Internet Connection' : 'Failed to Load Enquiries',
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
                              onPressed: () => _controller.fetchAdmissionEnquiries(),
                              icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                              label: Text(
                                'Retry',
                                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = _controller.filteredEnquiries;

                  if (list.isEmpty) {
                    return Center(
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFEEF2FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.school_rounded, size: 48, color: Color(0xFF4F46E5)),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _controller.searchQuery.value.isNotEmpty
                                    ? 'No matching enquiries found'
                                    : 'No Admission Enquiries Found',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1E293B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _controller.searchQuery.value.isNotEmpty
                                    ? 'Try searching with a different name, class or inquiry number'
                                    : 'There are no admission enquiries listed under this filter.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: () => Get.to(() => const AddAdmissionEnquiryScreen()),
                                icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                                label: Text(
                                  'Add New Enquiry',
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4F46E5),
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF4F46E5),
                    onRefresh: () => _controller.fetchAdmissionEnquiries(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 80),
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final enquiry = list[index];
                        return _buildEnquiryCard(enquiry);
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

  Widget _buildFilterChips() {
    final filters = [
      {'label': 'All', 'value': 'all'},
      {'label': 'Under Process', 'value': 'under_process'},
      {'label': 'Request Received', 'value': 'request_received'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Obx(() {
        return Row(
          children: filters.map((f) {
            final isSelected = _controller.selectedStatus.value == f['value'];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(
                  f['label']!,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF475569),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF4F46E5),
                backgroundColor: Colors.white,
                showCheckmark: false,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
                  ),
                ),
                onSelected: (selected) {
                  if (selected) {
                    _controller.filterByStatus(f['value']!);
                  }
                },
              ),
            );
          }).toList(),
        );
      }),
    );
  }

  Widget _buildEnquiryCard(AdmissionEnquiryModel enquiry) {
    final phone = enquiry.fatherMobile ?? enquiry.motherMobile ?? '';
    final hasPhone = phone.trim().isNotEmpty;
    final statusKey = (enquiry.status ?? '').toLowerCase();
    
    Color statusBgColor = const Color(0xFFEFF6FF);
    Color statusTextColor = const Color(0xFF2563EB);

    if (statusKey == 'under_process') {
      statusBgColor = const Color(0xFFFFFBEB);
      statusTextColor = const Color(0xFFD97706);
    } else if (statusKey == 'completed' || statusKey == 'approved') {
      statusBgColor = const Color(0xFFECFDF5);
      statusTextColor = const Color(0xFF059669);
    } else if (statusKey == 'rejected' || statusKey == 'cancelled') {
      statusBgColor = const Color(0xFFFEF2F2);
      statusTextColor = const Color(0xFFDC2626);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            if (enquiry.id != null) {
              Get.to(() => AdmissionDetailScreen(enquiryId: enquiry.id!));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Student Avatar, Name, Inquiry No. & Status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: const Color(0xFFEEF2FF),
                      backgroundImage: (enquiry.studentImageUrl != null && enquiry.studentImageUrl!.isNotEmpty)
                          ? NetworkImage(enquiry.studentImageUrl!)
                          : null,
                      child: (enquiry.studentImageUrl == null || enquiry.studentImageUrl!.isEmpty)
                          ? Text(
                              (enquiry.fullName != null && enquiry.fullName!.isNotEmpty)
                                  ? enquiry.fullName![0].toUpperCase()
                                  : 'A',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF4F46E5),
                                fontSize: 16,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            enquiry.fullName ?? 'Student Name',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1E293B),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          if (enquiry.inquiryNumber != null && enquiry.inquiryNumber!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                enquiry.inquiryNumber!,
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (enquiry.statusLabel != null && enquiry.statusLabel!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            enquiry.statusLabel!,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusTextColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Data Fields Stacked Vertically Line by Line
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (enquiry.className != null && enquiry.className!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailTag(
                          icon: Icons.class_outlined,
                          label: 'Class: ${enquiry.className}',
                        ),
                      ),
                    if (enquiry.sessionYear != null && enquiry.sessionYear!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailTag(
                          icon: Icons.calendar_today_rounded,
                          label: 'Session: ${enquiry.sessionYear}',
                        ),
                      ),
                    if (enquiry.gender != null && enquiry.gender!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailTag(
                          icon: Icons.person_outline_rounded,
                          label: 'Gender: ${enquiry.gender}',
                        ),
                      ),
                    if (enquiry.fatherName != null && enquiry.fatherName!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailTag(
                          icon: Icons.family_restroom_rounded,
                          label: 'Father: ${enquiry.fatherName}',
                        ),
                      ),
                    if (hasPhone)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailTag(
                          icon: Icons.phone_android_rounded,
                          label: 'Mobile: $phone',
                        ),
                      ),
                    if (enquiry.createdAt != null && enquiry.createdAt!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailTag(
                          icon: Icons.access_time_rounded,
                          label: 'Created: ${enquiry.createdAt}',
                        ),
                      ),
                    if (enquiry.createdBy != null && enquiry.createdBy!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _buildDetailTag(
                          icon: Icons.person_pin_rounded,
                          label: 'By: ${enquiry.createdBy}',
                        ),
                      ),
                  ],
                ),

                // Action buttons (Call & WhatsApp) if phone exists
                if (hasPhone) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _launchCall(phone),
                          icon: const Icon(Icons.phone_rounded, size: 14, color: Color(0xFF2563EB)),
                          label: Text(
                            'Call Parent',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2563EB),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _launchWhatsApp(phone, enquiry.fullName ?? 'Student'),
                          icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 14, color: Colors.white),
                          label: Text(
                            'WhatsApp',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTag({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _launchCall(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final url = Uri.parse('tel:$clean');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(title: 'Dialer Not Available', message: 'Could not open dialer for $phone.');
      }
    } catch (_) {
      AppSnackbar.showError(title: 'Call Error', message: 'Unable to open dialer.');
    }
  }

  Future<void> _launchWhatsApp(String phone, String studentName) async {
    final clean = phone.replaceAll(RegExp(r'\D'), '');
    final fullNumber = clean.length == 10 ? '91$clean' : clean;
    final message = Uri.encodeComponent('Hello, regarding admission enquiry for $studentName.');
    final url = Uri.parse('https://wa.me/$fullNumber?text=$message');
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
        AppSnackbar.showError(title: 'WhatsApp Not Available', message: 'Could not open WhatsApp for $phone.');
      }
    } catch (_) {
      AppSnackbar.showError(title: 'WhatsApp Error', message: 'Unable to open WhatsApp.');
    }
  }
}
