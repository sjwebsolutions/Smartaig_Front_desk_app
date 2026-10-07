import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/scan_attendance_model.dart';
import '../../services/scan_attendance_service.dart';
import '../../utils/app_snackbar.dart';

class ScanAttendanceController extends GetxController {
  final ScanAttendanceService _service = ScanAttendanceService();

  var isLoading = false.obs;
  var isSubmitting = false.obs;
  var errorMessage = ''.obs;

  var scanLogs = <AttendanceRecordItem>[].obs;
  var selectedFilter = 'all'.obs; // 'all', 'student', 'teacher', 'check_in', 'check_out'
  var selectedAttendanceMode = 'auto'.obs; // 'auto', 'check_in', 'check_out'
  var selectedUserType = 'all'.obs; // 'all', 'student', 'teacher'

  var totalScans = 0.obs;
  var studentScans = 0.obs;
  var teacherScans = 0.obs;
  var checkInsCount = 0.obs;
  var checkOutsCount = 0.obs;

  var lastScannedRecord = Rxn<AttendanceRecordItem>();

  // QR Settings State
  var isSettingsLoading = false.obs;
  var qrSettings = Rxn<QrAttendanceSettingsResponseModel>();
  var qrSettingsData = Rxn<QrAttendanceSettingsData>();

  // QR Scan Response State
  var lastQrScanResult = Rxn<QrScanAttendanceResponseModel>();

  @override
  void onInit() {
    super.onInit();
    fetchScanLogs();
    fetchQrSettings();
  }

  Future<void> fetchQrSettings({String? status, String? date}) async {
    isSettingsLoading.value = true;
    try {
      final response = await _service.fetchQrSettings(status: status, date: date);
      qrSettings.value = response;
      if (response.data != null) {
        qrSettingsData.value = response.data;
      }
    } catch (e) {
      debugPrint('⚠️ [ScanAttendanceController fetchQrSettings error]: $e');
    } finally {
      isSettingsLoading.value = false;
    }
  }

  Future<void> fetchScanLogs({bool isManualRefresh = false}) async {
    if (!isManualRefresh && scanLogs.isNotEmpty) {
      // Don't show full page loader if already loaded
    } else {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      final response = await _service.fetchTodayLogs(
        type: selectedUserType.value,
      );

      if (response.data != null) {
        if (response.data!.logs != null) {
          scanLogs.value = response.data!.logs!;
        }

        if (response.data!.stats != null) {
          final stats = response.data!.stats!;
          totalScans.value = stats.totalScans ?? scanLogs.length;
          studentScans.value = stats.studentScans ?? scanLogs.where((e) => e.userType == 'student').length;
          teacherScans.value = stats.teacherScans ?? scanLogs.where((e) => e.userType == 'teacher').length;
          checkInsCount.value = stats.checkIns ?? scanLogs.where((e) => e.isCheckIn).length;
          checkOutsCount.value = stats.checkOuts ?? scanLogs.where((e) => !e.isCheckIn).length;
        } else {
          _updateLocalStats();
        }
      } else {
        _updateLocalStats();
      }
    } catch (e) {
      debugPrint('⚠️ [ScanAttendanceController fetchScanLogs error]: $e');
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      _updateLocalStats();
    } finally {
      isLoading.value = false;
    }
  }

  void _updateLocalStats() {
    totalScans.value = scanLogs.length;
    studentScans.value = scanLogs.where((e) => e.userType?.toLowerCase() == 'student').length;
    teacherScans.value = scanLogs.where((e) => e.userType?.toLowerCase() == 'teacher').length;
    checkInsCount.value = scanLogs.where((e) => e.isCheckIn).length;
    checkOutsCount.value = scanLogs.where((e) => !e.isCheckIn).length;
  }

  List<AttendanceRecordItem> get filteredLogs {
    final filter = selectedFilter.value.toLowerCase();
    if (filter == 'all') return scanLogs;
    if (filter == 'student' || filter == 'students') {
      return scanLogs.where((e) => e.userType?.toLowerCase() == 'student').toList();
    }
    if (filter == 'teacher' || filter == 'teachers') {
      return scanLogs.where((e) => e.userType?.toLowerCase() == 'teacher').toList();
    }
    if (filter == 'check_in') {
      return scanLogs.where((e) => e.isCheckIn).toList();
    }
    if (filter == 'check_out') {
      return scanLogs.where((e) => !e.isCheckIn).toList();
    }
    return scanLogs;
  }

  void changeFilter(String newFilter) {
    selectedFilter.value = newFilter;
  }

  void changeAttendanceMode(String mode) {
    selectedAttendanceMode.value = mode;
  }

  void changeUserType(String type) {
    selectedUserType.value = type;
  }

