import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/student_image_students_model.dart';
import '../../services/student_image_students_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';

class StudentImageStudentsController extends GetxController {
  final StudentImageStudentsService _service = StudentImageStudentsService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var studentsList = <StudentImageStudentItem>[].obs;
  var totalCount = 0.obs;
  var searchQuery = ''.obs;
  var selectedStudent = Rxn<StudentImageStudentItem>();

  Future<void> fetchStudents({
    required dynamic classId,
    dynamic sectionId,
    dynamic streamId,
    bool isManualRefresh = false,
  }) async {
    if (classId == null) return;

    if (!isManualRefresh) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      debugPrint('🚀 [StudentImageStudentsController] Fetching students for classId=$classId, sectionId=$sectionId, streamId=$streamId');
      final response = await _service.fetchStudents(
        classId: classId,
        sectionId: sectionId,
        streamId: streamId,
        search: searchQuery.value,
      );

      if (response.success == true || response.data != null) {
        studentsList.value = response.data ?? [];
        totalCount.value = response.count ?? studentsList.length;
        debugPrint('✅ [StudentImageStudentsController] Loaded ${studentsList.length} students');
      } else {
        errorMessage.value = response.message ?? 'Failed to load students';
      }
    } catch (e, stack) {
      debugPrint('❌ [StudentImageStudentsController Exception]: $e\n$stack');
      errorMessage.value = AppErrorFormatter.format(e);
      if (isManualRefresh) {
        AppSnackbar.showError(
          title: 'Refresh Failed',
          message: errorMessage.value,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void selectStudent(StudentImageStudentItem? student) {
    selectedStudent.value = student;
  }

  List<StudentImageStudentItem> get filteredStudents {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return studentsList;

    return studentsList.where((s) {
      final name = (s.studentName ?? '').toLowerCase();
      final uniqueId = (s.studentUniqueId ?? '').toLowerCase();
      final rollNo = (s.rollNo ?? '').toLowerCase();
      final fatherName = (s.fatherName ?? '').toLowerCase();

      return name.contains(query) ||
          uniqueId.contains(query) ||
          rollNo.contains(query) ||
          fatherName.contains(query);
    }).toList();
  }
}
