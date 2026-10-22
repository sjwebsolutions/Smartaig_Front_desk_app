import 'package:get/get.dart';
import '../../models/leave_model.dart';
import '../../utils/app_snackbar.dart';

class LeaveController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedFilter = 'All'.obs; // All, Pending, Approved, Rejected
  var searchQuery = ''.obs;

  var leavesList = <LeaveItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchLeaves();
  }

  void fetchLeaves() {
    isLoading.value = true;
    errorMessage.value = '';

    // Initial mock data for Leaves
    Future.delayed(const Duration(milliseconds: 300), () {
      leavesList.value = [
        LeaveItem(
          id: 'LV-1001',
          applicantName: 'Ramesh Sharma',
          applicantRole: 'Senior Teacher',
          leaveType: 'Casual Leave',
          fromDate: '14 Oct 2024',
          toDate: '15 Oct 2024',
          daysCount: 2,
          reason: 'Family function in hometown',
          status: 'Pending',
          appliedDate: '12 Oct 2024',
        ),
        LeaveItem(
          id: 'LV-1002',
          applicantName: 'Priya Verma',
          applicantRole: 'Front Desk Staff',
          leaveType: 'Sick Leave',
          fromDate: '10 Oct 2024',
          toDate: '10 Oct 2024',
          daysCount: 1,
          reason: 'Severe fever and doctor consultation',
          status: 'Approved',
          appliedDate: '09 Oct 2024',
          approvedBy: 'Principal Office',
        ),
        LeaveItem(
          id: 'LV-1003',
          applicantName: 'Anil Kumar',
          applicantRole: 'Lab Assistant',
          leaveType: 'Earned Leave',
          fromDate: '05 Oct 2024',
          toDate: '08 Oct 2024',
          daysCount: 4,
          reason: 'Personal urgent work',
          status: 'Approved',
          appliedDate: '01 Oct 2024',
          approvedBy: 'HR Manager',
        ),
        LeaveItem(
          id: 'LV-1004',
          applicantName: 'Sunita Mishra',
          applicantRole: 'Accountant',
          leaveType: 'Emergency Leave',
          fromDate: '18 Oct 2024',
          toDate: '19 Oct 2024',
          daysCount: 2,
          reason: 'Medical emergency in family',
          status: 'Pending',
          appliedDate: '13 Oct 2024',
        ),
        LeaveItem(
          id: 'LV-1005',
          applicantName: 'Rajesh Gupta',
          applicantRole: 'Physical Educator',
          leaveType: 'Casual Leave',
          fromDate: '28 Sep 2024',
          toDate: '29 Sep 2024',
          daysCount: 2,
          reason: 'Attending sports seminar',
          status: 'Rejected',
          appliedDate: '25 Sep 2024',
          remarks: 'Overlapping with sports event date',
        ),
      ];
      isLoading.value = false;
    });
  }

  List<LeaveItem> get filteredLeaves {
    return leavesList.where((leave) {
      // Filter by status
      if (selectedFilter.value != 'All') {
        if (leave.status.toLowerCase() != selectedFilter.value.toLowerCase()) {
          return false;
        }
      }

      // Filter by search query
      if (searchQuery.value.trim().isNotEmpty) {
        final query = searchQuery.value.trim().toLowerCase();
        final name = leave.applicantName.toLowerCase();
        final role = leave.applicantRole.toLowerCase();
        final type = leave.leaveType.toLowerCase();
        final reason = leave.reason.toLowerCase();
        final id = leave.id.toLowerCase();

        return name.contains(query) ||
            role.contains(query) ||
            type.contains(query) ||
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

  void applyLeave(LeaveItem newItem) {
    leavesList.insert(0, newItem);
    AppSnackbar.showSuccess(
      title: 'Leave Applied',
      message: 'Leave request submitted successfully for ${newItem.applicantName}',
    );
  }

  void updateLeaveStatus(String id, String newStatus, {String? remark}) {
    final index = leavesList.indexWhere((l) => l.id == id);
    if (index != -1) {
      final old = leavesList[index];
      leavesList[index] = LeaveItem(
        id: old.id,
        applicantName: old.applicantName,
        applicantRole: old.applicantRole,
        leaveType: old.leaveType,
        fromDate: old.fromDate,
        toDate: old.toDate,
        daysCount: old.daysCount,
        reason: old.reason,
        status: newStatus,
        appliedDate: old.appliedDate,
        approvedBy: newStatus == 'Approved' ? 'Front Desk Admin' : old.approvedBy,
        remarks: remark ?? old.remarks,
      );
      leavesList.refresh();

      if (newStatus == 'Approved') {
        AppSnackbar.showSuccess(
          title: 'Leave Approved',
          message: 'Leave request for ${old.applicantName} has been approved.',
        );
      } else if (newStatus == 'Rejected') {
        AppSnackbar.showError(
          title: 'Leave Rejected',
          message: 'Leave request for ${old.applicantName} has been rejected.',
        );
      }
    }
  }
}
