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

  List<VisitorItem> get filteredVisitors {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return visitorList;
    }
    return visitorList.where((item) {
      final name = item.name?.toLowerCase() ?? '';
      final mobile = item.mobileNo?.toLowerCase() ?? '';
      final type = item.visitorType?.toLowerCase() ?? '';
      final purpose = item.purposeOfVisit?.toLowerCase() ?? '';
      final createdBy = item.createdBy?.toLowerCase() ?? '';

      return name.contains(query) ||
          mobile.contains(query) ||
          type.contains(query) ||
          purpose.contains(query) ||
          createdBy.contains(query);
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
