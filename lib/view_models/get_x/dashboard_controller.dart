import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/dashboard_model.dart';
import '../../services/dashboard_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_error_formatter.dart';
import 'callback_controller.dart';
import 'gate_pass_controller.dart';
import 'student_leave_controller.dart';
import 'teacher_leave_controller.dart';
import 'visitor_controller.dart';

class DashboardController extends GetxController {
  final DashboardService _dashboardService = DashboardService();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var dashboardData = Rxn<DashboardData>();

  Timer? _syncTimer;
  int _lastGatePassCount = -1;
  int _lastVisitorsCount = -1;
  int _lastCallbackPending = -1;
  int _lastStudentLeavePending = -1;
  int _lastTeacherLeavePending = -1;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard(isInitial: true);
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  void _startPeriodicSync() {
    _syncTimer?.cancel();
    // Fast real-time background sync every 8 seconds for instant live alerts
    _syncTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      fetchDashboard(isSilent: true);
    });
  }

  Future<void> fetchDashboard({
    bool isInitial = false,
    bool isSilent = false,
    bool isManualRefresh = false,
  }) async {
    if (!isSilent) {
      isLoading.value = true;
    }
    errorMessage.value = '';

    try {
      debugPrint('🚀 [DashboardController] Fetching dashboard data (silent: $isSilent, manual: $isManualRefresh)...');
      final response = await _dashboardService.fetchDashboardData();
      debugPrint('📥 [DashboardController] Result success=${response.success}, hasData=${response.data != null}');

      if ((response.success == true || response.data != null) && response.data != null) {
        final data = response.data!;
        dashboardData.value = data;

        final newGatePassCount = data.todayStats?.gatePassesCount ?? 0;
        final newVisitorsCount = data.todayStats?.visitorsCount ?? 0;
        final newCallbackPending = data.callbackRequests?.pending ?? 0;
        final newStudentLeavePending = data.studentLeaves?.totalPendingCount ?? 0;
        final newTeacherLeavePending = data.teacherLeaves?.totalPendingCount ?? 0;

        // If not initial load and not manual pull-down, detect new incoming requests in background and trigger live sound alert
        if (!isInitial && !isManualRefresh) {
          // 1. Detect New Gate Pass
          if (_lastGatePassCount != -1 && newGatePassCount > _lastGatePassCount) {
            NotificationService.instance.showLocalAlert(
              title: 'New Gate Pass Request',
              body: 'A new student Gate Pass request has been received.',
              type: 'gate_pass',
              incrementUnread: true,
            );
            if (Get.isRegistered<GatePassController>()) {
              try { Get.find<GatePassController>().fetchGatePasses(isRefresh: true, isSilent: true); } catch (_) {}
            }
          }

          // 2. Detect New Visitor
          if (_lastVisitorsCount != -1 && newVisitorsCount > _lastVisitorsCount) {
            NotificationService.instance.showLocalAlert(
              title: 'New Visitor Checked In',
              body: 'A new visitor entry has been logged at Front Desk.',
              type: 'visitor',
              incrementUnread: true,
            );
            if (Get.isRegistered<VisitorController>()) {
              try { Get.find<VisitorController>().fetchVisitors(isRefresh: true, isSilent: true); } catch (_) {}
            }
          }

          // 3. Detect New Callback Request
          if (_lastCallbackPending != -1 && newCallbackPending > _lastCallbackPending) {
            NotificationService.instance.showLocalAlert(
              title: 'New Callback Request',
              body: 'A parent has requested a callback.',
              type: 'callback',
              incrementUnread: true,
            );
            if (Get.isRegistered<CallbackController>()) {
              try { Get.find<CallbackController>().fetchCallbacks(isRefresh: true, isSilent: true); } catch (_) {}
            }
          }

          // 4. Detect New Student Leave Request
          if (_lastStudentLeavePending != -1 && newStudentLeavePending > _lastStudentLeavePending) {
            NotificationService.instance.showLocalAlert(
              title: 'New Student Leave Request',
              body: 'A new student leave request has been submitted.',
              type: 'student_leave',
              incrementUnread: true,
            );
            if (Get.isRegistered<StudentLeaveController>()) {
              try { Get.find<StudentLeaveController>().fetchStudentLeaves(isManualRefresh: true); } catch (_) {}
            }
          }

          // 5. Detect New Teacher Leave Request
          if (_lastTeacherLeavePending != -1 && newTeacherLeavePending > _lastTeacherLeavePending) {
            NotificationService.instance.showLocalAlert(
              title: 'New Teacher Leave Request',
              body: 'A new teacher leave request has been submitted.',
              type: 'teacher_leave',
              incrementUnread: true,
            );
            if (Get.isRegistered<TeacherLeaveController>()) {
              try { Get.find<TeacherLeaveController>().fetchTeacherLeaves(isManualRefresh: true); } catch (_) {}
            }
          }
        }

        // Store last seen counts
        _lastGatePassCount = newGatePassCount;
        _lastVisitorsCount = newVisitorsCount;
        _lastCallbackPending = newCallbackPending;
        _lastStudentLeavePending = newStudentLeavePending;
        _lastTeacherLeavePending = newTeacherLeavePending;

        debugPrint('✅ [DashboardController] Dashboard updated! GatePass: $newGatePassCount, Visitors: $newVisitorsCount, Callbacks: $newCallbackPending, StudentLeaves: $newStudentLeavePending, TeacherLeaves: $newTeacherLeavePending');
      } else {
        errorMessage.value = response.message ?? 'Failed to load dashboard data';
        debugPrint('⚠️ [DashboardController] Error: ${errorMessage.value}');
      }
    } catch (e, stack) {
      debugPrint('❌ [DashboardController Exception]: $e\n$stack');
      if (!isSilent) {
        errorMessage.value = AppErrorFormatter.format(e);
      }
    } finally {
      if (!isSilent) {
        isLoading.value = false;
      }
    }
  }
}
