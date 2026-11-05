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
  var isSubmittingCheckin = false.obs;

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

  Future<PassCheckinResponseModel> checkInAttendees({
    dynamic passId,
    String? passNumber,
    required List<dynamic> attendeeIds,
    String? gateName,
    String? remarks,
  }) async {
    isSubmittingCheckin.value = true;
    try {
      final res = await _service.checkInAttendees(
        passId: passId,
        passNumber: passNumber,
        attendeeIds: attendeeIds,
        gateName: gateName ?? (filterGateName.value.isEmpty ? null : filterGateName.value),
        remarks: remarks,
      );
      await fetchTodayScans(isSilent: true);
      return res;
    } catch (e) {
      rethrow;
    } finally {
      isSubmittingCheckin.value = false;
    }
  }

  var isSearchingStudents = false.obs;
  var searchedStudents = <EventSearchStudentItem>[].obs;
  var searchStudentError = ''.obs;

  Future<void> searchStudentsForEvent({required dynamic eventId, required String query}) async {
    if (query.trim().isEmpty) {
      searchedStudents.clear();
      searchStudentError.value = '';
      return;
    }

    isSearchingStudents.value = true;
    searchStudentError.value = '';

    try {
      final res = await _service.searchStudents(eventId: eventId, query: query);
      if (res.success == true && res.data != null) {
        searchedStudents.value = res.data!;
      } else {
        searchedStudents.clear();
        searchStudentError.value = 'No student records found.';
      }
    } catch (e) {
      searchedStudents.clear();
      searchStudentError.value = AppErrorFormatter.format(e);
    } finally {
      isSearchingStudents.value = false;
    }
  }

  var isLoadingApplications = false.obs;
  var passApplications = <PassApplicationItem>[].obs;
  var passApplicationsError = ''.obs;

  Future<void> fetchPassApplications({dynamic eventId, bool isManualRefresh = false}) async {
    isLoadingApplications.value = true;
    passApplicationsError.value = '';

    try {
      final targetEventId = eventId ?? (filterEventId.value.isNotEmpty ? filterEventId.value : '1');
      final res = await _service.fetchPassApplications(eventId: targetEventId);
      if (res.success == true && res.data != null) {
        passApplications.value = res.data!;
      } else {
        passApplications.clear();
        passApplicationsError.value = 'No pass applications found.';
      }
    } catch (e) {
      passApplications.clear();
      passApplicationsError.value = AppErrorFormatter.format(e);
    } finally {
      isLoadingApplications.value = false;
    }
  }

  var isIssuingWalkInPass = false.obs;

  Future<IssueWalkInPassResponseModel> issueWalkInPass({
    required dynamic eventId,
    required dynamic studentId,
    bool autoApprove = true,
    bool autoCheckin = true,
    String? gateName,
    String? remarks,
    required String personType,
    required String attendeeName,
    required String mobileNo,
    String? whatsappNo,
    String? aadhaarNumber,
    dynamic photoFile,
    String? existingPhotoPath,
  }) async {
    isIssuingWalkInPass.value = true;
    try {
      final res = await _service.issueWalkInPass(
        eventId: eventId,
        studentId: studentId,
        autoApprove: autoApprove,
        autoCheckin: autoCheckin,
        gateName: gateName ?? (filterGateName.value.isNotEmpty ? filterGateName.value : 'main gate'),
        remarks: remarks ?? 'Walk-in entry issued at gate',
        personType: personType,
        attendeeName: attendeeName,
        mobileNo: mobileNo,
        whatsappNo: whatsappNo,
        aadhaarNumber: aadhaarNumber,
        photoFile: photoFile,
        existingPhotoPath: existingPhotoPath,
      );
      await fetchPassApplications(eventId: eventId, isManualRefresh: true);
      return res;
    } catch (e) {
      rethrow;
    } finally {
      isIssuingWalkInPass.value = false;
    }
  }

  var isUpdatingPassStatus = false.obs;

  Future<UpdatePassStatusResponseModel> updatePassStatus({
    required dynamic passId,
    required String action,
    String? remarks,
    dynamic eventId,
  }) async {
    isUpdatingPassStatus.value = true;
    try {
      final res = await _service.updatePassStatus(
        passId: passId,
        action: action,
        remarks: remarks,
      );
      await fetchPassApplications(eventId: eventId, isManualRefresh: true);
      return res;
    } catch (e) {
      rethrow;
    } finally {
      isUpdatingPassStatus.value = false;
    }
  }
}
