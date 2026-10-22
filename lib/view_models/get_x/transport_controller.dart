import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../models/transport_alert_model.dart';
import '../../models/transport_halt_model.dart';
import '../../models/transport_live_overview_model.dart';
import '../../models/transport_location_request_model.dart';
import '../../services/transport_service.dart';
import '../../utils/app_snackbar.dart';

class TransportController extends GetxController {
  static TransportController get to {
    if (Get.isRegistered<TransportController>()) {
      return Get.find<TransportController>();
    }
    return Get.put(TransportController(), permanent: true);
  }

  final TransportService _service = TransportService();

  var isLoading = false.obs;
  var isActionLoading = false.obs;
  var errorMessage = ''.obs;

  var isDetailLoading = false.obs;
  var detailErrorMessage = ''.obs;
  var requestDetail = Rxn<TransportLocationRequestDetailItem>();

  var isLiveLoading = false.obs;
  var liveErrorMessage = ''.obs;
  var liveSummary = Rxn<TransportLiveOverviewSummary>();
  var fleetList = <TransportFleetItem>[].obs;

  var isHaltsLoading = false.obs;
  var haltsErrorMessage = ''.obs;
  var haltsResponse = Rxn<TransportHaltResponseModel>();
  var haltsList = <TransportHaltItem>[].obs;

  var isAlertsLoading = false.obs;
  var alertsErrorMessage = ''.obs;
  var alertsResponse = Rxn<TransportAlertResponseModel>();
  var realAlertsList = <TransportAlertItem>[].obs;

  var selectedStatusFilter = 'all'.obs; // all, pending, approved, rejected

  var locationRequestsResponse = Rxn<TransportLocationRequestsResponseModel>();
  var requestsList = <TransportLocationRequestItem>[].obs;
  var summary = Rxn<TransportLocationSummary>();

  @override
  void onInit() {
    super.onInit();
    fetchLocationRequests();
  }

  Future<void> fetchLocationRequests({bool isManualRefresh = false}) async {
    if (!isManualRefresh && requestsList.isEmpty) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchLocationRequests(
        status: selectedStatusFilter.value,
      );

      locationRequestsResponse.value = response;
      if (response.data != null) {
        summary.value = response.data!.summary;
        requestsList.value = response.data!.requests;
      } else {
        requestsList.clear();
        summary.value = null;
      }
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
      fetchLocationRequests();
    }
  }

  List<TransportLocationRequestItem> get filteredRequests {
    if (selectedStatusFilter.value == 'all') {
      return requestsList;
    }
    return requestsList.where((item) {
      return item.status.toLowerCase() == selectedStatusFilter.value.toLowerCase();
    }).toList();
  }

  List<TransportFleetItem> get haltedBusesList {
    return fleetList.where((b) {
      final status = b.vehicleStatus.toLowerCase();
      final hasHalt = b.activeTrip?.activeHalt != null;
      final hasAlerts = (b.activeTrip?.activeAlertsCount ?? 0) > 0;
      return status == 'halted' || status.contains('lost') || hasHalt || hasAlerts;
    }).toList();
  }

  List<TransportFleetItem> get alertsList {
    return fleetList.where((b) {
      final isSignalLost = b.activeTrip?.telemetry?.isSignalLost == true || b.vehicleStatus.contains('lost');
      final hasHalt = b.activeTrip?.activeHalt != null;
      final hasAlerts = (b.activeTrip?.activeAlertsCount ?? 0) > 0;
      return isSignalLost || hasHalt || hasAlerts;
    }).toList();
  }

  int get totalCount => summary.value?.total ?? requestsList.length;
  int get pendingCount => summary.value?.pending ?? requestsList.where((r) => r.status.toLowerCase() == 'pending').length;
  int get approvedCount => summary.value?.approved ?? requestsList.where((r) => r.status.toLowerCase() == 'approved').length;
  int get rejectedCount => summary.value?.rejected ?? requestsList.where((r) => r.status.toLowerCase() == 'rejected').length;

  Future<void> fetchLocationRequestDetail(int id, {bool isManualRefresh = false}) async {
    if (!isManualRefresh) {
      isDetailLoading.value = true;
    }
    detailErrorMessage.value = '';

    try {
      final response = await _service.fetchLocationRequestDetail(id);
      requestDetail.value = response.data;
    } catch (e) {
      detailErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (isManualRefresh) {
        AppSnackbar.showError(
          title: 'Refresh Failed',
          message: detailErrorMessage.value,
        );
      }
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<void> fetchLiveOverview({bool isManualRefresh = false}) async {
    if (!isManualRefresh && fleetList.isEmpty) {
      isLiveLoading.value = true;
    }
    liveErrorMessage.value = '';

    try {
      final response = await _service.fetchLiveOverview();
      if (response.data != null) {
        liveSummary.value = response.data!.summary;
        fleetList.value = response.data!.fleet;
      } else {
        fleetList.clear();
        liveSummary.value = null;
      }
    } catch (e) {
      liveErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (isManualRefresh) {
        AppSnackbar.showError(
          title: 'Refresh Failed',
          message: liveErrorMessage.value,
        );
      }
    } finally {
      isLiveLoading.value = false;
    }
  }

  Future<void> fetchTransportHalts({bool isManualRefresh = false}) async {
    if (!isManualRefresh && haltsList.isEmpty) {
      isHaltsLoading.value = true;
    }
    haltsErrorMessage.value = '';

    try {
      final response = await _service.fetchTransportHalts();
      haltsResponse.value = response;
      if (response.data != null) {
        haltsList.value = response.data!.halts;
      } else {
        haltsList.clear();
      }
    } catch (e) {
      haltsErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (isManualRefresh) {
        AppSnackbar.showError(
          title: 'Refresh Failed',
          message: haltsErrorMessage.value,
        );
      }
    } finally {
      isHaltsLoading.value = false;
    }
  }

  Future<void> fetchTransportAlerts({bool isManualRefresh = false}) async {
    if (!isManualRefresh && realAlertsList.isEmpty) {
      isAlertsLoading.value = true;
    }
    alertsErrorMessage.value = '';

    try {
      final response = await _service.fetchTransportAlerts();
      alertsResponse.value = response;
      if (response.data != null) {
        realAlertsList.value = response.data!.alerts;
      } else {
        realAlertsList.clear();
      }
    } catch (e) {
      alertsErrorMessage.value = e.toString().replaceAll('Exception: ', '');
      if (isManualRefresh) {
        AppSnackbar.showError(
          title: 'Refresh Failed',
          message: alertsErrorMessage.value,
        );
      }
    } finally {
      isAlertsLoading.value = false;
    }
  }

  Future<bool> approveLocationRequest(int id, {String? remarks}) async {
    isActionLoading.value = true;
    try {
      final res = await _service.approveLocationRequest(id, remarks: remarks);
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      AppSnackbar.showSuccess(
        title: 'Request Approved',
        message: res.message,
      );
      await fetchLocationRequests(isManualRefresh: true);
      if (requestDetail.value?.id == id) {
        await fetchLocationRequestDetail(id, isManualRefresh: true);
      }
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

  Future<bool> rejectLocationRequest(int id, {String? reason}) async {
    isActionLoading.value = true;
    try {
      final res = await _service.rejectLocationRequest(id, reason: reason);
      HapticFeedback.mediumImpact();
      SystemSound.play(SystemSoundType.click);
      AppSnackbar.showSuccess(
        title: 'Request Rejected',
        message: res.message,
      );
      await fetchLocationRequests(isManualRefresh: true);
      if (requestDetail.value?.id == id) {
        await fetchLocationRequestDetail(id, isManualRefresh: true);
      }
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
