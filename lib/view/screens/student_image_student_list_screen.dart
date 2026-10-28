import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/student_image_classes_model.dart';
import '../../models/student_image_students_model.dart';
import '../../utils/app_snackbar.dart';
import '../../view_models/get_x/student_image_students_controller.dart';

class StudentImageStudentListScreen extends StatefulWidget {
  final StudentClassItem selectedClass;
  final StudentSectionItem? initialSection;
  final StudentStreamItem? initialStream;

  const StudentImageStudentListScreen({
    super.key,
    required this.selectedClass,
    this.initialSection,
    this.initialStream,
  });

  @override
  State<StudentImageStudentListScreen> createState() => _StudentImageStudentListScreenState();
}

class _StudentImageStudentListScreenState extends State<StudentImageStudentListScreen> {
  late final StudentImageStudentsController _studentsController;
  final TextEditingController _searchController = TextEditingController();

  StudentSectionItem? _selectedSection;
  StudentStreamItem? _selectedStream;

  @override
  void initState() {
    super.initState();
    _studentsController = Get.put(StudentImageStudentsController());
    _selectedSection = widget.initialSection;
    _selectedStream = widget.initialStream;

    _fetchStudents();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _fetchStudents() {
    if (widget.selectedClass.classId != null) {
      _studentsController.fetchStudents(
        classId: widget.selectedClass.classId!,
        sectionId: _selectedSection?.sectionId,
        streamId: _selectedStream?.streamId,
      );
    }
  }

  void _openUploadDialog(StudentImageStudentItem student) {
    XFile? studentImage;
    XFile? fatherImage;
    XFile? motherImage;
    final ImagePicker picker = ImagePicker();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          Future<void> pickPhoto(String type) async {
            try {
              final picked = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
              if (picked != null) {
                setModalState(() {
                  if (type == 'profile') studentImage = picked;
                  if (type == 'father') fatherImage = picked;
                  if (type == 'mother') motherImage = picked;
                });
              }
            } catch (_) {
              AppSnackbar.showError(title: 'Image Error', message: 'Could not capture image.');
            }
          }

          return Container(
            constraints: BoxConstraints(maxHeight: Get.height * 0.85),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Upload Photo: ${student.studentName ?? ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.grey),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Student Details Badge
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.badge_rounded, color: Color(0xFF4F46E5), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'ID: ${student.studentUniqueId ?? '-'}  •  Roll: ${student.rollNo ?? '-'}',
                          style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.w600, color: const Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Photo Tiles
                  _buildCameraTile(
                    title: 'Student Photo',
                    image: studentImage,
                    onTap: () => pickPhoto('profile'),
                    onRemove: () => setModalState(() => studentImage = null),
                  ),
                  const SizedBox(height: 12),

                  _buildCameraTile(
                    title: 'Father Photo (Optional)',
                    image: fatherImage,
                    onTap: () => pickPhoto('father'),
                    onRemove: () => setModalState(() => fatherImage = null),
                  ),
                  const SizedBox(height: 12),

                  _buildCameraTile(
                    title: 'Mother Photo (Optional)',
                    image: motherImage,
                    onTap: () => pickPhoto('mother'),
                    onRemove: () => setModalState(() => motherImage = null),
                  ),
                  const SizedBox(height: 20),

                  // Submit Button inside Modal
                  Obx(() {
                    final isSubmitting = _studentsController.isSubmitting.value;

                    return SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (studentImage == null && fatherImage == null && motherImage == null) {
                                  AppSnackbar.showError(title: 'Required Field', message: 'Please capture at least one photo.');
                                  return;
                                }

                                final res = await _studentsController.submitStudentImageRequest(
                                  studentId: student!.id!,
                                  profileImageFile: studentImage != null ? File(studentImage!.path) : null,
                                  fatherImageFile: fatherImage != null ? File(fatherImage!.path) : null,
                                  motherImageFile: motherImage != null ? File(motherImage!.path) : null,
                                );

                                if (res != null && res.success == true) {
                                  Get.back();
                                  _fetchStudents();
                                }
                              },
                        icon: isSubmitting
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Icon(Icons.cloud_upload_rounded, color: Colors.white, size: 20),
                        label: Text(
                          isSubmitting ? 'Submitting...' : 'Submit Photo Request',
                          style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4F46E5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildCameraTile({
    required String title,
    required XFile? image,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: image != null ? const Color(0xFF4F46E5) : Colors.grey.shade300,
            width: image != null ? 1.5 : 1.0,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(File(image.path), fit: BoxFit.cover),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Row(
                        children: [
                          Container(
                            decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                            child: IconButton(
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                              onPressed: onTap,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                            child: IconButton(
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.delete_rounded, color: Colors.white, size: 16),
                              onPressed: onRemove,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  const SizedBox(width: 16),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEEF2FF),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF4F46E5), size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap to capture via Camera',
                          style: GoogleFonts.poppins(fontSize: 11.5, color: const Color(0xFF4F46E5), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  const SizedBox(width: 12),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final className = widget.selectedClass.className ?? 'Class';
    final sections = widget.selectedClass.sections ?? [];

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
                          '$className STUDENTS',
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
                    IconButton(
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF4F46E5), size: 20),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: const CircleBorder(),
                        elevation: 2,
                        shadowColor: Colors.black12,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: _fetchStudents,
                      tooltip: 'Refresh',
                    ),
                  ],
                ),
              ),

              // Section Selector Filter Row
              if (sections.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: Text('All Sections', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                        selected: _selectedSection == null,
                        selectedColor: const Color(0xFF4F46E5),
                        labelStyle: TextStyle(color: _selectedSection == null ? Colors.white : const Color(0xFF1E293B)),
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedSection = null);
                            _fetchStudents();
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      ...sections.map((sec) {
                        final isSel = _selectedSection?.sectionId == sec.sectionId;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text('Section ${sec.sectionName ?? ''}', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600)),
                            selected: isSel,
                            selectedColor: const Color(0xFF4F46E5),
                            labelStyle: TextStyle(color: isSel ? Colors.white : const Color(0xFF1E293B)),
                            onSelected: (selected) {
                              if (selected) {
                                setState(() => _selectedSection = sec);
                                _fetchStudents();
                              }
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      _studentsController.searchQuery.value = val;
                    },
                    style: GoogleFonts.poppins(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Search student name, roll no, or ID...',
                      hintStyle: GoogleFonts.poppins(fontSize: 13, color: Colors.grey.shade500),
                      prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF4F46E5), size: 20),
                      suffixIcon: Obx(() {
                        return _studentsController.searchQuery.value.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
                                onPressed: () {
                                  _searchController.clear();
                                  _studentsController.searchQuery.value = '';
                                },
                              )
                            : const SizedBox.shrink();
                      }),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              // Student List Body
              Expanded(
                child: Obx(() {
                  final isLoading = _studentsController.isLoading.value;
                  final students = _studentsController.filteredStudents;

                  if (isLoading && students.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                    );
                  }

                  if (students.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person_search_rounded, color: Colors.indigo.shade200, size: 54),
                          const SizedBox(height: 12),
                          Text(
                            'No students found in $className',
                            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFF4F46E5),
                    onRefresh: () async => _fetchStudents(),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      padding: const EdgeInsets.fromLTRB(14, 6, 14, 20),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return _buildStudentCard(student);
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

  Widget _buildStudentCard(StudentImageStudentItem student) {
    final photoUrl = student.currentPhotos?.studentPhotoUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: const Color(0xFFEEF2FF),
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Text(
                          (student.studentName ?? 'S')[0].toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
                        )
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.studentName ?? '',
                              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (student.hasPendingRequest == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Pending Request',
                                style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Roll No: ${student.rollNo ?? '-'}  •  ID: ${student.studentUniqueId ?? '-'}',
                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade700),
                      ),
                      if (student.fatherName != null && student.fatherName!.isNotEmpty)
                        Text(
                          'Father: ${student.fatherName}',
                          style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade600),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 38,
              child: ElevatedButton.icon(
                onPressed: () => _openUploadDialog(student),
                icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                label: Text(
                  'Upload Student Photo',
                  style: GoogleFonts.poppins(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
