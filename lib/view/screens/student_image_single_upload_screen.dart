import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/student_image_students_model.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/student_image_students_controller.dart';
import 'image_crop_screen.dart';
import 'live_face_camera_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _studentsController = Get.isRegistered<StudentImageStudentsController>()
        ? Get.find<StudentImageStudentsController>()
        : Get.put(StudentImageStudentsController());
    _loadLocalPhotos();
  }

  Future<void> _loadLocalPhotos() async {
    try {
      final studentId = widget.student.id;
      if (studentId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final profilePath = prefs.getString('local_photo_profile_$studentId');
      final fatherPath = prefs.getString('local_photo_father_$studentId');
      final motherPath = prefs.getString('local_photo_mother_$studentId');

      if (mounted) {
        setState(() {
          if (profilePath != null && File(profilePath).existsSync()) {
            _studentProfileImage = XFile(profilePath);
          }
          if (fatherPath != null && File(fatherPath).existsSync()) {
            _fatherImage = XFile(fatherPath);
          }
          if (motherPath != null && File(motherPath).existsSync()) {
            _motherImage = XFile(motherPath);
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _saveLocalPhoto(String type, String path) async {
    try {
      final studentId = widget.student.id;
      if (studentId == null) return;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('local_photo_${type}_$studentId', path);
    } catch (_) {}
  }

  void _showImageSourceOptions(String type, String title) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Drag Indicator
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select $title',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Camera Option Card
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        _pickFromCamera(type, title);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF4F46E5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Camera',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Gallery Option Card
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Get.back();
                        _pickFromGallery(type, title);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF16A34A),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.photo_library_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Gallery',
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1E293B),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickFromCamera(String type, String label) async {
    try {
      final XFile? confirmed = await Get.to(() => LiveFaceCameraScreen(title: label));

      if (confirmed != null) {
        await _updatePhoto(type, confirmed);
      }
    } catch (e) {
      debugPrint('Camera error: $e');
      AppSnackbar.showError(title: 'Camera Error', message: 'Could not open live camera view.');
    }
  }

  Future<void> _pickFromGallery(String type, String title) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        final XFile? cropped = await Get.to<XFile>(
          () => ImageCropScreen(
            imageFile: File(image.path),
            title: 'Crop $title',
          ),
        );
        if (cropped != null) {
          await _updatePhoto(type, cropped);
        }
      }
    } catch (e) {
      debugPrint('Gallery error: $e');
      AppSnackbar.showError(title: 'Gallery Error', message: 'Could not open gallery.');
    }
  }

  Future<void> _updatePhoto(String type, XFile image) async {
    setState(() {
      if (type == 'profile') _studentProfileImage = image;
      if (type == 'father') _fatherImage = image;
      if (type == 'mother') _motherImage = image;
    });
    await _saveLocalPhoto(type, image.path);
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

    // Save locally
    if (_studentProfileImage != null) {
      await _saveLocalPhoto('profile', _studentProfileImage!.path);
    }
    if (_fatherImage != null) {
      await _saveLocalPhoto('father', _fatherImage!.path);
    }
    if (_motherImage != null) {
      await _saveLocalPhoto('mother', _motherImage!.path);
    }

    final res = await _studentsController.submitStudentImageRequest(
      studentId: widget.student.id!,
      profileImageFile: _studentProfileImage != null ? File(_studentProfileImage!.path) : null,
      fatherImageFile: _fatherImage != null ? File(_fatherImage!.path) : null,
      motherImageFile: _motherImage != null ? File(_motherImage!.path) : null,
    );

    if (res != null && res.success == true) {
      AppSnackbar.showSuccess(
        title: 'Success',
        message: 'Student photo request submitted and saved locally.',
      );
      Get.back(result: true);
    }
  }

  Widget _buildSinglePhotoTile({
    required String title,
    required String type,
    required XFile? imageFile,
    required String? currentPhotoUrl,
  }) {
    final bool hasNewImage = imageFile != null;
    final bool hasCurrentPhoto = currentPhotoUrl != null && currentPhotoUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasNewImage ? const Color(0xFF4F46E5) : Colors.grey.shade300,
          width: hasNewImage ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Square Image Box on Left
          GestureDetector(
            onTap: () => _showImageSourceOptions(type, title),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hasNewImage ? const Color(0xFF4F46E5) : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: hasNewImage
                    ? Image.file(
                        File(imageFile.path),
                        fit: BoxFit.cover,
                      )
                    : hasCurrentPhoto
                        ? Image.network(
                            currentPhotoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.person_rounded, color: Colors.grey, size: 24),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.add_a_photo_rounded, size: 20, color: Color(0xFF4F46E5)),
                              const SizedBox(height: 2),
                              Text(
                                'Add Photo',
                                style: GoogleFonts.poppins(fontSize: 9, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
                              ),
                            ],
                          ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasNewImage
                      ? 'Saved locally'
                      : (hasCurrentPhoto ? 'Current photo available' : 'Photo required'),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: hasNewImage
                        ? const Color(0xFF16A34A)
                        : (hasCurrentPhoto ? const Color(0xFF4F46E5) : Colors.grey.shade600),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Action Button on Right
          ElevatedButton.icon(
            onPressed: () => _showImageSourceOptions(type, title),
            icon: const Icon(Icons.add_a_photo_rounded, size: 14, color: Colors.white),
            label: Text(
              hasNewImage ? 'Change' : 'Select',
              style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
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
                      // PHOTO CAPTURE SECTION CARD
                      Container(
                        padding: const EdgeInsets.all(14),
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
                              'Select or Capture Photos',
                              style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                            ),
                            const SizedBox(height: 12),

                            // Student Profile Photo
                            _buildSinglePhotoTile(
                              title: 'Student Profile Photo',
                              type: 'profile',
                              imageFile: _studentProfileImage,
                              currentPhotoUrl: currentPhotos?.studentPhotoUrl,
                            ),

                            // Father Photo
                            _buildSinglePhotoTile(
                              title: 'Father Photo',
                              type: 'father',
                              imageFile: _fatherImage,
                              currentPhotoUrl: currentPhotos?.fatherPhotoUrl,
                            ),

                            // Mother Photo
                            _buildSinglePhotoTile(
                              title: 'Mother Photo',
                              type: 'mother',
                              imageFile: _motherImage,
                              currentPhotoUrl: currentPhotos?.motherPhotoUrl,
                            ),
                            const SizedBox(height: 10),

                            // Submit Button
                            Obx(() {
                              final isSubmitting = _studentsController.isSubmitting.value;

                              return SizedBox(
                                width: double.infinity,
                                height: 44,
                                child: ElevatedButton.icon(
                                  onPressed: isSubmitting ? null : _handleSubmit,
                                  icon: isSubmitting
                                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                      : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 18),
                                  label: Text(
                                    isSubmitting ? 'Submitting Request...' : 'Submit Photo Request',
                                    style: GoogleFonts.poppins(fontSize: 13.5, fontWeight: FontWeight.bold, color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4F46E5),
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
