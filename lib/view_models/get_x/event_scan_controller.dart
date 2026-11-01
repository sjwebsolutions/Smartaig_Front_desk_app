import 'dart:async';
import 'package:get/get.dart';
import '../../models/event_scan_model.dart';
import '../../services/event_scan_service.dart';
import '../../utils/app_error_formatter.dart';

class EventScanController extends GetxController {
  final EventScanService _service = EventScanService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var totalValidScansToday = 0.obs;
  var scansList = <EventScanItem>[].obs;
  var searchQuery = ''.obs;

  var filterEventId = ''.obs;
  var filterGateName = ''.obs;
  var myScansOnly = false.obs;

  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    fetchTodayScans();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      fetchTodayScans(isSilent: true);
    });
  }

  Future<void> fetchTodayScans({bool isManualRefresh = false, bool isSilent = false}) async {
    if (!isSilent) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchTodayScans(
        eventId: filterEventId.value.isEmpty ? null : filterEventId.value,
        gateName: filterGateName.value.isEmpty ? null : filterGateName.value,
        myScansOnly: myScansOnly.value ? true : null,
      );

      if (response.success == true && response.data != null) {
        totalValidScansToday.value = response.data?.totalValidScansToday ?? 0;
        scansList.value = response.data?.scans ?? [];
      } else {
        if (!isSilent) {
          scansList.clear();
          totalValidScansToday.value = 0;
          errorMessage.value = response.message ?? 'Failed to load event scans';
        }
      }
    } catch (e) {
      if (!isSilent) {
        scansList.clear();
        totalValidScansToday.value = 0;
        errorMessage.value = AppErrorFormatter.format(e);
      }
    } finally {
      if (!isSilent) {
        isLoading.value = false;
      }
    }
  }

  List<EventScanItem> get filteredScans {
    if (searchQuery.value.trim().isEmpty) {
      return scansList;
    }
    final query = searchQuery.value.trim().toLowerCase();
    return scansList.where((scan) {
      final pass = scan.passNumber?.toLowerCase() ?? '';
      final name = scan.studentName?.toLowerCase() ?? '';
      final adm = scan.admissionNo?.toLowerCase() ?? '';
      final event = scan.eventTitle?.toLowerCase() ?? '';
      final gate = scan.gateName?.toLowerCase() ?? '';
      final msg = scan.scanMessage?.toLowerCase() ?? '';
      final classSec = scan.classSection?.toLowerCase() ?? '';

      return pass.contains(query) ||
          name.contains(query) ||
          adm.contains(query) ||
          event.contains(query) ||
          gate.contains(query) ||
          msg.contains(query) ||
          classSec.contains(query);
    }).toList();
  }

  var isScanning = false.obs;

  Future<Map<String, dynamic>> scanEventPass(String passCode) async {
    isScanning.value = true;
    try {
      final res = await _service.scanPass(
        passNumber: passCode,
        gateName: filterGateName.value.isEmpty ? null : filterGateName.value,
        eventId: filterEventId.value.isEmpty ? null : filterEventId.value,
      );
      await fetchTodayScans(isSilent: true);
      return res;
    } catch (e) {
      rethrow;
    } finally {
      isScanning.value = false;
    }
  }
}
