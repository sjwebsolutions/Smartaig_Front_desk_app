import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/admission_model.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/admission_controller.dart';

class AdmissionDetailScreen extends StatefulWidget {
  final int enquiryId;

  const AdmissionDetailScreen({
    super.key,
    required this.enquiryId,
  });

  @override
  State<AdmissionDetailScreen> createState() => _AdmissionDetailScreenState();
}

class _AdmissionDetailScreenState extends State<AdmissionDetailScreen> {
  final AdmissionController _controller = Get.find<AdmissionController>();

  @override
  void initState() {
    super.initState();
    _controller.fetchAdmissionDetail(widget.enquiryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddFollowupDialog(context, widget.enquiryId),
        backgroundColor: const Color(0xFF4F46E5),
        icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 22),
        label: Text(
          'Add Follow-up',
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
              // APP BAR
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
                          'ADMISSION DETAILS',
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
              // BODY
              // -------------------------------------------------
              Expanded(
                child: Obx(() {
                  if (_controller.isDetailLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                    );
                  }

                  if (_controller.detailErrorMessage.value.isNotEmpty) {
                    final isNetErr = AppErrorFormatter.isNetworkError(_controller.detailErrorMessage.value);
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
                              isNetErr ? 'No Internet Connection' : 'Failed to Load Detail',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF2C3E50),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _controller.detailErrorMessage.value,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 18),
                            ElevatedButton.icon(
                              onPressed: () => _controller.fetchAdmissionDetail(widget.enquiryId),
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

                  final item = _controller.admissionDetail.value;
                  if (item == null) {
                    return Center(
                      child: Text(
                        'No details available.',
                        style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF64748B)),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF4F46E5),
                    onRefresh: () => _controller.fetchAdmissionDetail(widget.enquiryId),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.only(left: 12, right: 12, top: 6, bottom: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(item),
                          const SizedBox(height: 12),
                          _buildActionButtons(item),
                          const SizedBox(height: 12),
                          _buildFollowupsCard(item),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: 'Student Information',
                            icon: Icons.person_rounded,
                            children: [
                              _buildInfoRow('Full Name', item.fullName),
                              _buildInfoRow('Inquiry Number', item.inquiryNumber),
                              _buildInfoRow('Gender', item.gender),
                              _buildInfoRow('Date of Birth', item.dob),
                              _buildInfoRow('Aadhaar No.', item.aadhaarNo),
                              _buildInfoRow('Category', item.category),
                              _buildInfoRow('Religion', item.religion),
                              _buildInfoRow('Caste', item.caste),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: 'Academic Information',
                            icon: Icons.school_rounded,
                            children: [
                              _buildInfoRow('Class Applied', item.className),
                              _buildInfoRow('Academic Session', item.sessionYear),
                              _buildInfoRow('Previous School', item.previousSchool),
                              _buildInfoRow('Last Class Attended', item.lastClassAttended),
                              _buildInfoRow('Reason for Leaving', item.reasonForLeaving),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: 'Parent & Contact Details',
                            icon: Icons.family_restroom_rounded,
                            children: [
                              _buildInfoRow('Father Name', item.fatherName),
                              _buildInfoRow('Father Mobile', item.fatherMobile),
                              _buildInfoRow('Father Occupation', item.fatherOccupation),
                              _buildInfoRow('Father Qualification', item.fatherQualification),
                              _buildInfoRow('Mother Name', item.motherName),
                              _buildInfoRow('Mother Mobile', item.motherMobile),
                              _buildInfoRow('Mother Occupation', item.motherOccupation),
                              _buildInfoRow('Mother Qualification', item.motherQualification),
                              _buildInfoRow('Family Income', item.familyIncome),
                              _buildInfoRow('Alternate Contact', item.alternateContact),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: 'Address Details',
                            icon: Icons.location_on_rounded,
                            children: [
                              _buildInfoRow('Address', item.address),
                              _buildInfoRow('Locality', item.locality),
                              _buildInfoRow('City', item.city),
                              _buildInfoRow('State', item.state),
                              _buildInfoRow('Pincode', item.pincode),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: 'Remarks & Details',
                            icon: Icons.assignment_rounded,
                            children: [
                              _buildInfoRow('Status', item.statusLabel ?? item.status),
                              _buildInfoRow('Follow-up Status', item.followUpStatus),
                              _buildInfoRow('Interest Level', item.interestLevel),
                              _buildInfoRow('Medical History', item.medicalHistory),
                              _buildInfoRow('Remarks', item.remarks),
                              _buildInfoRow('Siblings Details', item.siblingsDetails),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildSectionCard(
                            title: 'System Information',
                            icon: Icons.info_outline_rounded,
                            children: [
                              _buildInfoRow('Created By', item.createdBy),
                              _buildInfoRow('Created Date', item.createdAt),
                            ],
                          ),
                          const SizedBox(height: 24),
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

  Widget _buildHeaderCard(AdmissionDetailModel item) {
    final statusKey = (item.status ?? '').toLowerCase();
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
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: const Color(0xFFEEF2FF),
            backgroundImage: (item.studentImageUrl != null && item.studentImageUrl!.isNotEmpty)
                ? NetworkImage(item.studentImageUrl!)
                : null,
            child: (item.studentImageUrl == null || item.studentImageUrl!.isEmpty)
                ? Text(
                    (item.fullName != null && item.fullName!.isNotEmpty) ? item.fullName![0].toUpperCase() : 'A',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                      fontSize: 26,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            item.fullName ?? 'Student Name',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          if (item.inquiryNumber != null && item.inquiryNumber!.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item.inquiryNumber!,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF475569),
                ),
              ),
            ),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 6,
            children: [
              if (item.className != null && item.className!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Class: ${item.className}',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                ),
              if (item.statusLabel != null && item.statusLabel!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.statusLabel!,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: statusTextColor,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(AdmissionDetailModel item) {
    final phone = item.fatherMobile ?? item.motherMobile ?? '';
    if (phone.trim().isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _launchCall(phone),
            icon: const Icon(Icons.phone_rounded, size: 15, color: Color(0xFF2563EB)),
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
              backgroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFFBFDBFE)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _launchWhatsApp(phone, item.fullName ?? 'Student'),
            icon: const FaIcon(FontAwesomeIcons.whatsapp, size: 15, color: Colors.white),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFollowupsCard(AdmissionDetailModel item) {
    final followups = item.followups ?? [];

    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 18, color: Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Follow-up History',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddFollowupDialog(context, widget.enquiryId),
                  icon: const Icon(Icons.add_rounded, size: 16, color: Color(0xFF4F46E5)),
                  label: Text(
                    'Add Note',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF4F46E5),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            if (followups.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Text(
                    'No follow-up notes added yet.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: const Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: followups.length,
                separatorBuilder: (context, index) => const Divider(height: 16, color: Color(0xFFF1F5F9)),
                itemBuilder: (context, index) {
                  final fu = followups[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEEF2FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notes_rounded, size: 14, color: Color(0xFF4F46E5)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fu.note ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 2,
                              children: [
                                if (fu.createdBy != null && fu.createdBy!.isNotEmpty)
                                  Text(
                                    'By ${fu.createdBy}',
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (fu.createdAt != null && fu.createdAt!.isNotEmpty)
                                  Text(
                                    fu.createdAt!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final validChildren = children.where((w) => w is! SizedBox).toList();
    if (validChildren.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: Color(0xFFF1F5F9)),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    if (value == null || value.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showAddFollowupDialog(BuildContext context, int enquiryId) {
    final noteController = TextEditingController();

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: Color(0xFF4F46E5), size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Add Follow-up Note',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Follow-up Note *',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: 'Enter follow-up details or parent response...',
                    hintStyle: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF94A3B8)),
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
                      borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Obx(() {
                      return ElevatedButton(
                        onPressed: _controller.isAddingFollowup.value
                            ? null
                            : () async {
                                final text = noteController.text.trim();
                                if (text.isEmpty) {
                                  AppSnackbar.showError(
                                    title: 'Required Field',
                                    message: 'Please enter a follow-up note.',
                                  );
                                  return;
                                }
                                final success = await _controller.addAdmissionFollowup(
                                  enquiryId: enquiryId,
                                  note: text,
                                );
                                if (success) {
                                  Get.back();
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        ),
                        child: _controller.isAddingFollowup.value
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                'Submit Note',
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
