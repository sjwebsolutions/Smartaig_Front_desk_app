import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/student_image_classes_model.dart';
import '../../models/student_image_students_model.dart';
import '../../view_models/get_x/student_image_students_controller.dart';
import 'student_image_single_upload_screen.dart';

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

  void _fetchStudents() {
    if (widget.selectedClass.classId != null) {
      _studentsController.fetchStudents(
        classId: widget.selectedClass.classId!,
        sectionId: _selectedSection?.sectionId,
        streamId: _selectedStream?.streamId,
      );
    }
  }

  void _navigateToUploadScreen(StudentImageStudentItem student) {
    Get.to(() => StudentImageSingleUploadScreen(student: student))?.then((res) {
      if (res == true) {
        _fetchStudents();
      }
    });
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
                    const SizedBox(width: 32),
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

              const SizedBox(height: 6),

              // Student List Body
              Expanded(
                child: Obx(() {
                  final isLoading = _studentsController.isLoading.value;
                  final students = _studentsController.studentsList;

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
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _navigateToUploadScreen(student),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFEEF2FF),
                  backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                  child: (photoUrl == null || photoUrl.isEmpty)
                      ? Text(
                          (student.studentName ?? 'S')[0].toUpperCase(),
                          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF4F46E5)),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              student.studentName ?? '',
                              style: GoogleFonts.poppins(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (student.hasPendingRequest == true)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Pending',
                                style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Roll: ${student.rollNo ?? '-'}  •  ID: ${student.studentUniqueId ?? '-'}',
                        style: GoogleFonts.poppins(fontSize: 11.5, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                      ),
                      if (student.fatherName != null && student.fatherName!.isNotEmpty)
                        Text(
                          'Father: ${student.fatherName}',
                          style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey.shade600),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
                  onPressed: () => _navigateToUploadScreen(student),
                  icon: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.all(10),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  tooltip: 'Upload Photo',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
