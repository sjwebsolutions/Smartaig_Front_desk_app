import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/student_image_students_model.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/student_image_students_controller.dart';

class StudentImageSingleUploadScreen extends StatefulWidget {
  final StudentImageStudentItem student;

  const StudentImageSingleUploadScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentImageSingleUploadScreen> createState() => _StudentImageSingleUploadScreenState();
}

class _StudentImageSingleUploadScreenState extends State<StudentImageSingleUploadScreen> {
  late final StudentImageStudentsController _studentsController;
  
  XFile? _studentProfileImage;
  XFile? _fatherImage;
  XFile? _motherImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _studentsController = Get.find<StudentImageStudentsController>();
  }

  Future<void> _pickPhoto(String type) async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85);
      if (picked != null) {
        setState(() {
          if (type == 'profile') _studentProfileImage = picked;
          if (type == 'father') _fatherImage = picked;
          if (type == 'mother') _motherImage = picked;
        });
      }
    } catch (_) {
      AppSnackbar.showError(title: 'Image Error', message: 'Could not capture image from camera.');
    }
  }

  void _onPhotoTileTap(String type, String label) {
    final bool hasImage = (type == 'profile' && _studentProfileImage != null) ||
        (type == 'father' && _fatherImage != null) ||
        (type == 'mother' && _motherImage != null);

    if (!hasImage) {
      _pickPhoto(type);
    } else {
      _showImageActionModal(type, label);
    }
  }

  void _showImageActionModal(String type, String label) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Manage $label Photo',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4F46E5), size: 22),
              ),
              title: Text('Retake Photo (Camera)', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500)),
              onTap: () {
                Get.back();
                _pickPhoto(type);
              },
            ),
            const Divider(height: 1),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 22),
              ),
              title: Text(
                'Remove Photo',
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: const Color(0xFFEF4444)),
              ),
              onTap: () {
                Get.back();
                setState(() {
                  if (type == 'profile') _studentProfileImage = null;
                  if (type == 'father') _fatherImage = null;
                  if (type == 'mother') _motherImage = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (widget.student.id == null) {
      AppSnackbar.showError(title: 'Error', message: 'Student ID is missing.');
      return;
    }
    if (_studentProfileImage == null && _fatherImage == null && _motherImage == null) {
      AppSnackbar.showError(title: 'Required Field', message: 'Please capture at least one photo (Student, Father, or Mother).');
      return;
    }

    final res = await _studentsController.submitStudentImageRequest(
      studentId: widget.student.id!,
      profileImageFile: _studentProfileImage != null ? File(_studentProfileImage!.path) : null,
      fatherImageFile: _fatherImage != null ? File(_fatherImage!.path) : null,
      motherImageFile: _motherImage != null ? File(_motherImage!.path) : null,
    );

    if (res != null && res.success == true) {
      Get.back(result: true);
    }
  }

  Widget _buildSinglePhotoTile({
    required String title,
    required String type,
    required XFile? imageFile,
    required String? currentPhotoUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => _onPhotoTileTap(type, title),
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: imageFile != null ? const Color(0xFF4F46E5) : Colors.grey.shade300,
                width: imageFile != null ? 1.5 : 1.0,
              ),
            ),
            child: imageFile != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(File(imageFile.path), fit: BoxFit.cover),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                              onPressed: () => _onPhotoTileTap(type, title),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Row(
                    children: [
                      const SizedBox(width: 14),
                      if (currentPhotoUrl != null && currentPhotoUrl.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            currentPhotoUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.person_rounded, color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_a_photo_rounded, size: 24, color: Color(0xFF4F46E5)),
                        ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tap to take photo (Camera)',
                              style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF4F46E5)),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              currentPhotoUrl != null && currentPhotoUrl.isNotEmpty ? 'Current photo available' : 'Camera capture required',
                              style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.student;
    final currentPhotos = student.currentPhotos;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD1E9FF),
              Color(0xFFE9D5FF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
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
                          'UPLOAD STUDENT PHOTO',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2C3E50),
                            letterSpacing: 0.8,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    const SizedBox(width: 32),
                  ],
                ),
              ),

              // Form Body
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                  child: Column(
                    children: [
                      // STUDENT DETAILS HEADER CARD
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: const Color(0xFFEEF2FF),
                                  backgroundImage: (currentPhotos?.studentPhotoUrl != null && currentPhotos!.studentPhotoUrl!.isNotEmpty)
                                      ? NetworkImage(currentPhotos.studentPhotoUrl!)
                                      : null,
                                  child: (currentPhotos?.studentPhotoUrl == null || currentPhotos!.studentPhotoUrl!.isEmpty)
                                      ? Text(
                                          (student.studentName ?? 'S')[0].toUpperCase(),
                                          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        student.studentName ?? '',
                                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Class: ${student.className ?? ''} ${student.sectionName != null ? '(${student.sectionName})' : ''}',
                                        style: GoogleFonts.poppins(fontSize: 12.5, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w600),
                                      ),
                                      Text(
                                        'Roll No: ${student.rollNo ?? '-'}  •  ID: ${student.studentUniqueId ?? '-'}',
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (student.fatherName != null && student.fatherName!.isNotEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 10),
                                child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Father Name: ${student.fatherName}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF334155), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                            if (student.motherName != null && student.motherName!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.face_outline_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Mother Name: ${student.motherName}',
                                    style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF334155), fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                            if (student.hasPendingRequest == true) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.orange.shade200),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.warning_amber_rounded, color: Colors.orange.shade800, size: 16),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Pending update request already exists for this student.',
                                        style: GoogleFonts.poppins(fontSize: 11, color: Colors.orange.shade900, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // PHOTO CAPTURE SECTION CARD
                      Container(
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Capture Photos via Camera',
                              style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 14),

                            // Student Profile Photo
                            _buildSinglePhotoTile(
                              title: 'Student Profile Photo',
                              type: 'profile',
                              imageFile: _studentProfileImage,
                              currentPhotoUrl: currentPhotos?.studentPhotoUrl,
                            ),
                            const SizedBox(height: 14),

                            // Father Photo
                            _buildSinglePhotoTile(
                              title: 'Father Photo (Optional)',
                              type: 'father',
                              imageFile: _fatherImage,
                              currentPhotoUrl: currentPhotos?.fatherPhotoUrl,
                            ),
                            const SizedBox(height: 14),

                            // Mother Photo
                            _buildSinglePhotoTile(
                              title: 'Mother Photo (Optional)',
                              type: 'mother',
                              imageFile: _motherImage,
                              currentPhotoUrl: currentPhotos?.motherPhotoUrl,
                            ),
                            const SizedBox(height: 20),

                            // Submit Button
                            Obx(() {
                              final isSubmitting = _studentsController.isSubmitting.value;

                              return SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton.icon(
                                  onPressed: isSubmitting ? null : _handleSubmit,
                                  icon: isSubmitting
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                                  label: Text(
                                    isSubmitting ? 'Submitting Request...' : 'Submit Photo Request',
                                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
