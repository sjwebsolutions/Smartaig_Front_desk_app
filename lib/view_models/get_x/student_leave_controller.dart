import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/student_leave_model.dart';
import '../../services/student_leave_service.dart';
import '../../utils/app_snackbar.dart';

class StudentLeaveController extends GetxController {
  final StudentLeaveService _service = StudentLeaveService();

  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;

  var selectedStatusFilter = 'all'.obs; // all, pending, approved, rejected
  var selectedClassId = ''.obs;
  var selectedSectionId = ''.obs;
  var selectedStreamId = ''.obs;
  var selectedDate = ''.obs;
  var searchQuery = ''.obs;

  var leavesList = <StudentLeaveItem>[].obs;
  var canApprove = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchStudentLeaves();
  }

  Future<void> fetchStudentLeaves({bool isManualRefresh = false}) async {
    if (!isManualRefresh && leavesList.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchStudentLeaves(
        status: selectedStatusFilter.value,
        date: selectedDate.value,
        studentClassId: selectedClassId.value,
        studentSectionId: selectedSectionId.value,
        studentStreamId: selectedStreamId.value,
      );

      canApprove.value = response.canApprove;
      leavesList.value = response.data;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
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

  void changeStatusFilter(String status) {
    if (selectedStatusFilter.value != status) {
      selectedStatusFilter.value = status;
      fetchStudentLeaves();
    }
  }

  void applyClassSectionFilter({
    String? classId,
    String? sectionId,
    String? streamId,
    String? date,
  }) {
    selectedClassId.value = classId ?? '';
    selectedSectionId.value = sectionId ?? '';
    selectedStreamId.value = streamId ?? '';
    selectedDate.value = date ?? '';
    fetchStudentLeaves();
  }

  void clearAllFilters() {
    selectedStatusFilter.value = 'all';
    selectedClassId.value = '';
    selectedSectionId.value = '';
    selectedStreamId.value = '';
    selectedDate.value = '';
    searchQuery.value = '';
    fetchStudentLeaves();
  }

  List<StudentLeaveItem> get filteredLeaves {
    return leavesList.where((item) {
      // Status filter
      if (selectedStatusFilter.value != 'all') {
        if (item.status.toLowerCase() != selectedStatusFilter.value.toLowerCase()) {
          return false;
        }
      }

      // Local search filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final name = item.studentName.toLowerCase();
        final admNo = (item.admissionNumber ?? '').toLowerCase();
        final rollNo = (item.rollNo ?? '').toLowerCase();
        final className = (item.className ?? '').toLowerCase();
        final sectionName = (item.sectionName ?? '').toLowerCase();
        final reason = (item.reason ?? '').toLowerCase();
        final id = item.id.toString();

        return name.contains(query) ||
            admNo.contains(query) ||
            rollNo.contains(query) ||
            className.contains(query) ||
            sectionName.contains(query) ||
            reason.contains(query) ||
            id.contains(query);
      }

      return true;
    }).toList();
  }

  int get totalCount => leavesList.length;
  int get pendingCount => leavesList.where((l) => l.status.toLowerCase() == 'pending').length;
  int get approvedCount => leavesList.where((l) => l.status.toLowerCase() == 'approved').length;
  int get rejectedCount => leavesList.where((l) => l.status.toLowerCase() == 'rejected').length;

  Future<bool> approveLeave(int id, {String? remarks}) async {
    isActionLoading.value = true;
    try {
      final res = await _service.approveStudentLeave(id, remarks: remarks);
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      AppSnackbar.showSuccess(
        title: 'Leave Approved',
        message: res.message,
      );
      await fetchStudentLeaves(isManualRefresh: true);
      return true;
    } catch (e) {
      AppSnackbar.showError(
        title: 'Approve Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }

  Future<bool> rejectLeave(int id, {required String reason}) async {
    isActionLoading.value = true;
    try {
      final res = await _service.rejectStudentLeave(id, reason: reason);
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      AppSnackbar.showSuccess(
        title: 'Leave Rejected',
        message: res.message,
      );
      await fetchStudentLeaves(isManualRefresh: true);
      return true;
    } catch (e) {
      AppSnackbar.showError(
        title: 'Reject Failed',
        message: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    } finally {
      isActionLoading.value = false;
    }
  }
}