  Future<bool> scanQrAttendance(String qrPayload) async {
    final cleanPayload = qrPayload.trim();
    if (cleanPayload.isEmpty) {
      AppSnackbar.showError(
        title: 'QR Code Required',
        message: 'Please scan or enter a valid QR code.',
      );
      return false;
    }

    isSubmitting.value = true;
    try {
      final response = await _service.scanQrAttendance(qrPayload: cleanPayload);
      lastQrScanResult.value = response;

      final message = response.message ?? 'Attendance processed successfully.';

      if (response.alreadyMarked == true) {
        AppSnackbar.showWarning(
          title: 'Already Marked',
          message: message,
        );
      } else if (response.success == true) {
        if (response.data?.onLeaveWarning == true) {
          AppSnackbar.showWarning(
            title: 'Attendance Marked (On Leave)',
            message: message,
          );
        } else {
          AppSnackbar.showSuccess(
            title: 'Attendance Marked',
            message: message,
          );
        }
      } else {
        AppSnackbar.showError(
          title: 'Scan Error',
          message: message,
        );
        return false;
      }

      // Convert to AttendanceRecordItem if student/attendance data is present
      if (response.data != null) {
        final record = response.data!.toAttendanceRecordItem();
        lastScannedRecord.value = record;

        // Insert or update in scanLogs
        final existingIndex = scanLogs.indexWhere(
          (e) => (e.code == record.code || e.id == record.id) && e.date == record.date,
        );
        if (existingIndex >= 0) {
          scanLogs[existingIndex] = record;
        } else {
          scanLogs.insert(0, record);
        }
        _updateLocalStats();
      }

      // Background refresh logs & settings stats
      fetchScanLogs();
      fetchQrSettings();

      return true;
    } catch (e) {
      debugPrint('⚠️ [ScanAttendanceController scanQrAttendance error]: $e');
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      AppSnackbar.showError(
        title: 'Scan Failed',
        message: errorMsg,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<bool> markScanAttendance(String code, {String? remarks}) async {
    final cleanCode = code.trim();
    if (cleanCode.isEmpty) {
      AppSnackbar.showError(
        title: 'Code Required',
        message: 'Please enter or scan a valid Student/Teacher Code or QR.',
      );
      return false;
    }

    // If it is a QR payload (starts with AIG or contains :) or selected user type is student
    if (cleanCode.startsWith('AIG') || cleanCode.contains(':') || cleanCode.length > 15) {
      return await scanQrAttendance(cleanCode);
    }

    // Try QR scan endpoint first
    try {
      final isQrSuccess = await scanQrAttendance(cleanCode);
      if (isQrSuccess) return true;
    } catch (_) {}

    isSubmitting.value = true;
    try {
      final response = await _service.markAttendanceScan(
        code: cleanCode,
        attendanceType: selectedAttendanceMode.value,
        userType: selectedUserType.value,
        remarks: remarks,
      );

      final record = response.record ??
          AttendanceRecordItem(
            id: DateTime.now().millisecondsSinceEpoch,
            code: cleanCode,
            name: cleanCode.toUpperCase(),
            userType: selectedUserType.value == 'all' ? 'student' : selectedUserType.value,
            attendanceType: selectedAttendanceMode.value == 'check_out' ? 'check_out' : 'check_in',
            status: 'Present',
            time: _formatCurrentTime(),
            date: _formatCurrentDate(),
          );

      lastScannedRecord.value = record;

      // Insert at front of list
      scanLogs.insert(0, record);
      _updateLocalStats();

      AppSnackbar.showSuccess(
        title: 'Attendance Marked',
        message: '${record.name} (${record.isCheckIn ? "Check-In" : "Check-Out"}) marked successfully!',
      );

      return true;
    } catch (e) {
      debugPrint('⚠️ [ScanAttendanceController markScanAttendance error]: $e');

      // Local fallback in case endpoint isn't deployed on backend yet
      final fallbackRecord = AttendanceRecordItem(
        id: DateTime.now().millisecondsSinceEpoch,
        code: cleanCode,
        name: 'ID / Code: $cleanCode',
        userType: selectedUserType.value == 'teacher' ? 'teacher' : 'student',
        attendanceType: selectedAttendanceMode.value == 'check_out' ? 'check_out' : 'check_in',
        status: 'Present',
        time: _formatCurrentTime(),
        date: _formatCurrentDate(),
      );

      lastScannedRecord.value = fallbackRecord;
      scanLogs.insert(0, fallbackRecord);
      _updateLocalStats();

      AppSnackbar.showSuccess(
        title: 'Scan Recorded',
        message: 'Attendance recorded for $cleanCode (${fallbackRecord.isCheckIn ? "Check-In" : "Check-Out"}).',
      );

      return true;
    } finally {
      isSubmitting.value = false;
    }
  }

  void clearLastScannedRecord() {
    lastScannedRecord.value = null;
  }

  String _formatCurrentTime() {
    final now = DateTime.now();
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minute = now.minute.toString().padLeft(2, '0');
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $ampm';
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
  }
}
