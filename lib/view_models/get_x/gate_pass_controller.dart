import 'dart:async';
import 'package:get/get.dart';
import '../../models/gate_pass_model.dart';
import '../../services/gate_pass_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';
import 'dashboard_controller.dart';

class GatePassController extends GetxController {
  final GatePassService _service = GatePassService();

  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var errorMessage = ''.obs;

  var gatePassList = <GatePassItem>[].obs;
  var selectedStatus = 'pending'.obs; // 'pending', 'approved', 'rejected', 'all'
  var searchQuery = ''.obs;
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    fetchGatePasses();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    // Live real-time sync every 8 seconds while on Gate Pass screen
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchGatePasses(isRefresh: true, isSilent: true);
    });
  }

  Future<void> fetchGatePasses({bool isRefresh = false, bool isSilent = false}) async {
    if (!isSilent) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchGatePasses(
        status: selectedStatus.value,
      );

      if (response.success == true && response.data != null) {
        gatePassList.value = response.data!;
      } else {
        if (!isSilent) {
          gatePassList.clear();
          errorMessage.value = response.message ?? 'Failed to load gate passes';
        }
      }
    } catch (e) {
      if (!isSilent) {
        errorMessage.value = AppErrorFormatter.format(e);
      }
    } finally {
      if (!isSilent) {
        isLoading.value = false;
      }
    }
  }

  void filterByStatus(String status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      fetchGatePasses();
    }
  }

  List<GatePassItem> get filteredGatePasses {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return gatePassList;
    }
    return gatePassList.where((item) {
      final passNo = item.gatePassNo?.toLowerCase() ?? '';
      final student = item.student?.name?.toLowerCase() ?? '';
      final guardian = item.guardian?.personName?.toLowerCase() ?? '';
      final reason = item.reason?.toLowerCase() ?? '';

      return passNo.contains(query) ||
          student.contains(query) ||
          guardian.contains(query) ||
          reason.contains(query);
    }).toList();
  }

  var approvedGatePassData = Rxn<GatePassApprovalData>();

  Future<bool> approvePass(int id) async {
    isUpdatingStatus.value = true;
    try {
      final ApproveGatePassResponseModel response = await _service.approveGatePass(id);
      final isSuccess = response.success == true;
      if (isSuccess) {
        approvedGatePassData.value = response.data;
        AppSnackbar.showSuccess(
          title: 'Gate Pass Approved',
          message: response.message ?? 'Gate Pass #$id has been approved successfully.',
        );
        fetchGatePasses();
        if (Get.isRegistered<DashboardController>()) {
          try {
            Get.find<DashboardController>().fetchDashboard(isSilent: true);
          } catch (_) {}
        }
        return true;
      } else {
        AppSnackbar.showError(
          title: 'Failed',
          message: response.message ?? 'Could not approve gate pass.',
        );
        return false;
      }
    } catch (e) {
      AppSnackbar.showError(
        title: AppErrorFormatter.getTitle(e, defaultTitle: 'Error'),
        message: AppErrorFormatter.format(e),
      );
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }

  var rejectedGatePassData = Rxn<GatePassRejectionData>();

  Future<bool> rejectPass(int id, {String? reason}) async {
    isUpdatingStatus.value = true;
    try {
      final RejectGatePassResponseModel response = await _service.rejectGatePass(id, reason: reason);
      final isSuccess = response.success == true;
      if (isSuccess) {
        rejectedGatePassData.value = response.data;
        AppSnackbar.showSuccess(
          title: 'Gate Pass Rejected',
          message: response.message ?? 'Gate Pass #$id has been rejected.',
        );
        fetchGatePasses();
        if (Get.isRegistered<DashboardController>()) {
          try {
            Get.find<DashboardController>().fetchDashboard(isSilent: true);
          } catch (_) {}
        }
        return true;
      } else {
        AppSnackbar.showError(
          title: 'Failed',
          message: response.message ?? 'Could not reject gate pass.',
        );
        return false;
      }
    } catch (e) {
      AppSnackbar.showError(
        title: AppErrorFormatter.getTitle(e, defaultTitle: 'Error'),
        message: AppErrorFormatter.format(e),
      );
      return false;
    } finally {
      isUpdatingStatus.value = false;
    }
  }
}
