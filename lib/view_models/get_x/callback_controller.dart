import 'dart:async';
import 'package:get/get.dart';
import '../../models/callback_model.dart';
import '../../services/callback_service.dart';
import '../../utils/app_error_formatter.dart';
import '../../utils/app_snackbar.dart';

class CallbackController extends GetxController {
  final CallbackService _service = CallbackService();

  var isLoading = false.obs;
  var isUpdatingStatus = false.obs;
  var isStoringNote = false.obs;
  var errorMessage = ''.obs;

  var isDetailLoading = false.obs;
  var detailErrorMessage = ''.obs;
  var selectedDetail = Rxn<CallbackDetailItem>();

  var selectedStatus = 'all'.obs; // 'all', 'pending', 'in_progress', 'completed'
  var selectedDate = ''.obs; // YYYY-MM-DD
  var currentPage = 1.obs;

  var counts = CallbackCounts().obs;
  var callbackList = <CallbackRequestItem>[].obs;
  var meta = CallbackMeta().obs;
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    fetchCallbacks();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    // Live real-time sync every 8 seconds while on Call Back screen
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchCallbacks(isRefresh: true, isSilent: true);
    });
  }

  Future<void> fetchCallbacks({bool isRefresh = false, bool isSilent = false}) async {
    if (isRefresh) {
      currentPage.value = 1;
    }

    if (!isSilent) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchCallbackRequests(
        status: selectedStatus.value,
        date: selectedDate.value,
        page: currentPage.value,
      );

      if (response.success == true) {
        if (response.counts != null) {
          counts.value = response.counts!;
        }
        if (response.meta != null) {
          meta.value = response.meta!;
        }
        if (response.data != null) {
          callbackList.value = response.data!;
        } else {
          if (!isSilent) {
            callbackList.clear();
          }
        }
      } else {
        if (!isSilent) {
          errorMessage.value = response.message ?? 'Failed to load callback requests';
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

  Future<void> fetchCallbackDetail(int id) async {
    isDetailLoading.value = true;
    detailErrorMessage.value = '';
    selectedDetail.value = null;

    try {
      final response = await _service.fetchCallbackDetail(id);

      if (response.success == true && response.data != null) {
        selectedDetail.value = response.data;
      } else {
        detailErrorMessage.value = response.message ?? 'Failed to load request details';
      }
    } catch (e) {
      detailErrorMessage.value = AppErrorFormatter.format(e);
    } finally {
      isDetailLoading.value = false;
    }
  }

  Future<bool> storeNote({
    required int callbackId,
    required String notes,
    String? callStatus,
    String? updateStatusTo,
  }) async {
    isStoringNote.value = true;
    try {
      final response = await _service.storeCallbackNote(
        callbackId: callbackId,
        notes: notes,
        callStatus: callStatus,
        updateStatusTo: updateStatusTo,
      );

      if (response.success == true) {
        AppSnackbar.showSuccess(
          title: 'Note Logged',
          message: response.message ?? 'Call note logged successfully.',
        );
        fetchCallbacks();
        if (selectedDetail.value?.id == callbackId) {
          fetchCallbackDetail(callbackId);
        }
        return true;
      } else {
        AppSnackbar.showError(
          title: 'Failed',
          message: response.message ?? 'Could not log call note.',
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
      isStoringNote.value = false;
    }
  }

  void filterByStatus(String status) {
    if (selectedStatus.value != status) {
      selectedStatus.value = status;
      currentPage.value = 1;
      fetchCallbacks();
    }
  }

  void filterByDate(String date) {
    selectedDate.value = date;
    currentPage.value = 1;
    fetchCallbacks();
  }

  void clearDateFilter() {
    selectedDate.value = '';
    currentPage.value = 1;
    fetchCallbacks();
  }

  Future<bool> updateStatus(int id, String newStatus, {String? notes}) async {
    isUpdatingStatus.value = true;
    try {
      final response = await _service.updateCallbackStatus(
        callbackId: id,
        status: newStatus,
        notes: notes,
      );

      if (response.success == true) {
        AppSnackbar.showSuccess(
          title: 'Status Updated',
          message: response.message ?? 'Callback request status updated to ${newStatus.replaceAll('_', ' ')}.',
        );
        fetchCallbacks();
        if (selectedDetail.value?.id == id) {
          fetchCallbackDetail(id);
        }
        return true;
      } else {
        AppSnackbar.showError(
          title: 'Update Failed',
          message: response.message ?? 'Could not update callback status.',
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
