import 'dart:async';
import 'package:get/get.dart';
import '../../models/visitor_model.dart';
import '../../services/visitor_service.dart';
import '../../utils/app_error_formatter.dart';

class VisitorController extends GetxController {
  final VisitorService _service = VisitorService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var visitorList = <VisitorItem>[].obs;
  var selectedStatus = 'pending'.obs; // 'pending', 'approved', 'rejected', 'all'
  var searchQuery = ''.obs;
  var selectedDate = ''.obs;
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    fetchVisitors();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    // Live real-time sync every 8 seconds while on Visitors screen
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchVisitors(isRefresh: true, isSilent: true);
    });
  }

  Future<void> fetchVisitors({bool isRefresh = false, bool isSilent = false}) async {
    if (!isSilent) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchVisitors(
        date: selectedDate.value,
      );

      if (response.success == true && response.data != null) {
        visitorList.value = response.data!;
      } else {
        if (!isSilent) {
          visitorList.clear();
          errorMessage.value = response.message ?? 'Failed to load visitors list';
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
    selectedStatus.value = status;
  }

  List<VisitorItem> get filteredVisitors {
    final query = searchQuery.value.trim().toLowerCase();
    final statusFilter = selectedStatus.value.trim().toLowerCase();

    return visitorList.where((item) {
      // 1. Status Filter
      bool matchesStatus = true;
      if (statusFilter != 'all') {
        final type = (item.visitorType ?? '').toLowerCase();
        final purpose = (item.purposeOfVisit ?? '').toLowerCase();
        if (statusFilter == 'pending') {
          // If no explicit status or matches pending/in-progress
          matchesStatus = type.contains('pending') || type.isEmpty || !type.contains('reject');
        } else if (statusFilter == 'approved') {
          matchesStatus = type.contains('approve') || type.contains('verified') || (item.isLocationVerified == true);
        } else if (statusFilter == 'rejected') {
          matchesStatus = type.contains('reject');
        } else {
          matchesStatus = type.contains(statusFilter) || purpose.contains(statusFilter);
        }
      }

      // 2. Search Query
      if (query.isEmpty) {
        return matchesStatus;
      }

      final name = item.name?.toLowerCase() ?? '';
      final mobile = item.mobileNo?.toLowerCase() ?? '';
      final type = item.visitorType?.toLowerCase() ?? '';
      final purpose = item.purposeOfVisit?.toLowerCase() ?? '';
      final createdBy = item.createdBy?.toLowerCase() ?? '';

      final matchesQuery = name.contains(query) ||
          mobile.contains(query) ||
          type.contains(query) ||
          purpose.contains(query) ||
          createdBy.contains(query);

      return matchesStatus && matchesQuery;
    }).toList();
  }

  void filterByDate(String date) {
    selectedDate.value = date;
    fetchVisitors();
  }

  void clearDateFilter() {
    selectedDate.value = '';
    fetchVisitors();
  }
}
