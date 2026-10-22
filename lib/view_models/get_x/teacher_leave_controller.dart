import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/teacher_leave_model.dart';
import '../../services/teacher_leave_service.dart';
import '../../utils/app_snackbar.dart';

class TeacherLeaveController extends GetxController {
  final TeacherLeaveService _service = TeacherLeaveService();

  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;

  var selectedStatusFilter = 'pending'.obs; // pending, approved, rejected, all
  var selectedDate = ''.obs; // YYYY-MM-DD
  var searchQuery = ''.obs;

  var leavesList = <TeacherLeaveItem>[].obs;
  var canApprove = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTeacherLeaves();
  }

  Future<void> fetchTeacherLeaves({bool isManualRefresh = false}) async {
    if (!isManualRefresh && leavesList.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchTeacherLeaves(
        status: selectedStatusFilter.value,
        date: selectedDate.value,
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
      fetchTeacherLeaves();
    }
  }

  void applyDateFilter(String date) {
    selectedDate.value = date;
    fetchTeacherLeaves();
  }

  void clearDateFilter() {
    if (selectedDate.value.isNotEmpty) {
      selectedDate.value = '';
      fetchTeacherLeaves();
    }
  }

  void clearAllFilters() {
    selectedStatusFilter.value = 'all';
    selectedDate.value = '';
    searchQuery.value = '';
    fetchTeacherLeaves();
  }

  List<TeacherLeaveItem> get filteredLeaves {
    final list = leavesList.where((item) {
      // Status filter
      if (selectedStatusFilter.value != 'all') {
        if (item.status.toLowerCase() != selectedStatusFilter.value.toLowerCase()) {
          return false;
        }
      }

      // Local search query filter
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final name = item.teacherName.toLowerCase();
        final code = (item.teacherCode ?? '').toLowerCase();
        final phone = (item.teacherPhone ?? '').toLowerCase();
        final designation = (item.teacherDesignation ?? '').toLowerCase();
        final leaveType = item.leaveTypeLabel.toLowerCase();
        final dayType = item.dayTypeLabel.toLowerCase();
        final reason = (item.reason ?? '').toLowerCase();
        final id = item.id.toString();

        return name.contains(query) ||
            code.contains(query) ||
            phone.contains(query) ||
            designation.contains(query) ||
            leaveType.contains(query) ||
            dayType.contains(query) ||
            reason.contains(query) ||
            id.contains(query);
      }

      return true;
    }).toList();

    // Priority sorting: Pending leaves always at the top (priority 1), followed by other leaves
    list.sort((a, b) {
      final aPending = a.status.toLowerCase() == 'pending';
      final bPending = b.status.toLowerCase() == 'pending';

      if (aPending && !bPending) return -1;
      if (!aPending && bPending) return 1;

      return b.id.compareTo(a.id); // Latest first within same status
    });

    return list;
  }

  int get totalCount => leavesList.length;
  int get pendingCount => leavesList.where((l) => l.status.toLowerCase() == 'pending').length;
  int get approvedCount => leavesList.where((l) => l.status.toLowerCase() == 'approved').length;
  int get rejectedCount => leavesList.where((l) => l.status.toLowerCase() == 'rejected').length;

  Future<bool> approveLeave(int id, {String? remarks}) async {
    isActionLoading.value = true;
    try {
      final res = await _service.approveTeacherLeave(id, remarks: remarks);
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      AppSnackbar.showSuccess(
        title: 'Leave Approved',
        message: res.message,
      );
      await fetchTeacherLeaves(isManualRefresh: true);
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
      final res = await _service.rejectTeacherLeave(id, reason: reason);
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      AppSnackbar.showSuccess(
        title: 'Leave Rejected',
        message: res.message,
      );
      await fetchTeacherLeaves(isManualRefresh: true);
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
